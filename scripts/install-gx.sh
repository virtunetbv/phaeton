#!/bin/sh
set -eu
set -o pipefail 2>/dev/null || true

GITHUB_API_URL="https://api.github.com/repos/virtunetbv/phaeton"
INSTALL_DIR="/data/phaeton"
RUN_SCRIPT="${INSTALL_DIR}/run.sh"
RC_LOCAL="/data/rc.local"
MARKER_BEGIN="# BEGIN PHAETON AUTOSTART"
MARKER_END="# END PHAETON AUTOSTART"

echo "[phaeton] GX installer"

if [ "$(id -u)" != "0" ]; then
  echo "This script must run as root on the GX device." >&2
  exit 1
fi

if [ ! -f /etc/venus/machine ]; then
  echo "This installer only supports Venus OS / GX devices." >&2
  exit 1
fi

ARCH=$(uname -m)
if [ "$ARCH" != "armv7l" ] && [ "$ARCH" != "armv7" ]; then
  echo "Unsupported architecture: $ARCH (expected armv7)." >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"

TMP_DIR=$(mktemp -d /tmp/phaeton-install.XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

echo "[phaeton] Querying latest public GitHub release"
RELEASE_JSON=$(curl -fsSL "$GITHUB_API_URL/releases/latest")
ARCHIVE_URL=$(printf '%s\n' "$RELEASE_JSON" | sed -n 's/.*"browser_download_url": "\(https:[^"]*armv7-unknown-linux-gnueabihf\.tar\.gz\)".*/\1/p' | head -n 1)
SHA_URL=$(printf '%s\n' "$RELEASE_JSON" | sed -n 's/.*"browser_download_url": "\(https:[^"]*SHA256SUMS\)".*/\1/p' | head -n 1)

if [ -z "$ARCHIVE_URL" ] || [ -z "$SHA_URL" ]; then
  echo "Failed to locate armv7 release assets in the latest GitHub release." >&2
  exit 1
fi

ARCHIVE_NAME=$(basename "$ARCHIVE_URL")
ARCHIVE_PATH="$TMP_DIR/$ARCHIVE_NAME"
SHA_PATH="$TMP_DIR/SHA256SUMS"
CHECK_PATH="$TMP_DIR/$ARCHIVE_NAME.sha256"
STAGE_DIR="$TMP_DIR/stage"

echo "[phaeton] Downloading $ARCHIVE_NAME"
curl -fL "$ARCHIVE_URL" -o "$ARCHIVE_PATH"
curl -fL "$SHA_URL" -o "$SHA_PATH"

grep "  $ARCHIVE_NAME\$" "$SHA_PATH" > "$CHECK_PATH" || {
  echo "Checksum entry for $ARCHIVE_NAME not found in SHA256SUMS." >&2
  exit 1
}

echo "[phaeton] Verifying checksum"
(cd "$TMP_DIR" && sha256sum -c "$(basename "$CHECK_PATH")") || {
  echo "Checksum verification failed for $ARCHIVE_NAME." >&2
  exit 1
}

mkdir -p "$STAGE_DIR"
tar -xzf "$ARCHIVE_PATH" -C "$STAGE_DIR"

if [ ! -f "$STAGE_DIR/phaeton" ]; then
  echo "Release package is missing the phaeton binary." >&2
  exit 1
fi

rm -rf "$INSTALL_DIR/webui"
install -m 0755 "$STAGE_DIR/phaeton" "$INSTALL_DIR/phaeton"
if [ -d "$STAGE_DIR/webui" ]; then
  cp -R "$STAGE_DIR/webui" "$INSTALL_DIR/"
fi

cat > "$RUN_SCRIPT" <<'RUN'
#!/bin/sh
set -e
export PHAETON_DATA_DIR=/data/phaeton
export RUST_LOG=info
exec /data/phaeton/phaeton
RUN
chmod +x "$RUN_SCRIPT"

AUTOSTART_BLOCK=$(cat <<'BLOCK'
# BEGIN PHAETON AUTOSTART
if [ -x /data/phaeton/run.sh ]; then
  /data/phaeton/run.sh >> /data/phaeton/phaeton.log 2>&1 &
fi
# END PHAETON AUTOSTART
BLOCK
)

if [ -f "$RC_LOCAL" ]; then
  awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" '
    $0 == begin { skip=1; next }
    $0 == end { skip=0; next }
    skip != 1 { print }
  ' "$RC_LOCAL" > "$TMP_DIR/rc.local.clean"
else
  : > "$TMP_DIR/rc.local.clean"
fi

{
  printf '#!/bin/sh\n\n'
  if [ -s "$TMP_DIR/rc.local.clean" ]; then
    awk '
      NR == 1 && $0 == "#!/bin/sh" { next }
      $0 == "exit 0" { next }
      { print }
    ' "$TMP_DIR/rc.local.clean"
    printf '\n'
  fi
  printf '%s\n' "$AUTOSTART_BLOCK"
  printf '\nexit 0\n'
} > "$TMP_DIR/rc.local.new"

install -m 0755 "$TMP_DIR/rc.local.new" "$RC_LOCAL"

echo "[phaeton] Installed to $INSTALL_DIR"
echo "[phaeton] Autostart configured in $RC_LOCAL"
echo "[phaeton] First start writes credentials to $INSTALL_DIR/config.yaml"
echo "[phaeton] Free for personal use. Commercial use requires a license from Virtunet BV."
echo "[phaeton] Reboot the GX or start now with: $RUN_SCRIPT"
echo "[phaeton] Ensure Victron 'Modifications enabled' stays enabled for /data/rc.local to run."
