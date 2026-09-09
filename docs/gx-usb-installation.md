# GX USB installation / GX USB-installatie

**USB is the recommended way to install Phaeton on a GX.** Copy one installer
file to a stick, restart the GX, then finish in your browser. No SSH, terminal
commands or setup code are needed. The installer is for 32-bit ARMv7 Venus OS,
including Cerbo GX, and Phaeton 0.58.0 or later.

**USB is de aanbevolen manier om Phaeton op een GX te installeren.** Kopieer één
installatiebestand naar een stick, herstart de GX en rond de setup af in je
browser. Geen SSH, terminalopdrachten of setupcode nodig. De installer is voor
32-bits ARMv7 Venus OS, waaronder Cerbo GX, en Phaeton 0.58.0 of nieuwer.

## English instructions

You need physical access to the GX, an empty USB stick and a computer with
internet to download the installer. Use the same trusted local network as the
GX for browser setup. The GX itself does not need internet during installation.

### 1. Download the installer

Open [Install Phaeton](https://phaeton.virtunet.io/install) and select
**Download GX USB installer**. The file is named
`venus-data-phaeton-VERSION-armv7.tgz`. Keep it unopened: do not extract or rename
it. A `.phaeton-update` file is for updating an existing installation.

If the USB download is temporarily unavailable, return later or use the guide's
**Advanced installation with SSH** section.

### 2. Copy it to the USB stick

Use a dedicated empty, writable **FAT32 stick with an MBR partition table and
at least 256 MB free**. Formatting erases its contents; save wanted files first.
Ask your installer for help preparing the stick if you are unsure about its
format. Do not use a GX logging stick.

Copy the unopened archive directly onto the USB drive, outside any folder.
There must be only one Phaeton installer on the stick. Eject it from your computer
when copying finishes.

```text
Downloads                         USB drive (top level)
venus-data-phaeton-….tgz   ───►    venus-data-phaeton-….tgz
                                 (no enclosing folder)
```

<details>
<summary>Copying on Windows, macOS or Linux</summary>

- **Windows:** use File Explorer to copy the archive from Downloads to the USB
  drive itself. Choose Eject before unplugging it.
- **macOS:** use Finder to copy the archive to the USB drive, then use the eject
  icon. In Safari, turn off **Open "safe" files after downloading** first;
  download again if it was already extracted.
- **Linux:** use your file manager to copy the archive from Downloads to the USB
  drive itself, then safely eject the drive.

</details>

### 3. Insert the stick and restart the GX

On the GX display or in Remote Console, check **Settings → General →
Modification checks → Modifications enabled**. Keep this enabled for automatic
startup. Menu names vary by firmware. You do not need to enable SSH or set a
root password.

Disconnect other removable storage. Insert the stick in a **data-capable USB
port**, not a power-only port intended for GX Touch. Restart at a time when it
will not interrupt charging or other essential work.

Allow **five minutes** for startup and wait for USB activity to stop. Do not
remove busy media or interrupt GX power. Five minutes alone is not proof of safe
removal. If you cannot confirm that the stick is safe to remove, leave it inserted
and contact support; you can continue browser setup with it present.

### 4. Open Phaeton and finish setup

Find the GX IP address under **Settings → Ethernet** or **Settings → Wi-Fi →
your connected network**. On the same trusted local network, open
`https://GX-IP:8088/`, replacing `GX-IP` with that address.

With the 0.59.0 installer, a fresh installation creates a persistent MQTT instance
and manages its Control Panel route automatically on supported GX systems. Open
**VRM → your installation → Device list → Phaeton EV Charging Station → Control
Panel**. Configure GX internet, VRM **Full** mode and account settings permission;
see the [GX settings and availability](gx-control-panel.md). Releases through
0.58.4 do not prepare this route automatically. The new automatic lifecycle and
completed remote activation/updates still require GX qualification. Use the
local address above for commissioning or whenever Control Panel is unavailable.

If your browser shows a privacy warning, Phaeton uses its own certificate.
After safely returning the stick to your computer, open **PHAETON-RESULT.html**
and compare its public **SHA-256 certificate fingerprint** with the browser's
certificate details before entering credentials. Stop if they differ. The result
is an offline status report with no setup credential. If it is missing, still
says **Installation in progress**, or reports failure, see [Recovery](#recovery--herstel).
This fingerprint check applies to local HTTPS; the VRM relay presents its own
HTTPS certificate.

Choose your administrator username and password, then follow the wizard to
configure the charger and GX connection. **No setup code is required.** Activate
from Phaeton using your portal account, which is separate from your local login.
Follow the [first-run setup guide](user_guide.md#first-run-onboarding).

Online activation requires connectivity. An offline GX can exchange activation
request and license files using a computer with internet. Check the dashboard
and connections before choosing to start a charging test.

**Already installed?** Open Phaeton and use **Software Updates**, including a
`.phaeton-update` upload for an offline update. USB installation preserves
existing installations and does not update them.

## Nederlandse instructies

Je hebt fysieke toegang tot de GX, een lege USB-stick en een computer met
internet nodig om de installer te downloaden. Gebruik voor de setup hetzelfde
vertrouwde lokale netwerk als de GX. De GX zelf heeft tijdens de installatie
geen internet nodig.

### 1. Download de installer

Open [Phaeton installeren](https://phaeton.virtunet.io/install?lang=nl) en kies
**GX USB-installer downloaden**. Het bestand heet
`venus-data-phaeton-VERSIE-armv7.tgz`. Laat het ongeopend: pak het niet uit en
hernoem het niet. Een `.phaeton-update`-bestand is voor een bestaande installatie.

Is de USB-download tijdelijk niet beschikbaar, kom dan later terug of gebruik
**Geavanceerde installatie via SSH** in de handleiding.

### 2. Kopieer het bestand naar de USB-stick

Gebruik een aparte lege, schrijfbare **FAT32-stick met een MBR-partitietabel en
minstens 256 MB vrije ruimte**. Formatteren wist de inhoud; bewaar gewenste
bestanden eerst ergens anders. Vraag je installateur om hulp als je twijfelt
over het formaat. Gebruik geen GX-logstick.

Kopieer het ongeopende archief rechtstreeks naar het USB-station, buiten een map.
Er mag maar één Phaeton-installer op de stick staan. Werp de stick uit via je
computer zodra het kopiëren klaar is.

```text
Downloads                         USB-station (hoofdniveau)
venus-data-phaeton-….tgz   ───►    venus-data-phaeton-….tgz
                                 (niet in een map)
```

<details>
<summary>Kopiëren op Windows, macOS of Linux</summary>

- **Windows:** kopieer het archief in Verkenner vanuit Downloads rechtstreeks
  naar het USB-station. Kies Uitwerpen voordat je de stick loskoppelt.
- **macOS:** kopieer het archief in Finder naar de USB-stick en gebruik daarna
  het uitwerpsymbool. Schakel in Safari eerst **Open veilige bestanden na
  downloaden** uit; download opnieuw als het al is uitgepakt.
- **Linux:** kopieer het archief in je bestandsbeheerder vanuit Downloads
  rechtstreeks naar het USB-station en werp het station daarna veilig uit.

</details>

### 3. Plaats de stick en herstart de GX

Controleer op het GX-scherm of in Remote Console: **Instellingen → Algemeen →
Modification checks → Modifications enabled**. Laat dit aanstaan voor automatisch
starten. Menunamen verschillen per firmware. Je hoeft SSH niet in te schakelen
of een rootwachtwoord in te stellen.

Koppel andere verwisselbare media los. Plaats de stick in een **USB-poort met
data**, niet een poort die alleen GX Touch van stroom voorziet. Herstart op een
geschikt moment, zonder laden of ander essentieel werk te onderbreken.

Geef de installatie **vijf minuten** om te starten en wacht totdat de USB-activiteit
stopt. Trek geen actieve stick uit en onderbreek de GX-voeding niet. Vijf minuten
wachten alleen bewijst niet dat verwijderen veilig is. Weet je dit niet zeker,
laat de stick dan zitten en neem contact op met support; je kunt de setup in de
browser afronden terwijl de stick nog is geplaatst.

### 4. Open Phaeton en rond de setup af

Zoek het GX-IP-adres bij **Instellingen → Ethernet** of **Instellingen → Wi-Fi →
je verbonden netwerk**. Open op hetzelfde vertrouwde lokale netwerk
`https://GX-IP:8088/` en vervang `GX-IP` door dat adres.

De installer van 0.59.0 maakt bij een nieuwe installatie een vaste MQTT-instantie
aan en beheert de Control Panel-route automatisch op ondersteunde GX-systemen.
Open **VRM → je installatie → Device list → Phaeton EV Charging Station → Control
Panel**. Hiervoor zijn GX-internet, VRM **Full** en wijzigingsrechten nodig.
Versies tot en met 0.58.4 bereiden deze route niet automatisch voor. De nieuwe
automatische werking, voltooide activering en updates op afstand moeten nog op
GX worden geverifieerd. Gebruik voor het in bedrijf stellen het lokale adres
hierboven, ook als Control Panel ontbreekt. Je VRM-account, lokale Phaeton-login
en Phaeton-portalaccount staan los van elkaar. Zie de
[GX-instellingen en beschikbaarheid](gx-control-panel.md).

Voor VRM-toegang: verbind de GX met internet en open **Instellingen → VRM →
VRM Portal** (oudere interface: **VRM online portal**). Kies **Full** als de
eigenaar configuratie op afstand wil toestaan. Controleer in hetzelfde menu
**Last contact** en eventuele verbindingsfouten. Je VRM-account moet instellingen
mogen wijzigen. Laat **Modifications enabled** aanstaan voor Phaeton. De lokale
MQTT-services moeten draaien; Phaeton 0.59.0 beheert op ondersteunde installaties
zijn eigen route. Voor gebruik van Control Panel zijn geen SSH op LAN, Remote Support of
poortdoorschakelingen nodig. Behoud het bestaande lokale beveiligingsprofiel.

Je browser kan een privacywaarschuwing tonen omdat Phaeton een eigen certificaat
gebruikt. Open na veilige verwijdering van de stick **PHAETON-RESULT.html** op je
computer. Vergelijk de openbare **SHA-256-certificaatvingerafdruk** met de
certificaatdetails in je browser voordat je inloggegevens invoert. Stop als ze
verschillen. Het resultaat is een offline statusrapport zonder setupgeheim.
Ontbreekt het, staat er nog **Installatie bezig** of wordt er een fout gemeld,
bekijk dan [Herstel](#recovery--herstel).
Deze vergelijking geldt voor lokale HTTPS; de VRM-relay toont een eigen
HTTPS-certificaat.

Kies je lokale beheerdersnaam en wachtwoord en volg de wizard voor de laadpaal-
en GX-verbinding. **Er is geen setupcode nodig.** Activeer vanuit Phaeton met je
portalaccount; dat staat los van je lokale login. Volg de
[handleiding voor de eerste setup](https://phaeton.virtunet.io/docs/first-run-onboarding?lang=nl).

Online activering vereist verbinding. Een offline GX kan aanvraag- en
licentiebestanden uitwisselen via een computer met internet. Controleer het
dashboard en de verbindingen voordat je bewust een laadtest start.

**Al geïnstalleerd?** Open Phaeton en gebruik **Software Updates**, ook voor een
offline update via een `.phaeton-update`-bestand. De USB-installer behoudt
bestaande installaties en werkt ze niet bij.

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
| Storage / Opslag | Free space using GX settings or contact support. Preserve Phaeton data. | Maak ruimte via GX-instellingen of neem contact op met support. Behoud Phaeton-gegevens. |
| Modifications disabled / Wijzigingen uit | Enable modifications in GX settings and restart with the stick. | Schakel wijzigingen in via GX-instellingen en herstart met de stick. |
| Failed write / Schrijffout | Restart with the same installer to resume. If the stick is failing, copy the same release's unopened installer to a new writable FAT32 stick, disconnect the old one, and retry. Existing configuration and identity are preserved. | Herstart met dezelfde installer om te hervatten. Kopieer bij een defecte stick dezelfde ongeopende installer naar een nieuwe schrijfbare FAT32-stick, koppel de oude los en probeer opnieuw. Bestaande configuratie en identiteit blijven behouden. |
| Failed startup / Start mislukt | Check for another service on port 8088; retry by rebooting. If it repeats, contact support with the non-secret error text only. | Controleer of poort 8088 bezet is en herstart. Neem bij herhaling contact op met support met alleen de niet-geheime fouttekst. |
| Existing installation / Bestaande installatie | Nothing is replaced, including newer releases. Open that installation's web interface. Use its updater, not the USB installer, to change versions. | Er wordt niets vervangen, ook geen nieuwere release. Open de bestaande webinterface en gebruik die voor updates. |
| Another installer / Andere installer | Restart and retry. Persistent unrecognized SSH locks require support; USB never deletes them. | Herstart en probeer opnieuw. Een blijvende onbekende SSH-lock vereist support; USB verwijdert deze nooit. |

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
also builds and attaches the archive as the recommended GX installation download.
No signing key is placed in the USB archive. The outer boot hooks run with physical-media
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

The installer requires the GX's existing Python 3 standard library, OpenSSL,
curl, flock and basic shell/file utilities. Python supplies atomic lock creation
and bounded subprocess groups when Venus's reduced BusyBox lacks `timeout`.
No package installation or root filesystem changes are performed. Prepared
recovery checks the exact installed executable and needs only 1 MiB of workspace;
it does not restage the release or reset configuration/identity.

The portal's same-origin `/downloads/venus-data-phaeton.tgz` route is disabled
by default. Operators may pin `GX_USB_INSTALLER_VERSION=X.Y.Z` after the asset
is published to enable the customer download. Versions before 0.58.0 are refused
because they still require the retired setup code. It streams only that fixed official
release and preserves the required archive filename. Keep the environment
variable unset when no USB download is being offered; the guide then explains
unavailability and links to SSH. Publish/update the instructions through the curated
public GitHub sync. No portal deployment or release publication is implied by
merging this implementation.

For the repository's deployment helper, supply the corresponding optional
`PHAETON_PORTAL_STAGING_GX_USB_INSTALLER_VERSION` or
`PHAETON_PORTAL_PRODUCTION_GX_USB_INSTALLER_VERSION` variable. It is copied to
the Worker's `GX_USB_INSTALLER_VERSION` binding. No value is committed by default.

### Download availability check, 2026-09-09

The initial check found public release `v0.52.1` without a USB asset. A follow-up
after publication of [v0.58.4](https://github.com/virtunetbv/phaeton/releases/tag/v0.58.4)
at 09:25:49 UTC confirmed that its
[USB archive](https://github.com/virtunetbv/phaeton/releases/download/v0.58.4/venus-data-phaeton-0.58.4-armv7.tgz)
is publicly downloadable with the correct filename. The
[live installation page](https://phaeton.virtunet.io/install) still offers no
download link and its download endpoint still returns 404. A new USB package
is no longer needed to enable that version; the portal version pin remains.

There are three immediate distribution options:

| Option | Action | Operational effect |
| --- | --- | --- |
| **Normal portal deployment (recommended)** | Set `PHAETON_PORTAL_PRODUCTION_GX_USB_INSTALLER_VERSION=0.58.4` in the deployment environment, then run `portal_deploy_production` from reviewed main. Use the corresponding staging variable and job to check it first. | Enables the site's button and stable download URL through the existing deployment process. |
| **Cloudflare variable change** | On the production Worker, set the text binding `GX_USB_INSTALLER_VERSION` to `0.58.4` and deploy the configuration change. Also persist the same value in the deployment environment. | Enables the existing route without application source changes. A later scripted deployment rebuilds the bindings, so a dashboard-only value can disappear. |
| **Direct release download** | Download the official v0.58.4 USB archive linked above. | Usable immediately; does not enable the Phaeton site's button. Follow the same USB preparation instructions. |

The version value has no `v` prefix. The deployment helper also accepts
`PORTAL_GX_USB_INSTALLER_VERSION`, which takes precedence over the environment-
specific variable; remove a conflicting override or set it to the same version.
The Worker accepts only plain `X.Y.Z` versions at least 0.58.0 and fetches a
fixed GitHub release path. Private CI trial artifacts and trial-tag suffixes
cannot be selected by this binding. It deliberately does not follow `latest`.

After enabling the pin, check both guide languages, perform a full download,
confirm HTTP 200 and the expected filename, and compare the downloaded archive
with the release asset. The curated public GitHub sync must also carry the
current guides. To withdraw the site download, remove the binding and redeploy;
the existing guide will show it as unavailable. Changing this documentation
does not deploy any of these options.

### General-use release decision, 2026-09-09

On 2026-09-09, the product owner approved USB installation for general use and
selected it as the recommended method. This replaces the trial-only guidance and
the earlier novice-trial prerequisite for choosing the default. SSH remains an
advanced option. Operators still select the release offered by the download route.

No additional hardware tests ran for this documentation change. The record below
lists the tested configurations and remaining hardware and usability checks.

### Hardware verification record

| GX / firmware | State | Evidence |
| --- | --- | --- |
| Cerbo GX (`einstein`, device-tree identifier `victronenergy,cerbo-gx-b1`), Venus `v3.80~39` | Fresh 0.58.0 USB installation and first-account creation with SSH disabled and internet blocked; licensed restart without USB passed | Supervised trials below; remaining physical qualification cases are still pending |
| Cerbo GX MK2, exact revision + Venus version to be selected | Not tested | No compatibility claim |
| Other GX models / firmware | Not tested in the recorded trials | No additional hardware-test claim |

For each additional model/firmware verification, record hardware revision,
firmware version, USB make/capacity/filesystem/port, SHA-256 of the installer,
installer release, SSH-disabled proof, timings, result screenshots, and the exact
safe-removal procedure. The original qualification checklist remains a record of
verification work, with completed cases identified in the trials below:

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
  the original acceptance target was at least four reaching the dashboard without
  facilitator intervention. Record failures and revise the instructions; this
  remains usability follow-up after the general-use release decision above.

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
and formal EN/NL novice trials remain open. This trial does not establish
complete qualification for every GX model or firmware combination.

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
