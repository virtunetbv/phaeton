# Phaeton

Phaeton is a Victron EVCS protocol bridge for supported non-Victron EV chargers.

This public repository contains the public installer, license files, and release
documentation. Stable install packages are published on the GitHub Releases page.

## Install On Victron GX

These steps are intended for Cerbo GX and other GX devices running Venus OS.

### 1. Enable Third-Party Software And SSH

Before installing Phaeton, enable the Victron settings needed for SSH access and
startup scripts.

Use the official Victron root access guide for the current menu flow:

https://www.victronenergy.com/live/ccgx:root_access

Relevant notes from Victron's guide:

> "`Modifications enabled`" is available in `Settings -> General -> Modification checks`.

> "If the files /data/rcS.local or /data/rc.local exists, they will be called during startup."

On the GX device:

1. Go to `Settings -> General`.
2. Raise the access level to `Superuser`.
3. Set a temporary root password in `Settings -> General -> Set root password`.
4. Enable `SSH on LAN` in `Settings -> General`.
5. Open `Settings -> General -> Modification checks` and make sure `Modifications enabled` is enabled.

`/data/rc.local` only works when modifications are enabled. If Venus OS renames
it to `/data/rc.local.disabled`, re-enable modifications in that menu and rename
the file back.

### 2. Run The Installer

Fast path from your machine after SSH is enabled on the GX:

```sh
ssh root@<gx-ip> 'curl -fsSL https://raw.githubusercontent.com/virtunetbv/phaeton/main/scripts/install-gx.sh | sh'
```

If you are already logged into the GX shell, run:

```sh
curl -fsSL https://raw.githubusercontent.com/virtunetbv/phaeton/main/scripts/install-gx.sh | sh
```

The installer downloads the latest stable GX package, verifies the signed
`SHA256SUMS` manifest and selected package, installs Phaeton into
`/data/phaeton`, and creates or updates `/data/rc.local` for autostart. It also
starts Phaeton in the background and prints a web UI link using the detected GX
IP address when available.

If you prefer the manual installation steps, use the process below.

## Manual GX Install

Public install packages are published on the Releases page:

https://github.com/virtunetbv/phaeton/releases

For GX devices, download:

- `phaeton-<tag>-armv7-unknown-linux-gnueabihf.tar.gz`
- `SHA256SUMS`
- `SHA256SUMS.sig`

Use `release-signing-public.pem` from this repository as the trusted
verification key.

Verify the download before installing:

```bash
openssl dgst -sha256 -sigopt rsa_padding_mode:pss -sigopt rsa_pss_saltlen:digest \
  -verify release-signing-public.pem -signature SHA256SUMS.sig SHA256SUMS
sha256sum -c SHA256SUMS
```

Copy the release tarball to the GX:

```bash
scp phaeton-<tag>-armv7-unknown-linux-gnueabihf.tar.gz root@<gx-ip>:/data/
```

SSH into the GX and install Phaeton into `/data/phaeton`:

```bash
ssh root@<gx-ip>
mkdir -p /data/phaeton
tar -xzf /data/phaeton-<tag>-armv7-unknown-linux-gnueabihf.tar.gz -C /data/phaeton
chmod +x /data/phaeton/phaeton
```

Test run:

```bash
/data/phaeton/phaeton
```

On first start, Phaeton writes `config.yaml` in its data directory and serves
the first-run onboarding wizard at `http://<gx-ip>:8088/`. Complete the wizard
to choose admin credentials before the bridge runtime starts.

To start Phaeton automatically on boot, create or edit `/data/rc.local`:

```sh
cat >/data/rc.local <<'EOF'
#!/bin/sh
cd /data/phaeton
/data/phaeton/phaeton >> /data/phaeton/phaeton.log 2>&1 &
exit 0
EOF
chmod +x /data/rc.local
```

Reboot the GX and confirm that Phaeton starts automatically.

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
