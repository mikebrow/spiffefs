#!/usr/bin/env bash

set -xe

SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$(dirname "${SCRIPT}")"
TESTDIR="${SCRIPTPATH}/../../.github/tests"

CLEANUP=1

if [ "x${GITHUB_JOB}" != "x" ]; then
  echo "Running in GitHub"
else
  echo "Do not run this script on your own box."
  exit 1
fi

teardown() {
  echo ---------------------------
  if [ $0 -ne 0 ]; then
    systemctl status spire-server@main || true
    systemctl status spire-server@other || true
  fi
}

trap 'EC=$? && trap - SIGTERM && teardown $EC' SIGINT SIGTERM EXIT

wait_for_healthcheck() {
  local app="$1"
  local socket="$2"
  local timeout=30
  local count=0
  while [ "$count" -lt "$timeout" ]; do
    rc=0
    sudo "$app" healthcheck -socketPath "$socket" || rc=$?
    if [ "$rc" -eq 0 ]; then
      return 0
    fi
    sleep 1
    ((count++)) || true
  done
  return 1
}

wait_for_trust_sync() {
  local socket="$1"
  local timeout=30
  local count=0
  while [ "$count" -lt "$timeout" ]; do
    entries=$(sudo spire-server bundle list -socketPath "$socket" | wc -l)
    if [ "$entries" -ne 0 ]; then
      return 0
    fi
    sleep 1
    ((count++)) || true
  done
  return 1
}

wait_for_jwt() {
  local socket="$1"
  local timeout=30
  local count=0
  while [ "$count" -lt "$timeout" ]; do
      rc=0
      sudo spire-agent api fetch jwt -audience test -socketPath "$socket" || rc=$?
      if [ "$rc" -eq 0 ]; then
        return 0
      fi
      sleep 1
      ((count++)) || true
  done
  return 1
}

# Get the package repo and install the packages
sudo curl -s -o /etc/apt/sources.list.d/spire-examples.list https://raw.githubusercontent.com/spiffe/spire-examples/refs/heads/main/examples/debs/amd64/spire-examples.list
sudo apt-get update
sudo apt-get install -y spire-common spire-agent spire-server spire-controller-manager spiffe-socat-unix socat spire-trust-sync spiffe-helper

# Startup the servers
sudo systemctl start spire-server@main spire-server@other

# Register some workloads with the spire server using manifests
sudo mkdir -p /etc/spire/server/main/manifests/
sudo cp "${SCRIPTPATH}/example-manifests"/* /etc/spire/server/main/manifests/

# Startup servers and make sure they are ready
wait_for_healthcheck spire-server /run/spire/server/sockets/main/private/api.sock
wait_for_healthcheck spire-server /run/spire/server/sockets/other/private/api.sock

sudo spire-server -instance other bundle show

# Configure agent. For the test, create join tokens for both agents. You should really use a node attestor other then join tokens such as tpm-direct, http_challenge, or a cloud provider one
JOIN_TOKEN=$(sudo spire-server token generate -spiffeID spiffe://example.org/agent/node1 | awk '{print "\""$2"\""}')
export JOIN_TOKEN
sudo /bin/bash -c "echo JOIN_TOKEN=${JOIN_TOKEN} > /etc/spire/agent/main.env"

# Since we are running the two root spire servers on the same machine, we need to configure the trust sync instances to point to the opposite server
sudo /bin/bash -c 'echo "SPIRE_SERVER_SOCKET=/var/run/spire/server/sockets/b/private/api.sock" > /etc/spire/trust-sync/a.conf'
sudo /bin/bash -c 'echo "SPIRE_SERVER_SOCKET=/var/run/spire/server/sockets/a/private/api.sock" > /etc/spire/trust-sync/b.conf'

# Startup the agent
sudo systemctl start spire-agent@main
wait_for_healthcheck spire-agent /var/run/spire/agent/sockets/main/public/api.sock

