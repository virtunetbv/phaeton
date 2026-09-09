# GX USB installation / GX USB-installatie

**Experimental prototype, issue #384. SSH remains the supported route. No GX
model/firmware combination is advertised as USB-qualified.** This guide is for
supervised qualification trials; it does not establish complete hardware qualification.

**Experimenteel prototype, issue #384. SSH blijft de ondersteunde route. Er is
nog geen GX-model/firmwarecombinatie voor USB gekwalificeerd.** Deze handleiding
is bedoeld voor begeleide kwalificatieproeven en bewijst geen volledige hardwarekwalificatie.

These instructions describe Phaeton 0.58.0 and later, with no setup code. The
earlier 0.57.0 trial is preserved below as historical evidence.

## English instructions

1. Obtain the experimental installer from the Phaeton site's **Install → USB
   installation** section when the trial operator has enabled its download.
   The file is named `venus-data-phaeton-VERSION-armv7.tgz`. Do not open it,
   extract it, rename it, or use a `.phaeton-update` file for USB installation.
2. Use a dedicated empty, writable USB stick: **FAT32, MBR partition table,
   at least 256 MB free**. Formatting erases its contents; save wanted files
   elsewhere first. Do not use a GX logging stick. Disconnect other removable
   storage during the trial. There must be only one Phaeton installer present.
3. **Windows:** use File Explorer to copy the unopened archive from Downloads
   directly onto the USB drive. Choose Eject before unplugging it.
   **macOS:** use Finder to do the same. Disable Safari's **Open “safe” files
   after downloading** first; download again if Safari already extracted it.
   Use Finder's eject icon before unplugging it. The site's EN/NL instructions
   include a copy illustration. The final layout is:

   ```text
   Downloads                         USB drive (top level)
   venus-data-phaeton-….tgz   ───►    venus-data-phaeton-….tgz
                                    (no enclosing folder)
   ```

4. On the GX, confirm **Settings → General → Modification checks →
   Modifications enabled**; firmware versions may label these menus differently.
   SSH is not required and its settings are not changed by the installer.
   Use the model's **data-capable USB port**. A power-only
   port, including one intended only to power GX Touch, cannot read the stick.
   Insert it and restart at a time when rebooting will not interrupt charging
   or other essential work.
5. Allow **five minutes** and wait for media activity to stop. The installer
   flushes its result, checks the bytes written, and attempts to unmount the
   selected stick after success. Follow the trial operator's safe-removal
   procedure established on that exact GX/firmware combination. Do not pull a
   busy stick or interrupt GX power to meet a time limit. Safe-removal timing
   and a visible GX indication remain physical qualification gates.
6. Find the GX IP in its network settings. On the same trusted local network,
   open `https://GX-IP:8088/` and choose the administrator username and password.
   **No setup code is required.** You can complete setup directly in the browser.
7. For installation diagnostics or certificate comparison, safely return the
   stick to your computer and open **PHAETON-RESULT.html**. This offline page
   contains status and the public **SHA-256 certificate fingerprint**, with no
   setup credential, scripts, tracking or external resources. Compare that
   fingerprint with the browser certificate if needed; stop if they differ.
   If the result is missing, still says **Installation in progress**, or reports
   failure, use the recovery table. A read-only stick cannot receive a result.
   Venus may also create `vrmlogger-backlog.sqlite3` for its own VRM logging,
   even on a new stick. Preserve VRM records that have not yet been uploaded;
   the database is not needed for Phaeton setup.
8. Configure the charger, then activate its license. Initial installation needs
   **no GX internet connection**. Online activation requires connectivity; an
   offline GX can exchange activation request/license files using a computer
   with internet. Configuration, activation, and charging are separate actions.
   Start a charging test only when you explicitly choose to do so.

## Nederlandse instructies

1. Download de experimentele installer via **Installeren → USB-installatie**
   op de Phaeton-site nadat de proefbegeleider de download heeft ingeschakeld.
   De bestandsnaam is `venus-data-phaeton-VERSIE-armv7.tgz`. Open het bestand
   niet, pak het niet uit en hernoem het niet. Gebruik geen `.phaeton-update`.
2. Gebruik een aparte lege, schrijfbare USB-stick met **FAT32, MBR-partitietabel
   en minstens 256 MB vrije ruimte**. Formatteren wist de inhoud; bewaar
   gewenste bestanden eerst ergens anders. Gebruik geen GX-logstick. Koppel
   andere verwisselbare media los; er mag maar één Phaeton-installer aanwezig zijn.
3. **Windows:** kopieer in Verkenner het ongeopende archief vanuit Downloads
   rechtstreeks naar het USB-station. Kies Uitwerpen voordat u het loskoppelt.
   **macOS:** doe hetzelfde in Finder. Schakel in Safari eerst **Open veilige
   bestanden na downloaden** uit; download opnieuw als het al is uitgepakt.
   Gebruik het uitwerpsymbool. De website toont ook een kopieerillustratie:

   ```text
   Downloads                         USB-station (hoofdniveau)
   venus-data-phaeton-….tgz   ───►    venus-data-phaeton-….tgz
                                    (niet in een map)
   ```

4. Controleer **Instellingen → Algemeen → Modification checks → Modifications
   enabled** op de GX; menunamen verschillen per firmware. SSH is niet nodig
   en de installer verandert de SSH-instellingen niet.
   Gebruik een **USB-poort met data**, niet een poort die alleen GX Touch van
   stroom voorziet. Plaats de stick en herstart op een geschikt moment, zonder
   laden of ander essentieel werk te onderbreken.
5. Wacht **vijf minuten** en totdat de USB-activiteit stopt. De installer schrijft
   het resultaat weg, controleert de opgeslagen bytes en probeert na succes
   de gekozen stick te ontkoppelen. Volg de veilige verwijderprocedure die de
   proefbegeleider op precies deze GX/firmware heeft vastgesteld. Trek geen
   actieve stick uit en onderbreek de GX-voeding niet om een tijdslimiet te halen.
   Verwijdertijd en een zichtbare GX-indicatie moeten nog fysiek worden getest.
6. Zoek het GX-IP in de netwerkinstellingen. Open `https://GX-IP:8088/` op
   hetzelfde vertrouwde lokale netwerk en kies de gebruikersnaam en het wachtwoord
   voor de beheerder. **Er is geen setupcode nodig.** Rond de setup rechtstreeks
   in de browser af.
7. Voor installatiediagnostiek of certificaatcontrole plaatst u de veilig
   verwijderde stick terug in de computer en opent u **PHAETON-RESULT.html**.
   Deze offline pagina bevat de status en de openbare **SHA-256-vingerafdruk**
   van het certificaat, zonder setupgeheim, scripts, tracking of externe bronnen.
   Vergelijk de vingerafdruk zo nodig met het browsercertificaat; stop als deze
   afwijkt. Ontbreekt het bestand, staat er nog **Installatie bezig**, of is er
   een fout, gebruik dan de hersteltabel. Op alleen-lezen media kan geen resultaat
   worden opgeslagen. Venus kan ook `vrmlogger-backlog.sqlite3` aanmaken voor
   eigen VRM-loggegevens. Bewaar nog niet-geüploade records; deze database is
   niet nodig voor Phaeton-setup.
8. Configureer de lader en activeer daarna de licentie. Voor installatie heeft
   de GX **geen internet nodig**. Online activering vereist verbinding; voor
   een offline GX wisselt u licentiebestanden uit via een computer met internet.
   Configuratie, activering en laden zijn aparte acties. Begin alleen bewust
   aan een laadtest.

## Recovery / Herstel

The same installer stick can be reused on multiple GX devices. Each running
installer replaces `PHAETON-RESULT.html` automatically; deleting it is not a
requirement for reuse. It is an optional status/certificate report, not an
installation credential. Confirm setup on the current GX: if its boot hook never
runs, the previous device's report can remain on the stick.

The USB installer resumes an eligible unfinished installation of its own signed
package and preserves completed or unrecognized installations. It does not
upgrade an existing deployment. For an **offline update**, upload the newer
platform-matching `.phaeton-update` bundle in Phaeton's **Software Updates** page;
the GX does not need internet for that upload.

When troubleshooting that situation, remove the previous `PHAETON-RESULT.html`
and temporary `.phaeton-result.*` files on the computer before retrying so an old
success cannot be mistaken for a new result. Keep the unopened installer. Never
factory-reset the GX or delete Phaeton configuration/licensing files as recovery.

Dezelfde installatiestick kan op meerdere GX-apparaten worden gebruikt. Elke
gestarte installer vervangt `PHAETON-RESULT.html` automatisch; verwijderen is
geen voorwaarde voor hergebruik. Het bestand is alleen een optioneel status- en
certificaatrapport, geen toegangscode. Controleer de setup op de huidige GX: als
de starthook niet wordt uitgevoerd, kan het rapport van het vorige apparaat blijven
staan.

De USB-installer hervat een daarvoor geschikte onvoltooide installatie van zijn
eigen ondertekende pakket en behoudt voltooide of onbekende installaties. Hij
werkt bestaande installaties niet bij. Upload voor een **offline update** de
nieuwere `.phaeton-update`-bundel voor het juiste platform via **Software Updates**
in Phaeton; de GX heeft voor die upload geen internet nodig.

Verwijder bij onderzoek naar dat probleem vóór de nieuwe poging het oude
`PHAETON-RESULT.html` en tijdelijke `.phaeton-result.*`-bestanden op de computer,
zodat oud succes niet voor een nieuw resultaat wordt aangezien. Bewaar de
ongeopende installer. Herstel nooit door een fabrieksreset of door het verwijderen
van Phaeton-configuratie/licenties.

| Result / Resultaat | English action | Nederlandse actie |
| --- | --- | --- |
| Missing or in progress / Ontbreekt of bezig | Check the archive is unopened, in the drive root, on writable FAT32, with no second installer stick. Confirm the data USB port and modifications setting. After safe removal, try a different stick and download again. A hook that never runs or unwritable media cannot report a failure onto that media. | Controleer ongeopend archief, hoofdniveau, schrijfbaar FAT32, één installer, datapoort en toegestane wijzigingen. Verwijder veilig, probeer een andere stick en download opnieuw. Een niet-uitgevoerde hook of niet-schrijfbare stick kan geen fout op die stick zetten. |
| Signature/checksum / Handtekening/checksum | Download again from Phaeton; do not override verification. | Download opnieuw van Phaeton; omzeil verificatie niet. |
| Storage / Opslag | Free space using GX settings or contact the trial operator. Preserve Phaeton data. | Maak ruimte via GX-instellingen of neem contact op met de proefbegeleider. Behoud Phaeton-gegevens. |
| Modifications disabled / Wijzigingen uit | Enable modifications in GX settings and restart with the stick. | Schakel wijzigingen in via GX-instellingen en herstart met de stick. |
| Failed write / Schrijffout | Restart with the same installer to resume. If the stick is failing, copy the same release's unopened installer to a new writable FAT32 stick, disconnect the old one, and retry. Existing configuration and identity are preserved. | Herstart met dezelfde installer om te hervatten. Kopieer bij een defecte stick dezelfde ongeopende installer naar een nieuwe schrijfbare FAT32-stick, koppel de oude los en probeer opnieuw. Bestaande configuratie en identiteit blijven behouden. |
| Failed startup / Start mislukt | Check for another service on port 8088; retry by rebooting. If it repeats, contact the trial operator with the non-secret error text only. | Controleer of poort 8088 bezet is en herstart. Neem bij herhaling contact op met de proefbegeleider met alleen de niet-geheime fouttekst. |
| Existing installation / Bestaande installatie | Nothing is replaced, including newer releases. Open that installation's web interface. Use its updater, not the USB installer, to change versions. | Er wordt niets vervangen, ook geen nieuwere release. Open de bestaande webinterface en gebruik die voor updates. |
| Another installer / Andere installer | Restart and retry. Persistent unrecognized SSH locks require the trial operator; USB never deletes them. | Herstart en probeer opnieuw. Een blijvende onbekende SSH-lock vereist de proefbegeleider; USB verwijdert deze nooit. |

## Build, distribution and qualification record

The builder consumes a signed stable ARMv7 archive, `SHA256SUMS`, and
`SHA256SUMS.sig` in one directory:

```sh
python3 scripts/package-gx-usb.py \
  dist/phaeton-VERSION-armv7-unknown-linux-gnueabihf.tar.gz \
  release-signing-public.pem dist
```

Stable tag pipelines provide the manual `package_gx_usb_prototype` job, which
consumes the signed private release manifest and cross-built binary. Its `.tgz`
artifact is available for trials before public promotion. Public GitHub promotion
also builds and attaches the archive with an **experimental** label. No signing
key is placed in the USB archive. The outer boot hooks run with physical-media
root authority: obtain and protect the entire installer from the first-party
HTTPS download. Payload signature verification cannot authenticate a maliciously
replaced boot hook or its bundled trust anchor on a compromised USB stick.

Before releasing a version, a protected tag such as `v0.58.0-usb-trial.1` runs
the normal CI checks and builds, then offers the manual `package_gx_usb_trial`
job. That job signs the ARMv7 payload with the existing CI release key and emits
only a maintainer-accessible USB artifact, retained for 30 days. The private key
is held in temporary storage and removed before packaging. Trial tags skip
GitLab release publication and do not match public GitHub promotion or deployment
rules. A trial artifact does not establish a stable release or hardware qualification.

The prototype requires the GX's existing Python 3 standard library, OpenSSL,
curl, flock and basic shell/file utilities. Python supplies atomic lock creation
and bounded subprocess groups when Venus's reduced BusyBox lacks `timeout`.
No package installation or root filesystem changes are performed. Prepared
recovery checks the exact installed executable and needs only 1 MiB of workspace;
it does not restage the release or reset configuration/identity.

The portal's same-origin `/downloads/venus-data-phaeton.tgz` route is disabled
by default. Operators may pin `GX_USB_INSTALLER_VERSION=X.Y.Z` after the asset
is published to enable a **trial** download. Versions before 0.58.0 are refused
because they still require the retired setup code. It streams only that fixed official
release and preserves the required archive filename. It does not enable a
qualified/default USB route. Keep the environment variable unset when no trial
download is being offered. Publish/update the instructions through the curated
public GitHub sync. No portal deployment or release publication is implied by
merging this implementation.

For the repository's deployment helper, supply the corresponding optional
`PHAETON_PORTAL_STAGING_GX_USB_INSTALLER_VERSION` or
`PHAETON_PORTAL_PRODUCTION_GX_USB_INSTALLER_VERSION` variable. It is copied to
the Worker's `GX_USB_INSTALLER_VERSION` binding. No value is committed by default.

| GX / firmware | State | Evidence |
| --- | --- | --- |
| Cerbo GX (`einstein`, device-tree identifier `victronenergy,cerbo-gx-b1`), Venus `v3.80~39` | Fresh 0.58.0 USB installation and first-account creation with SSH disabled and internet blocked; licensed restart without USB passed | Supervised trials below; remaining physical qualification cases are still pending |
| Cerbo GX MK2, exact revision + Venus version to be selected | Not tested | No compatibility claim |
| Other GX models / firmware | Not supported by this prototype's qualification record | No compatibility claim |

Before advertising **each** model/firmware pair, record hardware revision,
firmware version, USB make/capacity/filesystem/port, SHA-256 of the installer,
installer release, SSH-disabled proof, timings, result screenshots, and the exact safe-removal procedure. Required physical cases:

- Fresh install reaches setup with GX internet disconnected and SSH disabled.
- Correct certificate comparison and direct first-account creation without a
  code. Confirm subsequent setup calls require login and cannot reset the account;
  no credentials or private keys appear in the USB result, logs or public APIs.
- Corrupt/truncated package; low `/data` space; disabled modifications; failed
  startup; read-only, full, and slow USB; unplug/replug and two identical sticks.
- Interrupt power at staging, ownership, binary rename, run-script write,
  `rc.local` rename, and result write; resume and compare preserved data.
- Reboot repeatedly with the stick present, including a newer release installed
  through the web updater. Confirm no binary replacement, resets or downgrade.
- Reboot without the stick and apply a representative Venus firmware update;
  verify autostart, configuration/license/TLS identity, and unrelated startup code.
- Independently review the physical-media trust boundary and claim/certificate
  setup boundary before customer trials. See the [blind review record](gx-usb-security-review-2026-09-08.md).
  Neither that review nor repository tests establish physical qualification.
- Observe at least five representative novice users with both EN/NL guidance;
  at least four must reach the dashboard without facilitator intervention before
  considering USB the default route. Record failures and revise the instructions.

### Supervised hardware trial, 2026-09-08

This historical trial used the former setup-code flow. The operator rebooted
the Cerbo GX with the reviewed v0.57.0 USB archive and
reported seeing the setup page. SSH remained enabled for observation; internet
disconnection was not established, so this does not satisfy the SSH-disabled or
offline qualification cases.

Read-only inspection confirmed:

- The installed executable matches the expected trial payload digest; preparation
  and autostart markers match it. One default Phaeton process was running.
- The successful private result was last updated approximately 75 seconds after
  boot. It contains the local claim and the actual certificate fingerprint.
- Certificate-verified HTTPS reports setup and a private claim are required.
  Its public setup response and the one Phaeton log file inspected contain no
  claim. The device claim file has mode 0600.
- At the first SSH inspection (approximately 283 seconds after boot), the USB
  filesystem was unmounted and the installer locks had been released. The
  operator was advised to remove the stick after this confirmation; this is
  supervised removal evidence, not a universally qualified removal timeout.
- Autostart is present and the original installation/configuration backup is
  preserved. Browser claim consumption, reboot without the stick, interrupted
  recovery, firmware-update survival and novice trials remain pending.

The exact archive digest is in the [review record](gx-usb-security-review-2026-09-08.md).
No setup codes, certificate private keys or credential-bearing result files are
included in this evidence.

The operator subsequently confirmed the stick contained `PHAETON-RESULT.html`
and `vrmlogger-backlog.sqlite3`. The returned HTML exactly matched the device's
successful result. Read-only SQLite inspection found a 16 KiB VRM database with
zero queued records. This is consistent with Venus automatically using inserted
storage for [VRM logging](https://www.victronenergy.com/media/pg/Cerbo_GX/en/vrm-portal.html).
The instructions now explain this additional file.

Operator feedback identified substantial friction in retrieving and manually
copying the private setup code. The product owner subsequently selected direct
first-visit account creation without a code, recorded in
[ADR 0053](https://gitlab.virtunet.io/virtunet/phaeton/-/blob/main/docs/adr/0053-create-first-admin-directly-without-a-setup-code.md). The
updated flow has separate software review and verification; it does not inherit
this trial's claim-based security conclusion. This supervised operator session is
not counted as a formal novice usability result.

### Updated setup on the trial GX, 2026-09-08

After the operator selected direct first-visit account creation, an ARMv7 build
of 0.58.0 was applied through the already enabled SSH connection. The existing
trial executable and state were backed up before replacement. Device inspection
verified the executable version, certificate-verified HTTPS status with
`claim_required: false`, removal of the retired claim file, no code field/header
in the served wizard assets, unchanged configuration and certificate, and one
running default Phaeton process. No administrator account was created by the
agent. The operator can continue setup in the browser.

This verifies the SSH-applied runtime; the later fresh USB trial is recorded
below. The earlier 0.57.0 archive remains the historical code-based trial.

### Automated validation, 2026-09-08

The implementation was checked locally with the following commands. These use
temporary signed fixtures and mocked GX hardware/media interfaces, not physical
GX qualification evidence.

| Check | Result |
| --- | --- |
| `python3 -m unittest discover -s tests -p '*gx*_py_test.py'` | USB installer and existing SSH installer regressions passed |
| `PHAETON_USB_TEST_BINARY="$PWD/target/debug/phaeton" python3 -m unittest discover -s tests -p gx_usb_runtime_py_test.py` | Updated flow: real loopback HTTPS setup without a code, legacy-file cleanup, certificate persistence and post-setup login across restart passed |
| `python3 -m unittest discover -s tests -p signed_update_bundle_py_test.py` | Passed |
| `python3 -m unittest discover -s tests -p public_github_sync_py_test.py` | Passed |
| `python3 -m unittest discover -s tests -p release_notes_py_test.py` | Passed |
| `cargo test --locked --test setup_wizard_test` | Updated flow: 18 passed, including no-code setup, concurrent completion and post-setup authentication |
| `cargo test --locked --lib bootstrap_marks_setup_required` | 2 passed: no code generation and retired-file cleanup |
| `cargo test --locked --lib web::auth::` | 37 passed, including login/session and compatibility coverage |
| `pnpm webui:test` | Updated flow: 248 passed |
| `pnpm portal:test` | 639 passed |
| `pnpm portal:smoke` | Local Worker/D1 smoke passed |
| `pnpm shellcheck` | Passed |
| `pnpm format:check` | Passed |
| `pnpm design-tokens:check` | Passed |
| `bash scripts/check-budgets.sh` | Passed |
| `git diff --check` | Passed |
| `glab ci lint .gitlab-ci.yml` | Valid |

Additionally, the 18 USB cases passed with BusyBox 1.37 file utilities (`tar`,
`ln`, `awk`, `sha256sum`, `mktemp`, `df`, `cp`, `cmp`, `head`, `tail`, `mv`,
`chmod`, `mkdir`, `rm`, `readlink`) selected through a temporary PATH. The three
GX shell files also passed `busybox sh -n`. The host's standalone BusyBox shell
bypasses PATH-based command mocks, so this is a file-utility compatibility run,
not an emulated Venus boot. The build/publish/sync Python files passed
`python3 -m py_compile`.

The blind review subsequently expanded the USB suite to 22 fixture tests,
four platform-helper tests, and one opt-in real-runtime HTTPS test. The earlier
18-case utility run predates those review fixes. Native helper preflight on the
trial GX uses its Python 3.12.13; it does not establish removable-media boot or
power-loss behavior.

Full-workspace Clippy/tests/coverage, audit, deny, documentation and cross-release
build matrices remain CI-owned and are not claimed as run locally. A single
production-mode ARMv7 release build with all features was run to update the test
GX; it passed. No release publication or portal deployment was performed.

### Signed trial artifact and CI, 2026-09-08

Protected tag `v0.58.0-usb-trial.1` identifies commit
`fe57e0325d2cc7e08df85e414a4efd4dc62bf657`. Both the
[MR pipeline 12524](https://gitlab.virtunet.io/virtunet/phaeton/-/pipelines/12524)
and [trial pipeline 12536](https://gitlab.virtunet.io/virtunet/phaeton/-/pipelines/12536)
passed. MR CI recorded 1,237 passing Rust tests, one skipped test, 85.98% line
coverage, 170 application browser tests, 136 portal browser tests, and all four
release builds. Its format, budget, Clippy, documentation and dependency-policy
gates also passed. These are CI results, not duplicated local full-workspace runs.

The subsequent private signing job succeeded. The resulting
`venus-data-phaeton-0.58.0-armv7.tgz` is 8,241,651 bytes, SHA-256
`bfbe268c3c229f2912bceea4fad34849987ba1568fb0610f82c5576578335bd4`.
Independent local inspection verified its RSA-PSS signature against the repository
public key, exact payload equality with the CI ARMv7 build artifact, executable
digest/architecture, archive layout, and boot scripts against the reviewed commit.
No stable release, registry package, public download or portal deployment was
published by the trial pipeline.

### Fresh no-code hardware trial, 2026-09-09

The operator copied that signed 0.58.0 archive to the installer stick and rebooted
the same Cerbo GX with SSH disabled. Storage reported **SanDisk 3.2Gen1**, vendor
`USB`, capacity 30,784,094,208 bytes (nominal 32 GB), with a `vfat` partition.
USB topology was `3-1.1.4`; the enclosure's physical port label, full retail stick
model, partition-table type and independent FAT subtype readout remain unrecorded.
This device boots microSD because its internal storage has failed; its existing
firmware-update caveat remains in the [GX qualification record](victron-gx-qualification.md).

The operator blocked internet access in the UDM while retaining local IPv4
access. Preflight found that the GX's `ll-eth0` virtual Ethernet interface used a
second, randomly assigned MAC and could still reach verified public IPv6 HTTPS.
The primary interface was blocked on both IP versions. Blocking the current
virtual IPv6 address worked only for that boot: a rehearsal reboot changed its
MAC. A temporary GX-only early boot hook disabled default/virtual-interface IPv6,
with the UDM continuing to block the primary interface. Public TCP/443 probes to
two IPv4 and two IPv6 destinations failed before installation and again during
inspection of the actual USB-install boot. This test network preparation was
separate from the distributed installer and was removed after the offline tests.

Observed results:

- LAN port 22 refused connections while Phaeton's HTTPS setup page was available.
  The agent did not use SSH to install the candidate. The operator re-enabled SSH
  only after completing the wizard and reaching the activation page.
- Initial HTTPS status reported `required: true` and `claim_required: false`.
  The served wizard JavaScript exactly matched the reviewed source, and its form
  had administrator credentials with no code input. After operator setup,
  unauthenticated setup-status and configuration requests returned HTTP 401.
- The installed executable reported 0.58.0 and matched SHA-256
  `fc62f99a4e03eed9a576a1fffbba1ba9518937cd5fbe5dc7ed4d63f755d05506`.
  Preparation and autostart markers matched it; one default process was running.
- The staged result reported success without a code. Its public fingerprint
  matched both the device certificate and the certificate captured through HTTPS.
  Inspection found no script, form, external reference or private key in that
  result, and no retired claim file in the fresh application or USB state.
- The result timestamp was approximately 83 seconds after boot. At the first
  post-setup SSH inspection, approximately 16 minutes after boot, the stick was
  unmounted and both installer locks were absent. The operator was then told it
  was safe to remove. This does not establish a universal five-minute removal
  timeout. The operator returned `PHAETON-RESULT.html` from the stick; all 1,817
  bytes exactly matched the staged result and its fingerprint matched the live
  certificate. It reported success with no setup code.
- The fresh install correctly required activation. For restoration of this same
  existing deployment, its backed-up signed license and installation identity
  were restored together. The fresh unlicensed identity was retained privately;
  the operator's new configuration and TLS identity were preserved. Normal
  license verification accepted the saved license and the driver ran offline.
  This is backup restoration, not a new portal activation or license issuance.
- After removal of the stick, another GX reboot automatically started Phaeton
  while internet remained blocked. Binary, run script, configuration, signed
  license, TLS certificate/private key and startup scripts were byte-identical;
  installation identity persisted and setup/configuration APIs remained protected.
- Original GX IPv6 settings were restored and the temporary early boot hook was
  removed. Private application and network-preparation backups were retained.
- The operator confirmed that booting with the stick inserted had also already
  been exercised. That case is not untouched work; the explicit newer-version
  preservation scenario remains separate.

This completes the supervised fresh offline/no-code installation, SSH-disabled
setup and restart-without-media cases on this one device, alongside the
operator-reported boot with media present. Explicit newer-version preservation,
physical interruption/fault-media cases, remaining hardware/media identification
and formal EN/NL novice trials remain open. No GX model is advertised as
USB-qualified.

Firmware-update persistence follows Victron's documented contract: image updates
leave `/data` intact, and `/data/rc.local` survives upgrades and starts custom
software. All persistent Phaeton installer/runtime files and the startup entry
use that partition. A firmware upgrade was not performed in this trial; the
known storage fault on this GX makes it unsuitable for an ordinary upgrade test.
That distinction records documented design support without claiming a measured
upgrade or requiring one on this damaged device to complete the implementation.
See [Victron's partition and startup-hook documentation](https://www.victronenergy.com/live/ccgx:root_access).

## Sources

- [Victron boot hooks and modification prerequisites](https://www.victronenergy.com/live/ccgx:root_access)
- [Pinned Venus removable-media implementation](https://github.com/victronenergy/meta-victronenergy/blob/79e6b43272d7b0e5913d9e2fee5ffe0732d9ee33/meta-venus/recipes-core/initscripts/files/update-data.sh)
- [SetupHelper blind installation precedent](https://github.com/kwindrem/SetupHelper#blind-install), reviewed 2026-09-08; no SetupHelper dependency or code copied.
