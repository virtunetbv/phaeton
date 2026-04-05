# Phaeton

Phaeton is a Victron EVCS protocol bridge for supported non-Victron EV chargers.

## Releases

Public install packages are published on the Releases page:

https://github.com/virtunetbv/phaeton/releases

Current release artifacts:

- `phaeton-<tag>-armv7-unknown-linux-gnueabihf.tar.gz`
- `phaeton-<tag>-aarch64-unknown-linux-gnu.tar.gz`
- `phaeton-<tag>-x86_64-unknown-linux-gnu.tar.gz`
- `SHA256SUMS`

Verify downloads before installing:

```bash
sha256sum -c SHA256SUMS
```

## Install

Extract the release tarball and install the `phaeton` binary:

```bash
mkdir -p phaeton-extract
tar -xzf phaeton-<tag>-<artifact>.tar.gz -C phaeton-extract
sudo install -m 0755 phaeton-extract/phaeton /usr/local/bin/phaeton
```

On first start, Phaeton writes `config.yaml` in its data directory and generates the admin password there when authentication is enabled.

## Licensing

- Personal Use is free under [`EULA.md`](EULA.md).
- Commercial Use requires a separate license from Virtunet BV.
- If you received Phaeton from a distributor or installer, Commercial Use is permitted only where that party is authorized by Virtunet BV to grant those rights.

For commercial licensing, contact `ron@virtunet.nl`.
