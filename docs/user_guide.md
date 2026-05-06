# Phaeton User Guide

This is the public user guide for installing, activating, configuring, operating,
updating, backing up, and troubleshooting Phaeton.

Phaeton is a Victron EVCS protocol bridge. It reads a supported physical EV
charger over Modbus TCP and exposes that charger to a Victron GX device as a
Victron-compatible EV Charging Station.

## Contents

- [What Phaeton Does](#what-phaeton-does)
- [Before You Start](#before-you-start)
- [Supported Chargers](#supported-chargers)
- [Install On Victron GX](#install-on-victron-gx)
- [Install On Other Linux Systems](#install-on-other-linux-systems)
- [First-Run Onboarding](#first-run-onboarding)
- [Activation And Licensing](#activation-and-licensing)
- [Configure The Charger](#configure-the-charger)
- [Configure Victron GX Integration](#configure-victron-gx-integration)
- [Using The Web UI](#using-the-web-ui)
- [Charging Modes](#charging-modes)
- [Updates](#updates)
- [Backup And Restore](#backup-and-restore)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Support Information](#support-information)

## What Phaeton Does

Phaeton sits between three systems:

```text
EV charger <-- Modbus TCP --> Phaeton <-- Victron EVCS Modbus TCP --> Victron GX
                                      |
                                      +-- Web UI and local API
```

Phaeton:

- reads live charger data from the physical EV charger
- translates charger-specific registers into Victron EVCS-compatible registers
- exposes the charger to Victron GX and VRM as an EV Charging Station
- provides a local web UI for setup, control, schedules, updates, and logs
- can read Victron GX system data for PV-aware Auto mode

The bridge runtime stays local to your installation. The web UI is served by the
Phaeton process, normally at `http://<device-ip>:8088/`.

## Before You Start

You need:

- a supported EV charger with Modbus TCP enabled
- the charger IP address or hostname
- the charger Modbus TCP port, usually `502`
- a Victron GX device on the same network, such as Cerbo GX or Ekrano GX
- SSH access if installing directly on Venus OS
- a Phaeton release package for your platform

Recommended network layout:

- keep the GX, charger, and Phaeton on a trusted local network
- avoid exposing Phaeton directly to the public internet
- allow TCP access from Phaeton to the charger Modbus port
- allow TCP access from the GX to Phaeton's EVCS Modbus server port
- allow browser access to Phaeton's web UI port, default `8088`

## Supported Chargers

Current built-in charger profile:

| Charger | Profile ID | Notes |
| --- | --- | --- |
| Alfen Eve Pro-line / Single Pro-line | `alfen-eve` | Default built-in profile |

Additional chargers can be supported by adding charger definitions or custom
charger profiles. The web UI includes a charger profile editor for advanced
users who need to clone a built-in profile and adjust registers.

## Install On Victron GX

These steps are intended for Cerbo GX and other GX devices running Venus OS.
Venus OS keeps writable data under `/data`, so Phaeton installs to
`/data/phaeton`.

### Enable SSH And Third-Party Startup

On the GX device:

1. Open `Settings -> General`.
2. Raise the access level to `Superuser`.
3. Set a temporary root password.
4. Enable `SSH on LAN`.
5. Open `Settings -> General -> Modification checks`.
6. Make sure `Modifications enabled` is enabled.

`/data/rc.local` only runs at startup when modifications are enabled.

### Fast Install

From your workstation:

```sh
ssh root@<gx-ip> 'curl -fsSL https://raw.githubusercontent.com/virtunetbv/phaeton/main/scripts/install-gx.sh | sh'
```

Or, from a GX shell:

```sh
curl -fsSL https://raw.githubusercontent.com/virtunetbv/phaeton/main/scripts/install-gx.sh | sh
```

The installer:

- downloads the latest stable public GitHub release
- verifies the release package against `SHA256SUMS`
- installs Phaeton into `/data/phaeton`
- writes `/data/phaeton/run.sh`
- adds a managed Phaeton block to `/data/rc.local`

After installation, start Phaeton:

```sh
/data/phaeton/run.sh
```

Then open:

```text
http://<gx-ip>:8088/
```

### Manual GX Install

Download the latest release assets from:

```text
https://github.com/virtunetbv/phaeton/releases
```

For most Cerbo GX installations, use:

- `phaeton-<tag>-armv7-unknown-linux-gnueabihf.tar.gz`
- `SHA256SUMS`

Verify the download:

```sh
sha256sum -c SHA256SUMS
```

Copy and extract:

```sh
scp phaeton-<tag>-armv7-unknown-linux-gnueabihf.tar.gz root@<gx-ip>:/data/
ssh root@<gx-ip>
mkdir -p /data/phaeton
tar -xzf /data/phaeton-<tag>-armv7-unknown-linux-gnueabihf.tar.gz -C /data/phaeton
chmod +x /data/phaeton/phaeton
```

Create a startup wrapper:

```sh
cat >/data/phaeton/run.sh <<'EOF'
#!/bin/sh
set -e
export PHAETON_DATA_DIR=/data/phaeton
export RUST_LOG=info
exec /data/phaeton/phaeton
EOF
chmod +x /data/phaeton/run.sh
```

Start manually:

```sh
/data/phaeton/run.sh
```

To start at boot, add Phaeton to `/data/rc.local`:

```sh
cat >/data/rc.local <<'EOF'
#!/bin/sh
/data/phaeton/run.sh &
exit 0
EOF
chmod +x /data/rc.local
```

## Install On Other Linux Systems

Choose the release package matching your platform:

| Platform | Artifact suffix |
| --- | --- |
| Raspberry Pi Zero / Pi 1, ARMv6 32-bit Linux | `arm-unknown-linux-gnueabihf` |
| Raspberry Pi 2 / 3 / 4, ARMv7 32-bit Linux | `armv7-unknown-linux-gnueabihf` |
| Raspberry Pi 3 / 4 / 5, ARM64 Linux | `aarch64-unknown-linux-gnu` |
| Linux AMD64 / x86_64 | `x86_64-unknown-linux-gnu` |

Install:

```sh
mkdir -p phaeton-extract
tar -xzf phaeton-<tag>-<artifact>.tar.gz -C phaeton-extract
sudo install -m 0755 phaeton-extract/phaeton /usr/local/bin/phaeton
```

Run:

```sh
phaeton
```

Open:

```text
http://<host-ip>:8088/
```

Phaeton stores writable files in the platform data directory. On Linux this is
usually `~/.local/share/phaeton`. You can override it:

```sh
PHAETON_DATA_DIR=/path/to/phaeton-data phaeton
```

## First-Run Onboarding

On a fresh install, Phaeton enters the first-run setup wizard. While the wizard
is pending, the bridge runtime is intentionally not started.

The wizard asks for:

1. Admin username and password.
2. Charger profile and optional charger connection details.
3. Optional Victron GX host and port for Auto mode data.
4. Final review.

After the wizard saves successfully:

- Phaeton redirects to the sign-in page.
- The new admin credentials are active.
- `config.yaml` is written to the data directory.
- A restart may be required before all bridge services are active.

If an older install still uses the retired default password, Phaeton also enters
the wizard so you can choose a real password.

## Activation And Licensing

Phaeton requires activation before the bridge runtime is available.

License types:

- Personal use is free under the EULA.
- Commercial use requires a commercial license from Virtunet BV.
- If an installer or distributor provided Phaeton, commercial use is permitted
  only when that party is authorized by Virtunet BV.

### Online Activation

Use online activation when the Phaeton device can reach the licensing portal.

1. Open the Phaeton web UI.
2. If activation is required, the activation page is shown automatically.
3. Select `Activate online`.
4. Open the portal link.
5. Sign in with the correct account.
6. Approve the installation.
7. Return to Phaeton and wait for the license to install.

The portal decides the license type from the signed-in account. Home accounts
receive a personal license. Partner or commercial accounts receive a commercial
license.

### Offline Activation

Use offline activation when the Phaeton device cannot reach the internet.

1. Open the activation page.
2. Expand `Activate offline`.
3. Download `license-request.json`.
4. Move that file to a computer that can reach the licensing portal.
5. Obtain the signed `license.json`.
6. Return to the Phaeton activation page.
7. Upload `license.json`.

The license is bound to the local installation. Do not reuse it on another
device.

### License Status

The main UI shows a license chip in the top bar. Select it to view:

- current license status
- license tier
- update entitlement status
- install ID
- last validation error, if any

If the license is invalid or missing, Phaeton returns to activation mode.

## Configure The Charger

Open `Configuration -> Charger`.

Set:

- charger profile
- charger IP address
- charger connection settings
- station limits if needed

For the default Alfen profile, use `alfen-eve`.

### Test The Charger Connection

Use the charger connection test before saving. If it fails:

- confirm the charger IP address
- confirm Modbus TCP is enabled on the charger
- confirm the Modbus port, usually `502`
- confirm the charger and Phaeton are on the same network
- check firewall rules between Phaeton and the charger

### Charger Profiles

Built-in profiles are read-only. To change registers:

1. Select the built-in profile.
2. Create a custom profile from it.
3. Edit the custom profile.
4. Save the configuration.

A profile defines:

- default charger Modbus port
- Modbus slave IDs
- datapoint addresses
- register counts
- value types
- optional scaling
- raw charger status mapping

Required datapoints include:

- `voltage_l1`, `voltage_l2`, `voltage_l3`
- `current_l1`, `current_l2`, `current_l3`
- `power_l1`, `power_l2`, `power_l3`
- `energy`
- `status`
- `amps_config`
- `phases`
- `firmware_version`
- `station_serial`
- `manufacturer`

Use the per-datapoint test buttons to verify raw and decoded values before
relying on a custom profile.

### Alfen Notes

For Alfen chargers, confirm:

- the charger has network connectivity
- Modbus TCP is enabled
- EMS or load balancing support is enabled where required
- the configured charger profile is `alfen-eve`
- the charger firmware exposes the expected Modbus registers

## Configure Victron GX Integration

Phaeton has two Victron-facing roles:

- EVCS server: exposes Phaeton as a Victron-compatible EV Charging Station.
- GX data client: reads PV, grid, load, and battery data for Auto mode.

On Venus OS, Phaeton applies platform defaults so the GX can discover it. The
EVCS server uses an alternate port such as `1502` to avoid conflicts with the
GX built-in Modbus service.

For non-GX installs:

1. Run Phaeton on a reachable host.
2. Enable the Phaeton Modbus EVCS server.
3. Configure the GX to connect to Phaeton's host and EVCS server port.
4. Confirm the EV Charging Station appears in the GX device list.

For Auto mode data:

1. Open the first-run wizard or `Configuration -> Victron GX`.
2. Enable Victron GX integration.
3. Set the GX host or IP.
4. Set the GX Modbus TCP port, usually `502`.
5. Use the test button to confirm live data.

## Using The Web UI

Open:

```text
http://<phaeton-host>:8088/
```

Main areas:

- Dashboard: live state and charging controls
- Planner: scheduled charging windows
- Configuration: charger, Victron GX, controls, web, logging, and updates
- Updates: install local packages or remote releases
- Logs: inspect and download logs
- License chip: inspect license status

The UI supports light and dark mode. The selected theme is stored in the
browser.

## Charging Modes

### Manual

Manual mode lets the operator start or stop charging and set the current
directly from the dashboard.

Use Manual when:

- you want immediate control
- you are testing charger communication
- you do not want automatic PV or schedule decisions

### Auto

Auto mode uses charger data and Victron GX system data to make PV-aware charging
decisions.

Auto mode can use:

- PV power
- AC load
- grid import/export
- battery state of charge
- ESS minimum SoC limit
- configured minimum and maximum current
- phase switching settings

Auto mode depends on reliable GX data. If the GX integration is disabled or not
reachable, Auto mode has less information and may stop or avoid charging
depending on configuration.

### Scheduled

Scheduled mode follows active time windows from the Planner view.

Use Scheduled when:

- charging should only be allowed during specific times
- the site uses external tariff or availability windows
- an operator wants predictable time-based behavior

Schedules can include day selections, start time, end time, active state, and
optional current limits.

## Updates

Open `Updates`.

Two update paths are available:

- Local package update: upload an official `*.tar.gz` release package.
- Release repository update: check and apply a release from the configured
  repository.

By default, a blank update repository means Phaeton uses the built-in public
GitHub release channel. Public GitHub releases do not need an access token.

Only set `updates.repository` when you need a private GitHub or GitLab release
source. Only set `updates.access_token` when that private repository requires
authentication.

Updates preserve the data directory:

- `config.yaml`
- `state.json`
- `phaeton.log`
- license files

Always keep a backup before updating production installations.

## Backup And Restore

Important files live in the data directory.

On Venus OS:

```text
/data/phaeton
```

Common files:

- `config.yaml`: main configuration
- `state.json`: runtime state
- `phaeton.log`: log file when no custom log path is configured
- `license/install-state.json`: local installation identity
- `license/license.json`: signed local license

Create a backup:

```sh
tar -czf phaeton-backup-$(date +%Y%m%d).tar.gz -C /data phaeton
```

Restore to the same device:

```sh
mkdir -p /data/phaeton
tar -xzf phaeton-backup-<date>.tar.gz -C /data
```

Do not copy license files to another device and expect them to work. Licenses
are bound to the installation identity and device fingerprint.

## Security

Recommended security practices:

- complete the first-run wizard before exposing the UI to other users
- use a unique admin password
- keep Phaeton on a trusted local network
- do not expose port `8088` directly to the internet
- use a trusted reverse proxy with TLS if remote access is required
- keep CORS disabled unless a specific trusted integration needs it
- restrict SSH access on the GX after installation
- back up configuration and license files securely

The browser UI uses local admin authentication after onboarding. API clients can
use HTTP Basic Auth when authentication is enabled.

## Troubleshooting

### The Public User Guide Link Returns 404

The public GitHub repository is populated by a release sync job. If the guide is
missing on GitHub, the release sync has not run with the current documentation
manifest yet. Use the latest public release branch after the next sync, or ask
support for the current guide.

### Cannot Reach The Web UI

Check:

- Phaeton is running
- the device IP address is correct
- port `8088` is reachable
- local firewall rules allow access
- on Venus OS, `/data/rc.local` exists and modifications are enabled

Useful commands on GX:

```sh
ps | grep phaeton
tail -n 100 /data/phaeton/phaeton.log
```

### The Wizard Appears Again

The wizard appears when setup is required. This can happen on a fresh install or
when an old install still uses the retired default password. Complete the wizard
with a unique admin password.

### Activation Page Appears

Phaeton is not currently licensed, or the local license failed validation. Use
online activation if the device has internet access. Use offline activation if
the device is isolated.

### Charger Does Not Connect

Check:

- charger IP address
- charger Modbus TCP setting
- charger port
- selected charger profile
- network route from Phaeton to the charger
- charger vendor settings for EMS, load balancing, or external control
- Phaeton logs

### GX Does Not See Phaeton As An EVCS

Check:

- Phaeton bridge runtime is running
- setup and activation are complete
- Phaeton EVCS Modbus server is enabled
- the GX can reach Phaeton's EVCS Modbus server port
- on Venus OS, D-Bus discovery has had time to update
- no other service is using the same Modbus TCP port

### Auto Mode Does Not Start Charging

Check:

- Victron GX integration is enabled and test succeeds
- PV, grid, load, and battery values appear plausible
- configured minimum current is not too high
- battery SoC rules are not blocking charging
- ESS minimum SoC limit is not blocking charging
- current mode is actually Auto
- charger status says the EV is connected

### Updates Fail

Check:

- update entitlement status in the license dialog
- internet access if using remote updates
- repository URL and token if using a private repository
- uploaded file is an official Phaeton release `*.tar.gz`
- logs for checksum, download, or unpack errors

### Need Logs For Support

Open `Logs` in the web UI and download the log file.

On Venus OS, the default log is:

```text
/data/phaeton/phaeton.log
```

## Support Information

When asking for help, include:

- Phaeton version
- platform, for example Cerbo GX or Raspberry Pi
- charger model and firmware version
- selected charger profile
- whether setup and activation are complete
- whether the charger connection test succeeds
- whether the GX data test succeeds
- relevant log excerpt
- install ID from the license dialog, if the issue is licensing related

Commercial licensing questions: `info@virtunet.io`

Public releases:

```text
https://github.com/virtunetbv/phaeton/releases
```
