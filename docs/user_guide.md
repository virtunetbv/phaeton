# Phaeton User Guide

The hosted public guide is available at `https://phaeton.virtunet.io/docs`.
This Markdown file is kept as a public fallback for source review and release
syncs.

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
Phaeton process, normally at `https://<device-ip>:8088/`.

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

For Alfen charger-side setup and troubleshooting, start with the hosted
[Alfen settings checklist](https://phaeton.virtunet.io/docs/alfen-settings).
The same checklist is also kept as a Markdown fallback in
[alfen-settings-runbook.md](alfen-settings-runbook.md).

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
- verifies the signed `SHA256SUMS` manifest and selected release package
- installs Phaeton into `/data/phaeton`
- writes `/data/phaeton/run.sh`
- adds a managed Phaeton block to `/data/rc.local`
- starts Phaeton in the background
- prints the web UI link for the detected GX IP address when available

After installation, open the web UI link printed by the installer. If Phaeton is
not already running, start it manually:

```sh
/data/phaeton/run.sh
```

Then open:

```text
https://<gx-ip>:8088/
```

### Manual GX Install

Download the latest release assets from:

```text
https://github.com/virtunetbv/phaeton/releases
```

For most Cerbo GX installations, use:

- `phaeton-<tag>-armv7-unknown-linux-gnueabihf.tar.gz`
- `SHA256SUMS`
- `SHA256SUMS.sig`

Use `release-signing-public.pem` from the public repository as the trusted
verification key.

Verify the download:

```sh
openssl dgst -sha256 -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:digest \
  -verify release-signing-public.pem -signature SHA256SUMS.sig SHA256SUMS
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
https://<host-ip>:8088/
```

Phaeton stores writable files in the platform data directory. On Linux this is
usually `~/.local/share/phaeton`. You can override it:

```sh
PHAETON_DATA_DIR=/path/to/phaeton-data phaeton
```

## First-Run Onboarding

On a fresh install, Phaeton enters the first-run setup wizard. While the wizard
is pending, the bridge runtime is intentionally not started.

Before opening the wizard, read `<data directory>/setup-claim.json` through
local access or SSH. Before accepting the browser's generated-certificate
warning, compare its SHA-256 fingerprint with `certificate_sha256` in that
file. Enter the file's `token` value when prompted. This device-local claim
authorizes creation of the first administrator and is removed after a
successful setup. The generated certificate and private key remain under the
data directory so the device identity is stable across restarts.

The wizard asks for:

1. The device-local setup claim, admin username, and password.
2. Charger profile and optional charger connection details.
3. Optional Victron GX host and port for Auto mode data.
4. Final review.

After the wizard saves successfully:

- Phaeton redirects to the sign-in page.
- The new admin credentials are active.
- The one-time setup claim is removed.
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

For the built-in Alfen profile, also use `Test Alfen Control`. The test reads
the charger EMS diagnostics, writes the current setpoint value back to Alfen
register `1210`, and checks whether the charger reports that the setpoint is
accounted for.

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

Phaeton does not duplicate Alfen's charger-side configuration manual. Start with
the hosted
[Alfen settings checklist](https://phaeton.virtunet.io/docs/alfen-settings)
or the Markdown fallback in
[alfen-settings-runbook.md](alfen-settings-runbook.md), then use the official
Alfen Service Portal documentation for the ACE Service Installer steps:

- [Alfen Service Portal: Smart Charging functionalities, Active Load Balancing,
  and Smart Charging Network](https://aceservice.alfen.com/en-us/knowledgebase/article/KA-01167)
- In that Alfen article, look for the attached `Smart Charging Guide` and
  `Configuration Guide Modbus ACE`.
- Useful Alfen/ACE breadcrumbs: `Smart Charging` or `Load Balancing` ->
  `Active balancing` -> `Data Source: Energy Management System` -> `TCP/IP EMS`.

If `Test Alfen Control` completes but reports that the setpoint is not
accounted for, the charger is reachable but is not accepting Phaeton as an EMS
controller. Re-check the Active Load Balancing license, Data Source / EMS mode,
TCP/IP EMS socket mode, write permission for maximum currents, validity time,
and safe current.

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

On Venus OS, enable the GX Modbus-TCP service in `Settings -> Services ->
Modbus-TCP`. Phaeton reads documented GX system-service values from unit ID
`100` for PV, grid, AC consumption, battery, ESS minimum SoC, and Multi state.
If the GX test succeeds but Auto mode looks wrong, compare the dashboard values
with the GX device list before changing thresholds.

## Using The Web UI

Open:

```text
https://<phaeton-host>:8088/
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
- verify the generated certificate fingerprint from the setup claim or local logs before accepting it in a browser
- use a trusted reverse proxy with end-to-end TLS if remote access is required
- keep CORS disabled unless a specific trusted integration needs it
- restrict SSH access on the GX after installation
- back up configuration and license files securely

The browser UI uses local admin authentication after onboarding. API clients can
use HTTP Basic Auth over HTTPS when authentication is enabled.

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

- the Dashboard status reason; it should say whether Phaeton is waiting for the
  EV, charger connection, solar surplus, grid threshold, schedule, phase
  settling, or battery SoC
- setup and activation are complete; the bridge runtime does not control
  charging while the wizard or activation page is active
- Manual mode can start a charge at the EVSE minimum, usually `6 A`
- Victron GX integration is enabled and test succeeds
- PV, grid, load, and battery values appear plausible
- configured minimum current is not too high
- battery SoC rules are not blocking charging
- ESS minimum SoC limit is not blocking charging
- current mode is actually Auto
- charger status says the EV is connected
- Alfen EMS / Active Load Balancing settings allow Phaeton to write maximum
  current setpoints
- for Alfen, `Test Alfen Control` reports that the setpoint is accounted for

Recommended reproduction for support:

1. Open `Logs`.
2. Set temporary log capture to `DEBUG`.
3. Clear displayed logs.
4. Switch to Manual mode, enable charging, and set `6 A`.
5. If Manual works, switch back to Auto and wait for at least two poll cycles.
6. Select `Support bundle`.

Useful status reasons:

- `driver_not_running`: finish setup or activation first.
- `config_recovery`: repair `config.yaml` in Settings, then restart Phaeton.
- `charger_connection_lost`: fix charger IP, port, route, or Modbus settings.
- `ev_disconnected`: the charger is reachable but reports no vehicle.
- `low_soc`: battery SoC or ESS minimum SoC is blocking Auto mode.
- `scheduled_inactive`: Scheduled mode has no active Planner window.
- `auto_waiting_for_grid_threshold`: PV is available, but GX grid import/export
  has not crossed the configured start threshold.
- `auto_waiting_for_sun`: Auto mode does not have enough available PV power.

### Updates Fail

Check:

- update entitlement status in the license dialog
- internet access if using remote updates
- repository URL and token if using a private repository
- uploaded file is an official Phaeton release `*.tar.gz`
- logs for checksum, download, or unpack errors

### Config Recovery

If `config.yaml` is invalid, Phaeton starts a web-only recovery mode with safe
defaults instead of stopping completely. Charger control and the EVCS Modbus
server stay offline so default charger or GX addresses are not used for live
runtime behavior.

Open the web UI, go to `Settings`, and either save a corrected configuration,
upload a valid config file, or reset to defaults. Phaeton preserves the invalid
`config.yaml` until one of those explicit repair actions succeeds. After the
repair is saved, restart Phaeton to leave recovery mode and start the bridge
runtime normally.

### Need Logs For Support

Open `Logs` in the web UI and select `Download full log`.

On Venus OS, the default log is:

```text
/data/phaeton/phaeton.log
```

For public support requests, prefer `Support bundle`. It includes the current
status snapshot, diagnostics, and log content, but redacts paths, email
addresses, secrets, and full device identifiers. IP addresses keep only the
last octet, and serial, install, and license identifiers keep only their last
four characters so support can still correlate repeated reports.

The Logs view level selector controls what is captured in the log file. DEBUG
and TRACE are available for temporary diagnostics only; Phaeton automatically
reverts them to INFO after 15 minutes to protect GX storage.

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

## Manual updates with a signed bundle

In Software Updates, select the official `.phaeton-update` download for your device platform. It contains the release archive and its signed checksum files. Phaeton verifies the release signature, package checksum, and platform before installation and restart. Plain `.tar.gz` uploads are no longer accepted; those archives remain available for installation and automatic updates.

To wrap an older signed release, place its `phaeton-*.tar.gz`, original `SHA256SUMS`, and `SHA256SUMS.sig` in one directory. Run `bash scripts/package-signed-updates.sh <directory> <trusted-release-signing-public.pem>` using the trusted project key. Upload the resulting `.phaeton-update` file. No private signing key is needed.

## Charging current and pending configuration changes

Max set current is a ceiling for Manual, Auto, Scheduled, and external control. The lower of this setting and the station current limit wins, including during Auto grace periods. Lowering a limit takes effect on the next eligible control cycle. Auto mode stops when the station limit falls below its minimum charging current.

Changing the web address or port saves the setting but leaves the current listener active until restart. The save response and UI continue to indicate the pending restart on later saves. Reverting to the active address and port clears those warnings.

## Single-phase-only installations

For an installation that must never request three-phase charging, enable
**Settings → Installation → Single-phase only**.
The setting is saved across restarts and applies immediately in Manual, Auto,
Scheduled and external GX control. It takes precedence over saved phase choices
and automatic phase switching. Existing installations leave it disabled by default.

Phaeton holds charging at zero until fresh charger readback confirms one phase.
If the charger reports three phases, Phaeton first writes zero current, waits for
fresh stopped readings and the configured settling period, then requests and
verifies one phase. It never sends a three-phase command or probe while this
setting is enabled. A charger already reporting one phase does not need to
support phase writes.

The dashboard continues to show actual charger readback. Saving the configuration
is not confirmation of a successful hardware transition: check the status reason
and verify that the charger reports **1 phase**. Charging then follows the selected
mode, start/stop intent, schedule and battery limits. External GX control must
reacquire its lease after configuration changes.

At the default 6 A minimum, the nominal single-phase minimum is 1,380 W
(6 A × 230 V), rather than 4,140 W for three phases. Auto mode's other start
conditions still apply; this setting does not lower minimum current or bypass
battery, grid or installation limits.

If readback is missing, stale or reports three phases, charging remains blocked.
Check the charger's installation settings and supported phase controls. After an
explicit rejection or mismatch, save configuration again, reconnect the charger,
or request one phase through the existing phase API to retry. Transport failures
use bounded retries with the configured phase-switch grace period. Fresh valid
one-phase readback can clear the block without another phase write.

Disabling the setting removes the restriction without immediately requesting
three phases. Saved automatic-switching preferences become effective again.

## Using the local interface

Use **Charging** for live power, the reason charging is running or waiting, mode
selection and Start/Stop. Selecting a mode does not replace your start/stop intent.
The Manual current slider respects the installation and station limits. When GX
owns charging, its ownership is shown explicitly. When Victron GX data is available, **Where the energy comes from** shows live
Solar, Grid, Battery and Car readings, and the ribbon under them shows how much
of the current session came from solar versus the grid. Sources without a
reading are left out rather than shown as zero. Session totals follow the main
controls; expand **Electrical details** or **Charging history** for more detail.
Requested current is your preference; commanded current is what Phaeton sends.
Older samples without commanded values have gaps in that series.

Use **Schedule** to edit weekly charging windows and inspect the next window.
These windows control charging when Scheduled mode is selected.

**Settings** has four pages: Charging (autostart, solar and battery behavior),
Installation (phase restriction and electrical limits), Connections (charger and
GX), and System (timezone, pricing, access and service configuration). Technical
options are in Advanced. Search opens the matching page. Edits remain a draft
across page navigation until **Save changes** or **Discard changes**. Failed saves
retain the draft and identify the field to correct. Hidden options retain their
saved values.

For a single-phase installation, enable **Settings → Installation → Single-phase
only**, or select it during first setup. Saving applies the restriction; it does
not confirm hardware readiness. The Charging page reports stopping, stopped-proof
waiting, settling, phase confirmation, retry or rejection. An unknown or
incompatible charger phase value stays visible in diagnostics. Phaeton will not
allow current until fresh readback confirms one phase.

**System** groups Health, Logs, Updates and License. Use the diagnostics link on
a charging fault to inspect the actual charger phase and current limits. A
connection test reads the charger; Alfen control tests write a current setpoint
and are explicitly labelled. See the Alfen runbook before changing charger
installation settings. Existing dashboard/configuration URLs still open the
corresponding new pages.
