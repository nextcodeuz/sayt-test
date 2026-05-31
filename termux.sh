#!/usr/bin/env bash
set -euo pipefail

log() { printf '[k6-termux] %s\n' "$*"; }
die() { printf '[k6-termux][error] %s\n' "$*" >&2; exit 1; }

[ -n "${PREFIX:-}" ] || die "This script is meant for Termux."

command -v pkg >/dev/null 2>&1 || die "pkg not found. Are you running inside Termux?"

log "Updating Termux packages..."
pkg update -y
pkg upgrade -y

log "Installing proot-distro and helper tools..."
pkg install -y proot-distro curl gnupg ca-certificates

if ! proot-distro list-installed 2>/dev/null | grep -qi '^ubuntu$'; then
  log "Installing Ubuntu inside proot-distro..."
  proot-distro install ubuntu
fi

log "Installing k6 inside Ubuntu proot environment..."
proot-distro login ubuntu --shared-tmp -- bash -lc '
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y curl gpg ca-certificates
mkdir -p /usr/share/keyrings
curl -fsSL https://dl.k6.io/key.gpg | gpg --dearmor -o /usr/share/keyrings/k6-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" > /etc/apt/sources.list.d/k6.list
apt-get update
apt-get install -y k6
k6 version
'

log "Done. Start Ubuntu again with: proot-distro login ubuntu"
