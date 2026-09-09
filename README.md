# Phaeton

Phaeton is a Victron EVCS protocol bridge for supported non-Victron EV chargers.

This public repository contains the public installer, license files, and release
documentation. Stable install packages are published on the GitHub Releases page.

Multiple chargers on one GX can use [named MQTT installations](docs/multiple-chargers.md)
with independent web interfaces and GX-owned Auto control. This requires Phaeton
0.51.0 or newer, separate activations and site qualification of shared charging.

## Install on Victron GX

**[Start the guided GX installation](https://phaeton.virtunet.io/install).**

We recommend **installation from a USB stick**. The English/Dutch guide covers:

1. Download the USB installer from the guide.
2. Copy the unopened `.tgz` file onto a prepared USB stick, outside any folder.
3. Enable modifications on the GX, insert the stick in a data USB port and restart.
   Follow the guide's waiting and safe-removal instructions.
4. Open `https://GX-IP:8088/` on the same local network and finish setup.

No SSH, terminal commands or setup code are needed. The GX does not need internet
during installation; activation can use an internet-connected computer afterward.

The USB installer is for 32-bit ARMv7 Venus OS, including Cerbo GX. Read the
[USB preparation and recovery guide](docs/gx-usb-installation.md) before starting;
it covers the required stick format and current availability.

If the website is unavailable, use the
[Markdown installation guide](docs/user_guide.md#install-on-victron-gx).
For future updates, use **Software Updates** in Phaeton. The USB installer
preserves existing installations and does not update them.

### Advanced installation with SSH

Use the **SSH installation** section in the guided installation if you cannot use a
stick or prefer a terminal. It downloads and verifies the software for you.

<details>
<summary>SSH command and technical installation details</summary>

After preparing and connecting to your GX as described in the
[SSH instructions](docs/user_guide.md#advanced-installation-with-ssh), run:

```sh
(installer=$(mktemp) && trap 'rm -f "$installer"' EXIT && curl -fL --connect-timeout 15 --max-time 120 https://phaeton.virtunet.io/install/gx.sh -o "$installer" && sh "$installer")
```

Keep the terminal open. The installer waits for the web interface and shows its
HTTPS address and certificate fingerprint. Compare the fingerprint before
accepting the browser certificate, then choose your local administrator username
and password. No setup code is required. Complete activation in Phaeton. The GX
password, local Phaeton account and portal account are separate credentials.

Phaeton installs under `/data/phaeton` and manages its own block in
`/data/rc.local`, preserving other startup commands. Keep **Modifications
enabled** on for autostart. Do not replace the whole startup file with a manual
example. Future updates use **Software Updates** in Phaeton; rerunning the
installer does not replace a running installation.

</details>

## Post-Install Checks

Phaeton stores its writable files on Venus OS in `/data/phaeton`.

Important files:

- `/data/phaeton/config.yaml`
- `/data/phaeton/state.json`
- `/data/phaeton/phaeton.log`

For Auto mode on a GX device, enable `Settings -> Services -> Modbus-TCP` on
the GX and use Phaeton's GX test button before relying on PV-aware charging.
Phaeton reads GX system data from unit ID `100`.

For the built-in Alfen profile, confirm the charger-side settings before
debugging Phaeton. Start with the hosted Alfen checklist:

https://phaeton.virtunet.io/docs/alfen-settings

This public repository also keeps the same checklist as a Markdown fallback:
[`docs/alfen-settings-runbook.md`](docs/alfen-settings-runbook.md).

In the Phaeton charger profile screen, run `Test Alfen Control`. It should
report that the Alfen setpoint is accounted for. If it does not, fix the
charger-side EMS / Active Load Balancing configuration before debugging Auto
mode thresholds.

## If Charging Does Not Start

Use the Dashboard status reason first. It distinguishes setup or activation
blocking, charger connection loss, no EV connected, low battery SoC,
phase-settling, schedule blocking, waiting for grid threshold, and waiting for
solar surplus.

Recommended support reproduction:

1. Open `Logs`.
2. Set log level to `DEBUG`.
3. Clear displayed logs.
4. Try Manual mode at `6 A`.
5. If Manual works, switch back to Auto and wait for at least two poll cycles.
6. Select `Download full log`.

## Releases

Current release artifacts:

- `phaeton-<tag>-arm-unknown-linux-gnueabihf.tar.gz`
- `phaeton-<tag>-armv7-unknown-linux-gnueabihf.tar.gz`
- `phaeton-<tag>-aarch64-unknown-linux-gnu.tar.gz`
- `phaeton-<tag>-x86_64-unknown-linux-gnu.tar.gz`
- `SHA256SUMS`
- `SHA256SUMS.sig`

Use `release-signing-public.pem` from this repository as the trusted
verification key.

Verify downloads before installing:

```bash
openssl dgst -sha256 -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:digest \
  -verify release-signing-public.pem -signature SHA256SUMS.sig SHA256SUMS
sha256sum -c SHA256SUMS
```

## Other Linux

Extract the release tarball and install the `phaeton` binary:

```bash
mkdir -p phaeton-extract
tar -xzf phaeton-<tag>-<artifact>.tar.gz -C phaeton-extract
sudo install -m 0755 phaeton-extract/phaeton /usr/local/bin/phaeton
```

## Licensing

- Each physical charger requires its own home or commercial license under
  [`EULA.md`](EULA.md). Licenses are perpetual, with no subscription.
- New home licenses are paid. Existing issued free licenses remain permanent;
  eligible existing accounts may claim within the deadline shown in the portal.
- The zero-power demo is free for simulated operation only.
- Approved installers may commission customer-owned home and commercial licenses.

See [license pricing](https://phaeton.virtunet.io/pricing),
[`COMMERCIAL-LICENSING.md`](COMMERCIAL-LICENSING.md), and
[`PARTNER-TERMS.md`](PARTNER-TERMS.md). For licensing assistance, contact
`info@virtunet.nl`.

## User Guide

The hosted user guide is available at:

https://phaeton.virtunet.io/docs

This repository also keeps a Markdown fallback at
[`docs/user_guide.md`](docs/user_guide.md).
