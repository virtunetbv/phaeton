# Phaeton

Phaeton is a Victron EVCS protocol bridge for supported non-Victron EV chargers.

This public repository contains the public installer, license files, and release
documentation. Stable install packages are published on the GitHub Releases page.

Multiple chargers on one GX can use [named MQTT installations](docs/multiple-chargers.md)
with independent web interfaces and GX-owned Auto control. This requires Phaeton
0.51.0 or newer, separate activations and site qualification of shared charging.

## Install On Victron GX

**[Start the guided GX installation](https://phaeton.virtunet.io/install).**

The guide walks through GX settings, connecting from Windows/macOS/Linux,
installation and first login, in English and Dutch. The installer downloads and
verifies the software for you; no manual binary download or GitHub account is
needed. It currently supports ARMv7 Venus OS, including Cerbo GX.

If the website is unavailable, use the
[Markdown installation guide](docs/user_guide.md#install-on-victron-gx).
After connecting to your GX with SSH, run:

```sh
(installer=$(mktemp) && trap 'rm -f "$installer"' EXIT && curl -fL --connect-timeout 15 --max-time 120 https://phaeton.virtunet.io/install/gx.sh -o "$installer" && sh "$installer")
```

Keep the terminal open. The installer waits for the web interface and shows its
HTTPS address, private one-time Setup code and certificate fingerprint in an
interactive terminal. Compare the fingerprint before accepting the browser
certificate, then enter the code and choose your local account. Complete
activation in Phaeton. The GX password, local Phaeton account and portal account
are separate credentials.

Phaeton installs under `/data/phaeton` and manages its own block in
`/data/rc.local`, preserving other startup commands. Keep **Modifications
enabled** on for autostart. Do not replace the whole startup file with a manual
example. Future updates use **Software Updates** in Phaeton; rerunning the
installer does not replace a running installation.

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

- Personal Use is free under [`EULA.md`](EULA.md).
- Commercial Use requires a separate license from Virtunet BV.
- If you received Phaeton from a distributor or installer, Commercial Use is permitted only where that party is authorized by Virtunet BV to grant those rights.

For commercial licensing, contact `info@virtunet.io` or visit https://virtunet.io.

## User Guide

The hosted user guide is available at:

https://phaeton.virtunet.io/docs

This repository also keeps a Markdown fallback at
[`docs/user_guide.md`](docs/user_guide.md).
