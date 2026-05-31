#!/usr/bin/env bash
set -euo pipefail

log() { printf '[k6-install] %s\n' "$*"; }
die() { printf '[k6-install][error] %s\n' "$*" >&2; exit 1; }

need() {
  command -v "$1" >/dev/null 2>&1 || return 1
}

os_name="$(uname -s 2>/dev/null || true)"
arch_name="$(uname -m 2>/dev/null || true)"

case "$os_name" in
  Darwin) os_id="darwin" ;;
  Linux)  os_id="linux" ;;
  *) die "This script is for Linux/macOS only. Detected: ${os_name:-unknown}" ;;
esac

case "$arch_name" in
  x86_64|amd64) arch_id="amd64" ;;
  arm64|aarch64) arch_id="arm64" ;;
  *) die "Unsupported CPU architecture: ${arch_name:-unknown}" ;;
esac

install_from_binary() {
  local asset_suffix="$1"
  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  log "Fetching latest k6 release metadata..."
  local api_json asset_url
  api_json="$(curl -fsSL https://api.github.com/repos/grafana/k6/releases/latest)"

  asset_url="$(
    printf '%s' "$api_json" \
      | grep -oE 'https://[^"]+' \
      | grep -E "$asset_suffix" \
      | head -n1 || true
  )"

  [ -n "$asset_url" ] || die "Could not find a download asset for: $asset_suffix"

  local archive="$tmpdir/k6-archive"
  log "Downloading: $asset_url"
  curl -fL "$asset_url" -o "$archive"

  log "Extracting archive..."
  tar -xzf "$archive" -C "$tmpdir"

  local k6_bin
  k6_bin="$(find "$tmpdir" -type f \( -name k6 -o -name k6.exe \) | head -n1)"
  [ -n "$k6_bin" ] || die "k6 binary was not found after extraction."

  local target_dir="${INSTALL_DIR:-/usr/local/bin}"
  if [ ! -w "$target_dir" ] && command -v sudo >/dev/null 2>&1; then
    log "Installing to $target_dir via sudo"
    sudo mkdir -p "$target_dir"
    sudo install -m 0755 "$k6_bin" "$target_dir/k6"
  else
    mkdir -p "$target_dir"
    install -m 0755 "$k6_bin" "$target_dir/k6"
  fi

  log "Installed k6 to $target_dir/k6"
}

if [ "$os_id" = "darwin" ]; then
  if need brew; then
    log "Homebrew detected; installing/upgrading k6..."
    brew update >/dev/null 2>&1 || true
    brew install k6 || brew upgrade k6
  else
    log "Homebrew not found; using official binary fallback."
    install_from_binary "k6-v[0-9.]+-darwin-${arch_id}\\.tar\\.gz"
  fi
else
  # Linux: prefer native package managers, then fall back to the official binary.
  if need apt-get || need apt; then
    log "Debian/Ubuntu path detected."
    if ! need sudo; then
      [ "$(id -u)" -eq 0 ] || die "sudo is required for Debian/Ubuntu installation."
      SUDO=""
    else
      SUDO="sudo"
    fi
    $SUDO apt-get update
    $SUDO apt-get install -y curl gpg ca-certificates
    $SUDO mkdir -p /usr/share/keyrings
    curl -fsSL https://dl.k6.io/key.gpg | $SUDO gpg --dearmor -o /usr/share/keyrings/k6-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | $SUDO tee /etc/apt/sources.list.d/k6.list >/dev/null
    $SUDO apt-get update
    $SUDO apt-get install -y k6
  elif need dnf || need yum; then
    log "Fedora/CentOS/RHEL path detected."
    if ! need sudo; then
      [ "$(id -u)" -eq 0 ] || die "sudo is required for DNF/YUM installation."
      SUDO=""
    else
      SUDO="sudo"
    fi
    $SUDO dnf install -y https://dl.k6.io/rpm/repo.rpm 2>/dev/null || $SUDO yum install -y https://dl.k6.io/rpm/repo.rpm
    $SUDO dnf install -y k6 2>/dev/null || $SUDO yum install -y k6
  else
    log "No supported Linux package manager found; using official binary fallback."
    install_from_binary "k6-v[0-9.]+-linux-${arch_id}\\.tar\\.gz"
  fi
fi

if command -v k6 >/dev/null 2>&1; then
  log "Verifying installation..."
  k6 version
  log "Done."
else
  die "k6 is not available on PATH after installation."
fi
