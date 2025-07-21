#!/bin/bash
set -e

if [ ! -f /etc/wireguard/wg0.conf ]; then
  echo "Missing /etc/wireguard/wg0.conf. Please mount it into the container."
  exit 1
fi

chmod 600 /etc/wireguard/wg0.conf

cleanup() {
  echo "[*] Caught signal, attempting to bring down wg0"
  wg-quick down wg0 || true
}
trap cleanup SIGINT SIGTERM EXIT

wg-quick up wg0

while :; do sleep 1; done