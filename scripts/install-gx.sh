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
    legacy == "" && $0 == "/data/phaeton/phaeton >> /data/phaeton/phaeton.log 2>&1 &" { next }
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

  wait_for_web_ui
}

wait_for_web_ui() {
  echo "[phaeton] Waiting for the Phaeton web interface"
  attempts=0
  while [ "$attempts" -lt 30 ]; do
    # The loopback readiness probe is not a remote trust decision. Users verify
    # the device certificate using the private handoff below.
    if is_phaeton_running; then
      status=$(curl --silent --insecure --noproxy '*' --max-time 2 \
        --output /dev/null --write-out '%{http_code}' \
        "https://127.0.0.1:$WEB_PORT/" 2>/dev/null || true)
      case "$status" in
        200|302|303|307) return 0 ;;
      esac
    fi
    attempts=$((attempts + 1))
    sleep 1
  done
  echo "[phaeton] The web interface did not become ready; installation is not complete." >&2
  echo "[phaeton] Check $INSTALL_DIR/phaeton.log and whether port $WEB_PORT is in use." >&2
  echo "[phaeton] After resolving the error, run $INSTALL_DIR/run.sh if Phaeton is stopped." >&2
  return 1
}

download_file() {
  if ! curl -fL --connect-timeout 15 --max-time 300 --retry 2 "$1" -o "$2"; then
    echo "[phaeton] Download failed. Check internet access on the GX, then rerun the installation command." >&2
    return 1
  fi
}

check_install_prerequisites() {
  for tool in curl openssl sha256sum tar awk sed grep mktemp readlink df du; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "[phaeton] Required tool is missing: $tool. Use a supported Venus OS installation." >&2
      return 1
    fi
  done
  if [ -f "$RC_LOCAL.disabled" ]; then
    echo "[phaeton] A disabled startup file exists: $RC_LOCAL.disabled" >&2
    echo "[phaeton] Enable General > Modification checks > Modifications enabled first." >&2
    echo "[phaeton] Restore the disabled file to $RC_LOCAL before retrying; if both files exist, merge their commands with administrator help." >&2
    return 1
  fi
  echo "[phaeton] Keep General > Modification checks > Modifications enabled on for startup."
}

check_free_space() {
  available=$(df -Pk "$1" | awk 'END {print $4}')
  case "$available" in
    ''|*[!0-9]*) echo "[phaeton] Unable to check free space in $1." >&2; return 1 ;;
  esac
  if [ "$available" -lt "$2" ]; then
    echo "[phaeton] Not enough free space in $1: need at least $2 KiB. Free space before retrying." >&2
    return 1
  fi
}

check_web_port() {
  port_hex=$(printf '%04X' "$WEB_PORT")
  for sockets in /proc/net/tcp /proc/net/tcp6; do
    [ -r "$sockets" ] || continue
    if awk -v port=":$port_hex" '$2 ~ (port "$") && $4 == "0A" {found=1} END {exit !found}' "$sockets"; then
      echo "[phaeton] Web port $WEB_PORT is already in use. Resolve the conflict before installing Phaeton." >&2
      return 1
    fi
  done
}

print_setup_handoff() {
  GX_IP=$(detect_gx_ip)
  WEB_UI_URL="https://${GX_IP:-<gx-ip>}:$WEB_PORT/"
  echo "[phaeton] Open Phaeton: $WEB_UI_URL"
  if [ ! -f "$INSTALL_DIR/setup-claim.json" ]; then
    fingerprint=$(openssl x509 -inform DER -in "$INSTALL_DIR/tls/certificate.der" -noout -sha256 -fingerprint) || return 1
    printf 'Certificate SHA-256: %s\n' "${fingerprint#*=}"
    echo "[phaeton] Compare this fingerprint with the browser certificate before continuing."
    echo "[phaeton] On first visit, choose your administrator username and password; no setup code is required."
    echo "[phaeton] If setup is already complete, sign in with your existing local Phaeton account."
    unset fingerprint
    return 0
  fi
  # Never include the private claim in redirected output or installation logs.
  if [ ! -t 1 ]; then
    echo "[phaeton] In your private GX terminal, run: cat $INSTALL_DIR/setup-claim.json"
    echo "[phaeton] Use token as the Setup code and certificate_sha256 to verify the browser certificate."
    return 0
  fi
  claim=$(sed -n 's/.*"token"[[:space:]]*:[[:space:]]*"\([A-Za-z0-9_-]\{43\}\)".*/\1/p' "$INSTALL_DIR/setup-claim.json")
  fingerprint=$(sed -n 's/.*"certificate_sha256"[[:space:]]*:[[:space:]]*"\([A-Fa-f0-9:]*\)".*/\1/p' "$INSTALL_DIR/setup-claim.json")
  if [ -z "$claim" ] || [ -z "$fingerprint" ]; then
    echo "[phaeton] Setup details are not ready. Read $INSTALL_DIR/setup-claim.json in this terminal before opening the wizard." >&2
    return 1
  fi
  printf '\nSetup code (private, one-time): %s\nCertificate SHA-256: %s\n\n' "$claim" "$fingerprint"
  echo "[phaeton] Compare this fingerprint with the browser certificate before continuing."
  echo "[phaeton] Enter the Setup code in the wizard, then choose your local account. Do not share this code."
  unset claim fingerprint
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

check_install_prerequisites

# A rerun must not replace an executable while its old process keeps running.
if is_phaeton_running; then
  echo "[phaeton] Phaeton is already running. Use its Software Updates screen; no files were replaced."
  print_setup_handoff
  exit 0
fi
check_web_port

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
check_free_space "$TMP_DIR" 65536
check_free_space "$INSTALL_DIR" 32768

echo "[phaeton] Querying latest public GitHub release"
download_file "$GITHUB_API_URL/releases/latest" "$TMP_DIR/release.json"
RELEASE_JSON=$(cat "$TMP_DIR/release.json")
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
download_file "$ARCHIVE_URL" "$ARCHIVE_PATH"
download_file "$SHA_URL" "$SHA_PATH"
download_file "$SIG_URL" "$SIG_PATH"
download_file "$PUBLIC_KEY_URL" "$PUBKEY_PATH"

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
staged_kib=$(du -sk "$STAGE_DIR" | awk '{print $1}')
check_free_space "$INSTALL_DIR" "$((staged_kib + 8192))"
if is_phaeton_running; then
  echo "[phaeton] Phaeton started while the installer was downloading. Use Software Updates; no installed files were replaced." >&2
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

echo "[phaeton] Phaeton is installed and its web interface is ready."
print_setup_handoff
echo "[phaeton] Complete setup and activation in your browser. Installation does not start a charging test."
echo "[phaeton] Autostart configured in $RC_LOCAL"
if [ -n "$INSTANCE_NAME" ]; then
  echo "[phaeton] MQTT instance: configure its Alfen charger in the wizard and activate it."
  echo "[phaeton] Auto charging requires a GX controller; qualify shared power limits before use."
else
  echo "[phaeton] Modbus server will run on alternate port 1502 automatically"
fi
