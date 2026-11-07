# Phaeton

> [!NOTE]
> This repository is archived and read-only. Phaeton is published at
> **[phaeton.virtunet.io](https://phaeton.virtunet.io)**. The repository stays
> available so that older installations can still update.

Phaeton connects supported non-Victron EV chargers to a Victron GX system as a
Victron EV Charging Station. It supports Alfen, go-e, Peblar, KEBA, WARP, Bender
and Zaptec chargers, and Easee chargers with approved Easee API access. The
[supported chargers](https://phaeton.virtunet.io/docs/supported-chargers) page
lists the models and requirements.

## Documentation

The user guide is at
**[phaeton.virtunet.io/docs](https://phaeton.virtunet.io/docs)**, in English,
Dutch and German. Start with:

- [Install on Victron GX](https://phaeton.virtunet.io/install): the recommended
  USB stick installation, with the SSH installation as an alternative.
- [Getting started](https://phaeton.virtunet.io/docs/getting-started) and
  [requirements and compatibility](https://phaeton.virtunet.io/docs/requirements).
- [Advanced installation](https://phaeton.virtunet.io/docs/advanced-installation),
  including other Linux systems.
- [Updates](https://phaeton.virtunet.io/docs/updates),
  [backup and restore](https://phaeton.virtunet.io/docs/backup-restore) and
  [troubleshooting](https://phaeton.virtunet.io/docs/troubleshooting).

## Downloads and updates

Releases are published on
[Phaeton downloads](https://downloads.phaeton.virtunet.io/). An installed
Phaeton updates itself from **System → Updates**.

Phaeton versions older than 0.60.0 look for updates in this repository and find
version 0.60.0 here. Install it from the update page, let Phaeton restart, then
check for updates again: from 0.60.0 on, Phaeton updates from Phaeton downloads.
No reinstallation or manual repository change is needed.

The files here:

- `release-signing-public.pem`: the public key that verifies every release's
  signature. Check a download against it as described under
  [Manual GX installation](https://phaeton.virtunet.io/docs/advanced-installation#manual-gx-installation).
- `scripts/install-gx.sh`: a copy of the SSH installer for older installation
  commands. It installs the current release from Phaeton downloads.
- `scripts/package-signed-updates.sh`: packages a release as signed update
  bundles.
- `docs/user_guide.md` and `docs/licensing.md`: pointers to the website for
  links in older versions.

## Licensing

Each physical charger requires its own home or commercial license under the
[software license](https://phaeton.virtunet.io/terms/EULA.md). See
[license pricing](https://phaeton.virtunet.io/pricing),
[license and purchase terms](https://phaeton.virtunet.io/terms), and
[installer partner terms](https://phaeton.virtunet.io/terms/PARTNER-TERMS.md).

## Support

Issues are no longer handled here. Customers use
[Support](https://phaeton.virtunet.io/support) in the license portal, which can
attach a support bundle. Questions before buying go through the
[contact form](https://phaeton.virtunet.io/contact). You can also email
`info@virtunet.nl`.
