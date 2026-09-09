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
- [Install on Victron GX](#install-on-victron-gx)
- [Install On Other Linux Systems](#install-on-other-linux-systems)
- [Open Phaeton Through VRM Control Panel](#open-phaeton-through-vrm-control-panel)
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
- physical access to the GX and an empty USB stick for the recommended USB installation
- a computer with internet to download the USB installer, on the same local network as the GX for setup
- SSH access and GX internet access only if choosing the advanced SSH installation

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

## Install on Victron GX

The [guided GX installation](https://phaeton.virtunet.io/install) is available in
English and Dutch. **USB installation is recommended**: no SSH, terminal commands
or setup code are needed. The USB installer is for 32-bit ARMv7 Venus OS,
including Cerbo GX. The GX does not need internet during installation.

### Install from a USB stick

1. **Download.** Open the guided installation and select **Download GX USB
   installer**. Keep the file named `venus-data-phaeton-VERSION-armv7.tgz`
   unopened. Do not extract or rename it, and do not use a `.phaeton-update`
   bundle for USB installation.
2. **Copy.** Use a dedicated empty, writable FAT32 stick with an MBR partition
   table and at least 256 MB free. Formatting erases its contents; save anything
   you want to keep first. Copy the unopened installer directly onto the drive,
   outside any folder, then eject it from your computer. Do not use a GX logging
   stick. The [USB guide](gx-usb-installation.md) includes Windows/macOS/Linux help.
3. **Restart the GX.** Keep **Settings → General → Modification checks →
   Modifications enabled** on. Disconnect other removable storage, insert the
   stick in a USB data port. Do not use a GX Touch power-only port. Restart when
   it will not interrupt charging or other essential work. Allow five minutes
   for startup and wait for USB activity to stop. Do not remove busy media or
   interrupt GX power. If safe removal is uncertain, leave the stick inserted and
   contact support; browser setup can continue with it present.
4. **Finish in your browser.** Find the GX IP address in its Ethernet or Wi-Fi
   settings and open `https://GX-IP:8088/` on the same trusted local network.
   Choose your administrator username and password, configure the charger and
   GX connection, then activate from Phaeton. Follow [First-Run Onboarding](#first-run-onboarding).
   No setup code is required. The portal account used for activation is separate
   from your local Phaeton login.

If your browser shows a certificate warning, safely return the stick to your
computer and open `PHAETON-RESULT.html` to compare its public SHA-256 fingerprint
with the browser certificate before entering credentials. Stop if they differ.
The result is also useful for [installation troubleshooting](gx-usb-installation.md#recovery--herstel);
it contains no setup password or code.

If your GX has separately prepared VRM management access, you can open the
setup page through [VRM Control Panel](#open-phaeton-through-vrm-control-panel).
USB installation itself does not enable that remote route.

If the guide reports that the USB download is unavailable, return later or use
the advanced SSH instructions below. Older public releases may not contain a
USB installer; their normal `.tar.gz` archives cannot be used as USB installers.

An offline GX can exchange activation request and license files using a computer
with internet. Check the dashboard and connections before starting a charging test.
For an existing installation, open Phaeton and use **Software Updates**, including
uploading a `.phaeton-update` bundle for offline updates. The USB installer
preserves existing installations and does not update them.

### Advanced installation with SSH

Use SSH if you cannot use a USB stick or prefer a terminal. The online installer
downloads and verifies the software for you; no additional account is needed.

<details>
<summary>Open the six-step SSH installation instructions</summary>

#### 1. Check what you need

Use a computer on the same local network as the GX. The GX needs internet access
for the online installer. Remote Console through VRM alone does not provide an
SSH route from your computer. Check the preparation instructions for your charger.
The installer reserves at least 64 MiB of free staging space in `/tmp` and
32 MiB in `/data`, then checks the extracted package size before installation.

#### 2. Prepare your GX

Use the GX display, or sign in to Victron VRM, open your installation and choose
Remote Console. If you already know the GX IP address, open it in your browser
on the local network. Find its local IP address under
**Settings → Ethernet**, or **Settings → Wi-Fi → your connected network**.

- **New UI / touchscreen:** open **Settings → General → Access & Security**,
  set Access level to **User and installer** (access-level password `ZZZ`), then
  pull the menu list down and hold it for five seconds until **Superuser** appears.
- **Classic UI:** open **Settings → General**, set **User and installer**
  (password `ZZZ`), return to General and highlight Access level without opening
  it. Hold the keyboard's right arrow until **Superuser** appears. Holding the
  on-screen arrow with the mouse does not work.

Set your own temporary root password, enable **SSH on LAN**, then make sure
**General → Modification checks → Modifications enabled** is on. `ZZZ` is not
that SSH password. If the access-level password was changed, ask your installer.
Firmware updates reset the temporary root password. Menu
labels vary; use the [Victron root-access guide](https://www.victronenergy.com/live/ccgx:root_access)
if your screen differs. Current Venus versions do not require Remote Support
for local SSH.

#### 3. Connect from your computer

Open **PowerShell / Terminal** from the Windows Start menu, **Terminal** using
Spotlight on macOS, or your terminal application on Linux. Replace `<gx-ip>` with
the address you found and run this on your computer:

```sh
ssh root@<gx-ip>
```

SSH may ask you to confirm its host key on first connection. Verify you are
connecting to your GX; investigate an unexpected changed-key warning. Enter the
temporary root password. Password characters are invisible while typing.
When the prompt starts with `root@`, you are connected. Keep this terminal open.

If the connection is refused, check SSH on LAN. For a timeout, check the address,
local network and any guest Wi-Fi/VPN isolation. For permission denied, check
the temporary root password. If Windows cannot find `ssh`, enable its
**OpenSSH Client** optional feature and reopen PowerShell.

#### 4. Install Phaeton in the GX terminal

Paste this entire command at the GX `root@` prompt:

```sh
(installer=$(mktemp) && trap 'rm -f "$installer"' EXIT && curl -fL --connect-timeout 15 --max-time 120 https://phaeton.virtunet.io/install/gx.sh -o "$installer" && sh "$installer")
```

The first-party URL redirects to the curated public installer. If the Phaeton
website is unavailable, use the same command with
`https://phaeton.virtunet.io/install/gx.sh`
as the download URL. The script is downloaded completely before execution.

The installer checks the device and tools, downloads and verifies the signed
stable release, installs to `/data/phaeton`, writes `run.sh`, preserves other
commands while adding its managed block to `/data/rc.local`, and waits for the
web interface. No charging test is started. If a disabled startup file exists,
restore it only after enabling modifications; if both startup files exist, ask
an administrator to merge their commands instead of overwriting either one.

For multiple chargers, use [named MQTT instances](multiple-chargers.md); those
have their own web ports, data directories and activations.

#### 5. Open Phaeton

Use the HTTPS address printed by the installer, normally
`https://<gx-ip>:8088/`. Compare the browser certificate's SHA-256 fingerprint
with the installer output before entering credentials. On first visit, choose
an administrator username and password directly; no setup code is required.
If setup is already complete, sign in with your existing local account. Named
instances have their own web address and account.

#### 6. Finish setup and activation

Follow [First-Run Onboarding](#first-run-onboarding), then complete activation
from the local Phaeton interface. The local account is separate from both the GX
root password and your portal account. Verify the charger and GX connection and
follow any restart prompt before relying on charging control.

Future updates use **Software Updates** in Phaeton. A running installation is
left intact when the installer is rerun. After setup works, SSH on LAN can be
turned off if no longer needed; keep **Modifications enabled** on for autostart.

If the installer reports a download error, check GX internet access and retry.
If the web interface is not ready, inspect `/data/phaeton/phaeton.log` and the
web port before retrying. Start `/data/phaeton/run.sh` only if Phaeton is stopped.
The installer reporting that files were installed is not proof of charging
readiness; verify the dashboard and charger configuration separately.

</details>

### Manual GX install

<details>
<summary>Advanced package verification and startup configuration</summary>

Download the latest release assets from:

```text
https://downloads.phaeton.virtunet.io/
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

For autostart, prefer the managed installer. If maintaining a manual install,
back up `/data/rc.local` and edit it to add `/data/phaeton/run.sh &` before its
existing `exit 0`. Keep all other startup commands and mark the file executable.
Do not overwrite the entire file. Modifications must be enabled in the GX menu.

</details>

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

## Open Phaeton Through VRM Control Panel

Phaeton 0.59.0 adds automatic Control Panel management for fresh GX USB/SSH
installations and existing named MQTT instances. Open **VRM → Device list →
Phaeton EV Charging Station → Control Panel** to reach setup or sign-in remotely.
Existing default Modbus installations keep their current registration and are
not automatically migrated. Releases through 0.58.4 require the separately
prepared trial route.

### Configure the GX for Control Panel

Use the GX display or Remote Console. The newer UI uses **Settings → VRM**;
older menus call it **Settings → VRM online portal**.

| Where | What to configure or check |
| --- | --- |
| **Settings → Connectivity → Ethernet / Wi-Fi** (older UI: **Settings → Ethernet / Wi-Fi**) | Connect the GX to the internet. USB installation can be offline; remote access needs internet. |
| **Settings → VRM → VRM Portal** | Select **Full** if the owner wants remote configuration. |
| **Settings → VRM → Last contact** | Confirm recent successful contact and that the GX belongs to the intended VRM installation. |
| **Settings → General → Modification checks → Modifications enabled** | Keep enabled for Phaeton startup after reboot. |
| VRM installation permissions | The account opening Control Panel must be allowed to change settings. |

Phaeton uses the GX's local MQTT services. Enabling **MQTT Access** on the LAN or
pairing a network device does not create its web route. Keep the existing local
network security profile. Control Panel does not require router port forwarding,
Remote Support or SSH on LAN. Phaeton manages its own nginx include and proxy;
GX retains ownership of the remote tunnel and access settings.

### Open the installation

1. Complete the GX settings above and allow the device list to refresh after
   Phaeton starts. The initial registration waits 17 seconds.
2. Select the intended Phaeton EV Charging Station and **Control Panel** in VRM.
   During setup its name is **Phaeton - setup / activation**; the same identity
   becomes **Phaeton EVCS** after authorized restart. **Remote Console** opens GX.
3. Create your administrator account or sign in to Phaeton. No setup code is
   required. VRM access does not replace the Phaeton login or licensing account.
4. Follow setup, activation and restart prompts. Remote visibility does not
   authorize charging: the process remains inhibited until an authorized restart.

The supervised Cerbo GX trial on Venus `v3.80~39` established remote setup,
login/logout and activation-page access. The new automatic lifecycle, completed
activation, licensed dashboard and updates still require GX/VRM qualification.
Use local HTTPS for commissioning while that verification remains outstanding.

### If Control Panel is missing or opens the wrong page

Check the deployment/version, GX connectivity, VRM Full mode and account
permissions. On 0.59.0, inspect `--control-panel status` and the Phaeton logs;
allow a 30-second reconciliation interval after GX regenerates its routes.
Continue locally at `https://GX-IP:8088/`, or the named instance's assigned port.
The USB result's certificate fingerprint belongs to this local HTTPS service;
the VRM relay presents its own certificate.

See [GX Control Panel setup, disable/removal and troubleshooting](gx-control-panel.md)
for supported layouts, commands and ownership details, and Victron's
[VRM connectivity instructions](https://www.victronenergy.com/media/pg/Cerbo_GX/en/vrm-portal.html).

## First-Run Onboarding

On a fresh install, Phaeton enters the first-run setup wizard. While the wizard
is pending, the bridge runtime is intentionally not started.

Open `https://<host>:8088/`, or use the
[VRM Control Panel route](#open-phaeton-through-vrm-control-panel),
and choose the administrator username and password.
No setup code, local file retrieval or SSH access is required. Complete initial
setup on a trusted network: the first person to finish it creates the account.
The generated certificate and private key remain under the data directory so
the device identity is stable across restarts. Its public SHA-256 fingerprint
is available in the USB installation result or local logs for comparison with
the browser certificate when connecting locally.

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

Physical charging requires activation with a valid license. The free zero-power
demo is simulated and runs without activation.

License types:

- Each physical charger needs its own perpetual home or commercial license, with
  no subscription.
- A home license covers private household use. A commercial license covers use by
  a business or organization.
- New home licenses are paid. Existing issued free licenses remain permanent;
  only eligible existing accounts can still claim a free license within the
  deadline shown in the portal.
- Approved installers may activate customer-owned home or commercial licenses
  with the customer's authority.

See [license pricing](https://phaeton.virtunet.io/pricing) and the
[EULA](../EULA.md) for the available offers and terms.

### Online Activation

Use online activation when the Phaeton device can reach the licensing portal.

1. Open the Phaeton web UI.
2. If activation is required, the activation page is shown automatically.
3. Select `Activate online`.
4. Open the portal link.
5. Sign in with the correct account.
6. Select the intended license and approve the installation. If you need a
   license, open the portal's pricing page; eligible free claims appear in your
   license overview.
7. Return to Phaeton and wait for the license to install.

Choose a license you own or are authorized to manage. The selected license
determines the home or commercial use rights, including when an approved installer
activates it for a customer.

### Offline Activation

Use offline activation when the Phaeton device cannot reach the internet.

1. Open the activation page.
2. Expand `Activate offline`.
3. Download `license-request.json`.
4. Move that file to a computer that can reach the licensing portal.
5. Select a license you own or are authorized to manage, then sign the request to
   obtain `license.json`.
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

Open `Settings -> Charger & installation`.

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

For the Alfen integration, also use `Test Alfen Control`. The test reads
the charger EMS diagnostics, writes the current setpoint value back to Alfen
register `1210`, and checks whether the charger reports that the setpoint is
accounted for.

### Charger Integrations

Select Alfen, go-e, Peblar, KEBA or WARP under Charger & installation. Each named
adapter owns its manufacturer's control behavior. Setup instructions and scope:
[go-e](go-e.md), [Peblar](peblar.md), [KEBA](keba.md), [WARP](warp.md).
The new KEBA and WARP adapters support current limits, pause/resume and telemetry;
phase switching and RFID authorization remain in the charger.

Custom Modbus profiles and arbitrary register tests were removed in v0.57.0.
Existing standard Alfen configurations migrate automatically. If an old file
contains custom mappings or a runtime Alfen YAML override, remove it and select a
supported integration; Phaeton will report the unsupported configuration rather
than execute or silently translate those mappings. For Alfen, configure the IP,
TCP port and socket ID (1 or 2); the register map and station ID are fixed.

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

1. Open the first-run wizard or `Settings -> Victron GX -> Solar & battery readings`.
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

- Charging: live state and charging controls
- Schedule: scheduled charging windows
- Settings: Charging, Charger & installation, Victron GX, and System
- System: health, diagnostics, updates and logs
- License chip: inspect license status

The UI supports light, dark and automatic themes. The selected theme is stored in
the browser; automatic follows the device's color preference.

### Settings and charging ownership

Settings has a section navigation on desktop and a section selector on phones.
Every section edits the same draft. Nothing is saved until **Apply changes** is
selected. **Discard** restores the last loaded configuration. The draft bar appears
only while changes exist; failed saves keep the draft. Changes saved elsewhere,
such as Schedule edits, are preserved unless they conflict with the same setting.
Conflicting changes and validation errors identify the affected field.

Under **Charging**, choose **Charging managed by: Phaeton / Victron GX**:

- **Phaeton** uses local solar, battery and grid-assist preferences in Auto. Choosing
  it disables GX charging control and preserves the existing discovery connection.
- **Victron GX** enables MQTT discovery and GX control together and disables the
  legacy Modbus producer. GX supplies Auto charging commands; local preferences
  remain stored but are labelled inactive. Broker addresses and identities are
  retained. Select Auto separately on the Charging page if it is not already active.

Changing the controller does not change Manual/Scheduled mode or send a Start
command. Discovery alone does not transfer charging control. The advanced discovery
choice under **Victron GX** supports legacy Modbus, MQTT discovery and no connection
when Phaeton manages charging. **Solar & battery readings** is an independent GX
system-data connection, not the charger discovery or control connection.

**Charger & installation** contains the charger model/address, connection test and
current/phase limits. Configured phase permissions are separate from the runtime
capability readback: allowing switching does not establish that it has been verified.
From v0.49.2, a successful distinct 1P/3P transition is saved for the matching charger
and installation. Fresh charger identity and phase readback are required to restore
it after a restart. See [phase-switch verification](alfen-settings-runbook.md#saved-phase-switch-verification)
for the initial test and conditions that invalidate it.
Register mappings, ports, identities and tuning are in contextual **Advanced**
disclosures. Reset is under **System → Maintenance → Advanced**. System also links
to the existing update, diagnostic and log pages.

Search covers all sections and advanced settings. Results include section
breadcrumbs. Selecting a result reveals it without modifying configuration; inactive
settings explain when they apply. Existing configuration section links still work.

## Charging Modes

### Manual

Manual mode lets the operator start or stop charging and set the current
directly from the dashboard.

Use Manual when:

- you want immediate control
- you are testing charger communication
- you do not want automatic PV or schedule decisions

### Auto

Auto is one charging mode with two possible controllers:

- With **Phaeton** as controller, the caption says **Follows solar surplus**.
  Phaeton uses GX solar, grid, load and battery readings with local charging
  preferences. Reliable data is needed for these local decisions.
- With **Victron GX** as controller, the caption says **Controlled by GX**.
  Status distinguishes Waiting for GX, Paused by GX, Waiting for vehicle,
  Preparing phase change, and Charging — controlled by GX. If GX loses control,
  Phaeton holds charging while waiting for GX; it does not fall back to local solar
  rules. Installation verification, connection failures and faults remain visible.

The dashboard follows saved runtime state, not an unsaved Settings draft. Older
status snapshots without ownership information use **Automatic charging**. Selecting
GX does not activate Dynamic ESS or Opportunity Loads scheduling services.

### Scheduled

Scheduled mode follows active time windows from the Planner view.

Use Scheduled when:

- charging should only be allowed during specific times
- the site uses external tariff or availability windows
- an operator wants predictable time-based behavior

Schedules can include day selections, start time, end time, active state, and
optional current limits. They can also require a VRM import price at or below a
limit. In the editor, choose **Charge when → VRM price is at or below a limit**.
Zero and negative prices are supported; missing prices pause charging. The first
matching enabled window owns the decision, including over overlapping windows.

Price-controlled windows can additionally require a **Minimum home battery (%)**.
Missing GX battery readings then pause charging. Without a minimum, the home
battery may supply charging. This is separate from Auto's battery settings.
The price preview shows known time/price eligibility for the next three days;
it does not guarantee an EV charge level or departure time. See
[VRM electricity prices](vrm-pricing.md#charge-at-low-prices) for details.

On the Schedule page, select a window in the week overview to show its Edit,
Enable/Disable, and Delete actions. Drag the middle of a window to move it,
or drag its left or right edge to change the start or end time. Changes use
15-minute steps and save when you release; press Escape or release outside
the week to cancel. A failed save restores the previous schedule.

A time change applies to every repeat day of that schedule. Moving a window
to another day shifts all its repeat days together. Overnight windows continue
on the next row, including Sunday into Monday. Overlapping schedules stay
separate and retain their existing order of precedence.

Click a day label or Add schedule to create a window. Double-clicking an empty
track starts a new window at that time. Click the exact-time text below a track,
double-click a window, or use Edit for the time, repeat days and current limit
form. Disabled windows remain visible and editable.

With a window focused, Left/Right moves it by 15 minutes and Up/Down shifts
its repeat days. Left/Right on an edge handle resizes that edge. Enter opens
the editor. On phones, scroll the week horizontally or use the day labels and
exact-time buttons to manage windows without dragging.

## Updates

Open `Updates`.

Two update paths are available:

- Local package update: upload the matching signed `*.phaeton-update` bundle.
- Release repository update: check and apply a release from the configured
  repository.

By default, a blank update repository means Phaeton uses the built-in
first-party release channel. Public Phaeton releases do not need an access token.
Version 0.60.0 also migrates saved references to Phaeton’s former public GitHub
repository. Install that bridge, restart, and check again for subsequent releases;
custom repositories and update preferences remain in place.

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
- verify the generated certificate fingerprint from the USB installation result or local logs before accepting it in a browser
- use a trusted reverse proxy with end-to-end TLS if remote access is required
- keep CORS disabled unless a specific trusted integration needs it
- restrict SSH access on the GX after installation
- back up configuration and license files securely

The browser UI uses local admin authentication after onboarding. API clients can
use HTTP Basic Auth over HTTPS when authentication is enabled.

## Troubleshooting

### The Public User Guide Link Returns 404

The hosted guide and downloadable Markdown copies are published with the portal
and first-party download service. The retained GitHub repository provides a
compatibility path for older installations; current instructions and releases
are available from the Phaeton website.

### Cannot Reach The Web UI

For a missing or failing VRM Control Panel, follow the
[VRM access checks](#if-control-panel-is-missing-or-opens-the-wrong-page).
The checks below are for direct local access.

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
- `scheduled_price_high`: the current VRM import price exceeds the active window's limit.
- `scheduled_price_unavailable`: the current interval has no usable cached VRM price.
- `scheduled_battery_low`: a price window's home-battery minimum is unmet or GX SoC is unavailable.
- `scheduled_price_allowed`: the current price meets the active window's limit.
- `scheduled_stopped`: a price-controlled window is held by manual Stop.
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

Open `Logs` in the web UI and select `Support bundle` after reproducing the issue,
before restarting Phaeton or reconnecting the charger. For a reported fix, capture
a new bundle while the charger is connected so the current status is included.

On Venus OS, the default log is:

```text
/data/phaeton/phaeton.log
```

The bundle includes the Phaeton version, current
status snapshot, diagnostics, and log content, but redacts paths, email
addresses, secrets, and full device identifiers. IP addresses keep only the
last octet, and serial, install, and license identifiers keep only their last
four characters so support can still correlate repeated reports.

Use `Download full log` when support specifically needs the original log file.

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
https://downloads.phaeton.virtunet.io/
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

Auto mode requests zero current while the charger reports no vehicle connected.
If Stop arrives during a current change, Phaeton records the completed change
and sends the corrective zero-current request on the next polling cycle.
Unavailable energy readings retain the last displayed counter; session totals
and energy attribution resume when fresh readings return.

Use **Schedule** to edit weekly charging windows and inspect the next window.
These windows control charging when Scheduled mode is selected.

**Settings** has four pages: Charging (autostart, solar and battery behavior),
Installation (phase restriction and electrical limits), Connections (charger and
GX), and System (timezone, pricing, access and service configuration). Technical
options are in Advanced. Search opens the matching page. Edits remain a draft
across page navigation until **Save changes** or **Discard changes**. Failed saves
retain the draft and identify the field to correct. Hidden options retain their
saved values.

For optional VRM electricity prices, open **Settings → System → Pricing**.
Create a token in VRM, paste it once and connect; enter the GX Portal ID if
automatic discovery fails. Connection changes save immediately, separately from
the Settings draft. Match the currency symbol and static fallback rate to your
VRM installation. See [VRM electricity prices](vrm-pricing.md) for setup,
fallback behavior and the limits of session cost estimates.

**Start automatically when connected** enables charging when a car is detected,
including when it is already plugged in as Phaeton starts. Saving this preference
also updates the active autostart control. Auto and Scheduled modes still wait
for their solar, battery and schedule conditions. A manual Stop remains in effect
until the car is disconnected and connected again, or you enable charging.
When GX Auto control is enabled, GX owns starting charging and local autostart
is suppressed.

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
