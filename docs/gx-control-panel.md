# Phaeton through VRM Control Panel

Phaeton 0.59.0 adds managed Control Panel access on GX. This lets you open the
Phaeton interface remotely through **VRM → Device list → Phaeton EV Charging
Station → Control Panel**, including setup and activation.

This document describes the 0.59.0 implementation. Releases through 0.58.4 do
not install this route automatically. The earlier supervised trial established
remote setup and login on a Cerbo GX with Venus `v3.80~39` and
`dbus-mqtt-integrations 1.4.1-r0`. The new automatic lifecycle, completed remote
license activation, licensed charging dashboard and remote software updates
still require verification on GX before release qualification is claimed.

## Installation requirements

- A fresh installation made by the 0.59.0 USB or GX SSH installer, or an existing
  named MQTT instance upgraded to 0.59.0. Fresh installers create the persistent
  `default` instance in `/data/phaeton`; its HTTPS port remains 8088.
- Venus OS with its local MQTT broker on `127.0.0.1:1883`,
  `dbus-mqtt-integrations`, and the standard nginx include directory
  `/run/nginx/sites-enabled`. Phaeton must run with permission to manage that
  directory and gracefully reload nginx, as in the normal GX installation.
- The Phaeton web host must be `0.0.0.0` or `127.0.0.1`, so its own verified
  HTTPS service is reachable over loopback. Keep the normal authentication
  enabled and choose your own administrator password during setup.

Existing default installations using Modbus keep their configuration and GX
registration when updated. They are not automatically migrated. The enable
command below does not perform a migration. Do not add a separate probe beside
an existing charger to obtain a second Control Panel entry. A migration must
preserve the existing charger configuration, license and registration; it is
outside this installation path. Named instances are described in
[Multiple chargers](multiple-chargers.md).

## Configure the GX

Use the GX display or Remote Console. Menu labels differ between Venus versions.

| Setting | Required action |
| --- | --- |
| **Settings → Connectivity → Ethernet / Wi-Fi** (older UI: directly under **Settings**) | Give the GX an internet connection. USB installation itself can remain offline. |
| **Settings → VRM → VRM Portal** (older UI: **VRM online portal**) | Select **Full** for remote configuration. |
| **Settings → VRM → Last contact** | Check for recent successful contact. Add the GX to the intended VRM installation if necessary. |
| **Settings → General → Modification checks → Modifications enabled** | Keep enabled so Phaeton starts after reboot. |
| VRM installation permissions | The signed-in VRM account must be allowed to change settings. |

Phaeton uses MQTT internally on GX. **Settings → Integrations → MQTT Access**
(older UI: **Services → MQTT on LAN**) and network-device pairing control LAN
access; enabling them does not create the Phaeton web route. Keep the owner's
existing local network security profile. The route uses Venus-managed remote
access and needs no router port forwarding, Remote Support or SSH on LAN.

Victron documents [VRM connectivity and access](https://www.victronenergy.com/media/pg/Cerbo_GX/en/vrm-portal.html),
[GX security settings](https://www.victronenergy.com/media/pg/Cerbo_GX/en/the-new-user-interface.html)
and the [EVCS Control Panel button](https://www.victronenergy.com/media/pg/EV_Charging_Station/en/description-and-features.html).

## Open Phaeton

1. Start Phaeton and allow GX/VRM to refresh its device list. Phaeton waits
   17 seconds before MQTT registration on startup so the previous GX lease expires.
2. In VRM, select the installation, open **Device list**, expand the intended
   Phaeton EV Charging Station and select **Control Panel**. During onboarding
   its name is **Phaeton - setup / activation**. After authorized restart it
   becomes **Phaeton EVCS**, using the same serial and device identity.
3. Create your administrator account on first setup, or sign in with your
   existing Phaeton credentials. No setup code is required. Your VRM login,
   Phaeton administrator and Phaeton licensing-portal account are separate.
4. Complete setup and activation, following Phaeton's restart prompts. Setup,
   recovery and missing runtime authorization keep physical polling and charging
   controls inhibited for that process. Remote visibility does not authorize
   charging. Use local HTTPS for commissioning while the remote lifecycle is
   awaiting GX qualification.

**Remote Console** opens the GX interface. **Control Panel** opens Phaeton.
Always follow the Control Panel button for the correct instance instead of
bookmarking a temporary relay address.

## What Phaeton manages

Each instance uses its existing MQTT identity throughout onboarding and normal
operation. Phaeton adds one marked nginx include for a dedicated address in
`127.77.0.0/16`, forwarding to its own loopback proxy and then to its own HTTPS
service. The upstream certificate is verified; application authentication,
cookies and security headers remain in force. Requests cannot choose a
different upstream host, port or instance. The `/login.htm` VRM entry redirects
to Phaeton's normal root page.

This **does add GX nginx configuration**. Phaeton validates before graceful
reload and restores the previous owned files if validation or activation fails.
It checks the route every 30 seconds and repairs its include after reboot or
Venus regeneration. A collision, unsupported layout or permission failure is
reported without preventing local HTTPS or normal authorized charging.
Phaeton does not change the GX security profile, VRM permissions, firewall,
remote tunnel settings or vendor nginx files.

## Check, disable or remove access

Run commands in the GX terminal with the instance's data directory. For the
default USB installation:

```sh
PHAETON_DATA_DIR=/data/phaeton /data/phaeton/phaeton --control-panel status
PHAETON_DATA_DIR=/data/phaeton /data/phaeton/phaeton --control-panel disable
```

Disable persists `gx-management.disabled` and removes the exact owned nginx
route. If nginx cannot be validated/reloaded, the command reports failure and
the preference still prevents reinstallation. Resolve that failure before
deleting Phaeton's files. Restart Phaeton to refresh GX discovery metadata.
To enable again:

```sh
PHAETON_DATA_DIR=/data/phaeton /data/phaeton/phaeton --control-panel enable
```

Restart Phaeton after enabling. For named deployments, substitute that instance's
directory and executable. Before uninstalling an instance, disable its route
successfully, then stop it and remove its own autostart entry. Preserve other
instances and GX startup commands. No blanket deletion of nginx includes is needed.

## Troubleshooting and local fallback

- Missing button: check GX internet, VRM **Full**, permissions, Phaeton version
  and whether this is a supported MQTT deployment. An EVCS entry alone does not
  establish remote web access.
- GX page or connection failure: inspect `--control-panel status` and Phaeton
  logs. `ready` confirms the local route generation; it does not certify VRM
  cloud connectivity or account permissions. `gx-management-status.json`
  records the last status change. A reboot/profile change may need a 30-second
  reconciliation interval plus GX/VRM refresh time.
- Continue at `https://GX-IP:8088/` on the LAN, or the named instance's assigned
  web port. For a local certificate warning, compare its fingerprint with the
  USB result or installer output. The VRM relay uses its own HTTPS certificate.
  Local operation does not depend on VRM availability.
