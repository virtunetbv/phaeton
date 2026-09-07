#!/bin/sh
set -eu

GITHUB_API_URL="https://api.github.com/repos/virtunetbv/phaeton"
PUBLIC_KEY_URL="https://raw.githubusercontent.com/virtunetbv/phaeton/main/release-signing-public.pem"
DATA_ROOT="/data"
INSTANCE_NAME=""
INSTANCE_SET=0
DEMO=0
WEB_PORT="8088"

usage() {
  echo "Usage: install-gx.sh [--instance NAME --web-port PORT [--demo]]"
  echo "Named instances use MQTT/GX control and independent data and activation."
}

parse_options() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --instance|--web-port)
        if [ "$#" -lt 2 ]; then
          usage >&2
          return 1
        fi
        case "$1" in
          --instance) INSTANCE_NAME="$2"; INSTANCE_SET=1 ;;
          --web-port) WEB_PORT="$2" ;;
        esac
        shift 2
        ;;
      --demo) DEMO=1; shift ;;
      --help|-h) usage; exit 0 ;;
      *) usage >&2; return 1 ;;
    esac
  done
  case "$WEB_PORT" in
    ''|*[!0-9]*|0*) echo "Invalid web port" >&2; return 1 ;;
  esac
  if [ "${#WEB_PORT}" -gt 5 ] || [ "$WEB_PORT" -lt 1024 ] || [ "$WEB_PORT" -gt 65535 ]; then
    echo "Web port must be between 1024 and 65535" >&2
    return 1
  fi
  if [ "$INSTANCE_SET" = 1 ] && [ -z "$INSTANCE_NAME" ]; then
    echo "Instance name must not be empty" >&2
    return 1
  fi
  if [ -n "$INSTANCE_NAME" ]; then
    case "$INSTANCE_NAME" in
      [!a-z0-9]*|*[!a-z0-9-]*) echo "Invalid instance name" >&2; return 1 ;;
    esac
    if [ "${#INSTANCE_NAME}" -gt 32 ] || [ "$WEB_PORT" = 8088 ]; then
      echo "Use a name up to 32 characters and a dedicated web port (not 8088)" >&2
      return 1
    fi
    INSTALL_DIR="$DATA_ROOT/phaeton-instances/$INSTANCE_NAME"
    AUTOSTART_BEGIN="# Phaeton instance $INSTANCE_NAME autostart begin"
    AUTOSTART_END="# Phaeton instance $INSTANCE_NAME autostart end"
  else
    if [ "$DEMO" = 1 ]; then
      echo "--demo requires --instance" >&2
      return 1
    fi
    if [ "$WEB_PORT" != 8088 ]; then
      echo "--web-port requires --instance" >&2
      return 1
    fi
    INSTALL_DIR="$DATA_ROOT/phaeton"
    AUTOSTART_BEGIN="# Phaeton autostart begin"
    AUTOSTART_END="# Phaeton autostart end"
  fi
  BINARY_PATH="$INSTALL_DIR/phaeton"
  BINARY_TMP="$INSTALL_DIR/phaeton.new"
  RC_LOCAL="$DATA_ROOT/rc.local"
  RC_LOCAL_TMP="$INSTALL_DIR/rc.local.new"
  RC_LOCAL_INPUT="$INSTALL_DIR/rc.local.input"
}

check_instance_port() {
  [ -n "$INSTANCE_NAME" ] || return 0
  for other in "$DATA_ROOT"/phaeton-instances/*/instance.json; do
    [ -f "$other" ] || continue
    [ "$other" != "$INSTALL_DIR/instance.json" ] || continue
    port=$(sed -n 's/.*"web_port"[[:space:]]*:[[:space:]]*\([0-9]*\).*/\1/p' "$other")
    if [ "$port" = "$WEB_PORT" ]; then
      echo "Web port $WEB_PORT is already assigned by $other" >&2
      return 1
    fi
  done
}

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

  awk -v begin="$AUTOSTART_BEGIN" -v end="$AUTOSTART_END" \
    -v run="$INSTALL_DIR/run.sh &" -v legacy="$INSTANCE_NAME" '
    $0 == begin { skipping = 1; next }
    $0 == end { skipping = 0; next }
    skipping { next }
    legacy == "" && $0 == "cd /data/phaeton && /data/phaeton/phaeton &" { next }
    legacy == "" && $0 == "cd /data/phaeton && ./phaeton &" { next }
    legacy == "" && $0 == "/data/phaeton/phaeton >> /data/phaeton.log 2>&1 &" { next }
    legacy == "" && $0 == "/data/phaeton/run.sh &" { next }
    $0 == "exit 0" && !inserted {
      print begin
      print run
      print end
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
        print begin
        print run
        print end
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

detect_gx_ip() {
  DETECTED_IP=""
  if command -v ip >/dev/null 2>&1; then
    DETECTED_IP=$(ip -4 route get 1.1.1.1 2>/dev/null \
      | sed -n 's/.* src \([0-9][0-9.]*\).*/\1/p' \
      | head -n 1 \
      || true)
  fi

  if [ -z "$DETECTED_IP" ] && command -v hostname >/dev/null 2>&1; then
    DETECTED_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
  fi

  printf '%s\n' "$DETECTED_IP"
}

is_phaeton_running() {
  # Executable paths distinguish instances, including a running binary replaced
  # by an update (Linux appends " (deleted)" to that symlink target).
  for process in /proc/[0-9]*/exe; do
    target=$(readlink "$process" 2>/dev/null || true)
    case "$target" in
      "$BINARY_PATH"|"$BINARY_PATH (deleted)") return 0 ;;
    esac
  done
  return 1
}

write_run_script() {
  cat > "$INSTALL_DIR/run.sh" <<RUN
#!/bin/sh
set -e
export PHAETON_DATA_DIR='$INSTALL_DIR'
export RUST_LOG=info
cd '$INSTALL_DIR'
exec '$BINARY_PATH'
RUN
  chmod +x "$INSTALL_DIR/run.sh"
}

start_phaeton() {
  if is_phaeton_running; then
    echo "[phaeton] Phaeton is already running"
    return
  fi

  echo "[phaeton] Starting Phaeton in the background"
  if command -v nohup >/dev/null 2>&1; then
    (cd "$INSTALL_DIR" && nohup "$INSTALL_DIR/run.sh" >/dev/null 2>&1 &)
  else
    (cd "$INSTALL_DIR" && "$INSTALL_DIR/run.sh" >/dev/null 2>&1 &)
  fi

  sleep 2
  if is_phaeton_running; then
    echo "[phaeton] Phaeton started"
  else
    echo "[phaeton] Phaeton start was requested; check $INSTALL_DIR/phaeton.log if the web UI is not reachable"
  fi
}

# Runtime installation begins here.
parse_options "$@"
check_instance_port

echo "[phaeton] Cerbo GX installer${INSTANCE_NAME:+: $INSTANCE_NAME}"

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

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required to verify signed release checksums." >&2
  exit 1
fi

mkdir -p "$DATA_ROOT"
# Serialize installers because all instances share rc.local and the port map.
INSTALL_LOCK="$DATA_ROOT/.phaeton-install.lock"
if ! mkdir "$INSTALL_LOCK" 2>/dev/null; then
  echo "Another installer is active; if it crashed, remove $INSTALL_LOCK after checking processes." >&2
  exit 1
fi
TMP_DIR=""
trap '[ -z "$TMP_DIR" ] || rm -rf "$TMP_DIR"; rmdir "$INSTALL_LOCK"' EXIT
trap 'exit 1' INT TERM
check_instance_port
mkdir -p "$INSTALL_DIR"
chmod 0700 "$INSTALL_DIR"

TMP_DIR=$(mktemp -d /tmp/phaeton-install.XXXXXX)

echo "[phaeton] Querying latest public GitHub release"
RELEASE_JSON=$(curl -fsSL "$GITHUB_API_URL/releases/latest")
ARCHIVE_URL=$(printf '%s\n' "$RELEASE_JSON" | sed -n 's/.*"browser_download_url": "\(https:[^"]*armv7-unknown-linux-gnueabihf\.tar\.gz\)".*/\1/p' | head -n 1)
SHA_URL=$(printf '%s\n' "$RELEASE_JSON" | sed -n 's/.*"browser_download_url": "\(https:[^"]*SHA256SUMS\)".*/\1/p' | head -n 1)
SIG_URL=$(printf '%s\n' "$RELEASE_JSON" | sed -n 's/.*"browser_download_url": "\(https:[^"]*SHA256SUMS\.sig\)".*/\1/p' | head -n 1)

if [ -z "$ARCHIVE_URL" ] || [ -z "$SHA_URL" ] || [ -z "$SIG_URL" ]; then
  echo "Failed to locate armv7 release assets in the latest GitHub release." >&2
  exit 1
fi

ARCHIVE_NAME=$(basename "$ARCHIVE_URL")
ARCHIVE_PATH="$TMP_DIR/$ARCHIVE_NAME"
SHA_PATH="$TMP_DIR/SHA256SUMS"
SIG_PATH="$TMP_DIR/SHA256SUMS.sig"
PUBKEY_PATH="$TMP_DIR/release-signing-public.pem"
CHECK_PATH="$TMP_DIR/$ARCHIVE_NAME.sha256"
STAGE_DIR="$TMP_DIR/stage"

echo "[phaeton] Downloading release package $ARCHIVE_NAME"
curl -fL "$ARCHIVE_URL" -o "$ARCHIVE_PATH"
curl -fL "$SHA_URL" -o "$SHA_PATH"
curl -fL "$SIG_URL" -o "$SIG_PATH"
curl -fL "$PUBLIC_KEY_URL" -o "$PUBKEY_PATH"

echo "[phaeton] Verifying signed checksum manifest"
openssl dgst -sha256 \
  -sigopt rsa_padding_mode:pss \
  -sigopt rsa_pss_saltlen:digest \
  -verify "$PUBKEY_PATH" \
  -signature "$SIG_PATH" \
  "$SHA_PATH" >/dev/null || {
  echo "Release checksum signature verification failed." >&2
  exit 1
}

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

# Initialize with the verified new binary before replacing any installed files.
# Reinstalling a live named instance is refused by its process lock; use that
# instance's web updater, or stop it first, then rerun this installer.
if [ -n "$INSTANCE_NAME" ]; then
  chmod 0755 "$STAGE_DIR/phaeton"
  if [ "$DEMO" = 1 ]; then
    PHAETON_DATA_DIR="$INSTALL_DIR" "$STAGE_DIR/phaeton" --init-instance "$INSTANCE_NAME" "$WEB_PORT" --demo
  else
    PHAETON_DATA_DIR="$INSTALL_DIR" "$STAGE_DIR/phaeton" --init-instance "$INSTANCE_NAME" "$WEB_PORT"
  fi
fi

rm -rf "$INSTALL_DIR/webui"
rm -f "$BINARY_TMP"
cp "$STAGE_DIR/phaeton" "$BINARY_TMP"
chmod 0755 "$BINARY_TMP"
mv "$BINARY_TMP" "$BINARY_PATH"
if [ -d "$STAGE_DIR/webui" ]; then
  cp -R "$STAGE_DIR/webui" "$INSTALL_DIR/"
fi

write_run_script
update_rc_local
start_phaeton

GX_IP=$(detect_gx_ip)
if [ -n "$GX_IP" ]; then
  WEB_UI_URL="https://$GX_IP:$WEB_PORT/"
else
  WEB_UI_URL="https://<gx-ip>:$WEB_PORT/"
fi

echo "[phaeton] Installed to $INSTALL_DIR"
echo "[phaeton] Web UI: $WEB_UI_URL"
echo "[phaeton] Open this URL in your browser: $WEB_UI_URL"
echo "[phaeton] First start serves the onboarding wizard at $WEB_UI_URL"
echo "[phaeton] Free for personal use. Commercial use requires a license from Virtunet BV."
echo "[phaeton] Autostart configured in $RC_LOCAL"
if [ -n "$INSTANCE_NAME" ]; then
  echo "[phaeton] MQTT instance: configure its Alfen charger in the wizard and activate it."
  echo "[phaeton] Auto charging requires a GX controller; qualify shared power limits before use."
else
  echo "[phaeton] Modbus server will run on alternate port 1502 automatically"
fi
