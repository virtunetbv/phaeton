#!/bin/sh
set -eu

GITHUB_API_URL="https://api.github.com/repos/virtunetbv/phaeton"
INSTALL_DIR="/data/phaeton"
ALT_PORT="1502"
BINARY_PATH="$INSTALL_DIR/phaeton"
BINARY_TMP="$INSTALL_DIR/phaeton.new"
RC_LOCAL="/data/rc.local"
RC_LOCAL_TMP="$INSTALL_DIR/rc.local.new"
RC_LOCAL_INPUT="$INSTALL_DIR/rc.local.input"

echo "[phaeton] Cerbo GX installer"

update_rc_local() {
  if [ -f "$RC_LOCAL" ]; then
    if sed -n '1p' "$RC_LOCAL" | grep -q '^#!'; then
      cp "$RC_LOCAL" "$RC_LOCAL_INPUT"
    else
      {
        printf '%s\n' '#!/bin/sh'
        cat "$RC_LOCAL"
      } > "$RC_LOCAL_INPUT"
    fi
  else
    printf '%s\n' '#!/bin/sh' > "$RC_LOCAL_INPUT"
  fi

  awk '
    $0 == "# Phaeton autostart begin" { skipping = 1; next }
    $0 == "# Phaeton autostart end" { skipping = 0; next }
    skipping { next }
    $0 == "cd /data/phaeton && /data/phaeton/phaeton &" { next }
    $0 == "cd /data/phaeton && ./phaeton &" { next }
    $0 == "/data/phaeton/phaeton >> /data/phaeton.log 2>&1 &" { next }
    $0 == "/data/phaeton/run.sh &" { next }
    $0 == "exit 0" && !inserted {
      print "# Phaeton autostart begin"
      print "/data/phaeton/run.sh &"
      print "# Phaeton autostart end"
      inserted = 1
      has_exit = 1
      print
      next
    }
    $0 == "exit 0" {
      has_exit = 1
      print
      next
    }
    { print }
    END {
      if (!inserted) {
        print "# Phaeton autostart begin"
        print "/data/phaeton/run.sh &"
        print "# Phaeton autostart end"
      }
      if (!has_exit) {
        print "exit 0"
      }
    }
  ' "$RC_LOCAL_INPUT" > "$RC_LOCAL_TMP"

  mv "$RC_LOCAL_TMP" "$RC_LOCAL"
  rm -f "$RC_LOCAL_INPUT"
  chmod 0755 "$RC_LOCAL"
}

if [ "$(id -u)" != "0" ]; then
  echo "This script must run as root (GX shell)." >&2
  exit 1
fi

if [ ! -f /etc/venus/machine ]; then
  echo "Not a Venus OS / Cerbo GX device; aborting." >&2
  exit 1
fi

ARCH=$(uname -m)
if [ "$ARCH" != "armv7l" ] && [ "$ARCH" != "armv7" ]; then
  echo "Unsupported arch: $ARCH (expected armv7)." >&2
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

echo "[phaeton] Downloading release package $ARCHIVE_NAME"
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
rm -f "$BINARY_TMP"
cp "$STAGE_DIR/phaeton" "$BINARY_TMP"
chmod 0755 "$BINARY_TMP"
mv "$BINARY_TMP" "$BINARY_PATH"
if [ -d "$STAGE_DIR/webui" ]; then
  cp -R "$STAGE_DIR/webui" "$INSTALL_DIR/"
fi

cat > "$INSTALL_DIR/run.sh" <<'RUN'
#!/bin/sh
set -e
export PHAETON_DATA_DIR=/data/phaeton
export RUST_LOG=info
exec /data/phaeton/phaeton
RUN

chmod +x "$INSTALL_DIR/run.sh"
update_rc_local

echo "[phaeton] Installed to $INSTALL_DIR"
echo "[phaeton] Web UI: http://<gx-ip>:8088"
echo "[phaeton] First start writes credentials to $INSTALL_DIR/config.yaml"
echo "[phaeton] Free for personal use. Commercial use requires a license from Virtunet BV."
echo "[phaeton] Start now with: $INSTALL_DIR/run.sh"
echo "[phaeton] Autostart configured in $RC_LOCAL"
echo "[phaeton] Modbus server will run on alternate port (e.g., $ALT_PORT) automatically"
