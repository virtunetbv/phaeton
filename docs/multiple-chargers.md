# Multiple Alfen chargers on one Victron GX

Phaeton 0.50 introduces named MQTT instances: one Phaeton process per physical
charger, with a separate EVCS identity in GX. Each instance owns its executable,
configuration, web UI, session history, logs and activation. The GX is the common
Auto-mode controller. Phaeton does not allocate the installation's shared power
budget.

This is deployment support with automated isolation tests. Simultaneous physical
charging and real Opportunity Loads/Dynamic ESS scheduling still require site
qualification; use the qualification procedure below.

## Installation

Use the signed 0.51.0 release or newer. From the GX shell, download the installer
once and assign a name and unused web port to each charger:

```sh
curl -fsSL https://raw.githubusercontent.com/virtunetbv/phaeton/main/scripts/install-gx.sh -o /tmp/install-phaeton.sh
sh /tmp/install-phaeton.sh --instance garage --web-port 8089
sh /tmp/install-phaeton.sh --instance driveway --web-port 8090
```

Names contain 1–32 lowercase letters, digits or hyphens and start with a letter
or digit. Named installations reserve port 8088 for the original installation.
The installer rejects a port assigned to another named instance, including one
that is currently stopped. Check that the port is also unused by other services.

| Instance | Executable and data directory | Web UI |
| --- | --- | --- |
| garage | `/data/phaeton-instances/garage` | `https://<gx-ip>:8089/` |
| driveway | `/data/phaeton-instances/driveway` | `https://<gx-ip>:8090/` |
| original, if installed | `/data/phaeton` | its existing web port |

For each new instance:

1. Open its web UI and complete the first-run credential wizard, using that
   instance's `setup-claim.json` obtained locally or over SSH. Compare its recorded
   certificate fingerprint with the browser certificate. Configure the correct
   Alfen IP and charger profile. Only one instance may target a physical
   charger; the installer cannot establish this before the wizard is completed.
2. Activate the instance using its normal online or offline activation flow.
   Each instance needs its own signed grant under the existing licensing model.
   Home accounts receive one free license and can buy additional licenses in the
   portal through Stripe Checkout. Select the intended license during activation.
3. Configure the installation current limits and verified phase capabilities.
4. Confirm that GX discovers two EVCS devices with distinct serial identities.
   The MQTT client IDs and device IDs are generated once and remain stable.
5. Select and qualify the GX controller before using Auto mode. The named
   deployment always enables MQTT control, so local Phaeton Auto decisions are
   suppressed. A charger in Auto waits for GX acquisition and targets.

The new MQTT instances do not modify legacy Modbus registrations. If replacing
an original installation for the same Alfen, first stop its charging and process
and remove its own autostart entry; never leave both controlling the same charger.
Retire the original EVCS registration in GX as part of that migration. Initializing
a named instance in an existing configuration/state directory is refused.

Victron's [Opportunity Loads beta](https://community.victronenergy.com/t/beta-turn-surplus-solar-into-useful-work-with-gx-opportunity-loads/58711)
provides coordinated surplus allocation through MQTT, including priorities for
multiple EV chargers. Its documented beta is mutually exclusive with Dynamic ESS.
Phaeton does not turn either feature on or implement an additional scheduler.
Manual operation requires fixed current limits sized for all simultaneously
active chargers and other site loads.

## Configuration, recovery and updates

`instance.json` stores the deployment name, web port and MQTT identity separately
from `config.yaml`. Those values, the MQTT control selection, and the instance's
state/log paths are reapplied at startup and during configuration changes. They
survive configuration reset, import and recovery. Treat the deployment file as
part of the installation, not as a configuration template to copy to a sibling.
Malformed deployment metadata stops startup rather than using legacy defaults.
Named web UIs use separate session cookies for their assigned ports, so logging
in or out of one instance does not replace another instance's browser session.

A process lock prevents a second process from running the same named data
directory. It is released by the OS after exit, crash or exec restart. Do not
remove the lock file while an instance runs.

Use each instance's web updater. Separate executable directories isolate update
staging, backups and exec restarts. Do not replace the two executables with links
to a shared writable binary. To rerun the installer for a named instance, stop
that instance first; a live instance's lock prevents installer replacement.
Reinstallation with the same name and port preserves its identity and data.
Existing unnamed installer usage remains supported.

Use 0.52.1 or newer for named-instance GX discovery. Earlier named deployments
generated MQTT device IDs containing hyphens, which Venus OS 3.80~39 rejects in
its D-Bus settings paths. The updated runtime maps these hyphens to underscores
for GX discovery while retaining the saved deployment identity, MQTT client ID
and license. If the GX MQTT integration is stuck retrying a failed discovery,
stop the affected old instances before restarting that integration with all
chargers idle. This briefly interrupts GX registration for every MQTT charger.

To start a stopped instance:

```sh
/data/phaeton-instances/garage/run.sh
```

When stopping or restarting manually, identify the process by its executable
under that instance's directory. Avoid commands that terminate every process
named `phaeton`. Each instance has its own managed block in `/data/rc.local`.
Installer invocations are serialized because they share that file and the port
map. If the installer is forcibly killed, verify it has exited before removing
`/data/.phaeton-install.lock` and retrying.

Back up the complete instance directory, including `instance.json` and `license/`.
Restore it to the same location for the same charger. Do not run a restored copy
alongside the original identity. Roll back named deployments only to releases
that support named instances (0.51.0 or newer).

## Testing with one physical charger

Create a separate dummy instance using the same signed release:

```sh
sh /tmp/install-phaeton.sh --instance demo --web-port 8091 --demo
```

Complete its normal setup. From version 0.52.0 the zero-power demo is free and
does not require activation or consume a home license or installer credit.
The license indicator shows **Demo · zero power**; no licensing heartbeat is sent.
Physical instances still require their own valid signed licenses. No Alfen IP
is needed for the demo. The immutable demo setting
selects an in-memory adapter and a fixed single-phase profile. Charger diagnostics
that could contact physical hardware are blocked. Configuration imports cannot
turn it into a physical adapter. The web UI and GX identify it as
**Phaeton demo (zero load)**.

Change its state while it runs:

```sh
PHAETON_DATA_DIR=/data/phaeton-instances/demo /data/phaeton-instances/demo/phaeton --demo-state connected
PHAETON_DATA_DIR=/data/phaeton-instances/demo /data/phaeton-instances/demo/phaeton --demo-state ready
PHAETON_DATA_DIR=/data/phaeton-instances/demo /data/phaeton-instances/demo/phaeton --demo-state offline
PHAETON_DATA_DIR=/data/phaeton-instances/demo /data/phaeton-instances/demo/phaeton --demo-state disconnected
```

The default is disconnected. Connected/ready represent an attached EV that draws
no power; start/stop and GX targets exercise waiting and control states. Offline
simulates a lost downstream connection. Measured current, power and total/session
energy remain zero in every state, including after commands and reconnects.
Requested current limits may be nonzero; they are never used as measurements.
Malformed state files report the dummy offline. Reinstall it with `--demo` again;
changing a deployment between real and demo modes is refused.

With one Alfen plus a dummy, verify discovery, separate controls, lease loss,
restart isolation and zero GX/VRM energy from the dummy. A dummy may receive an
allocation from GX, so use conservative real-charger limits during this test.
This does not qualify simultaneous physical charging or the site's shared limits.
Free demo operation also does not prove physical runtime license enforcement;
qualify signed activation and unlicensed physical startup separately.

## Qualification before shared Auto charging

Record the GX/Phaeton/Alfen versions, charger wiring and phase assignments, shared
site and per-phase limits, and the selected controller. Then verify:

- Both chargers have separate GX/VRM entries, measurements and session histories.
- A start, stop, current or phase request reaches only its intended Alfen.
- Restarting or updating one instance keeps the other registered and responsive;
  the restarted instance requires fresh GX acquisition after its startup delay.
- Disconnecting either Alfen revokes only its target. Losing the common broker
  revokes both targets and causes stopped/zero output through their drivers.
- With both EVs connected, varying PV production and household loads keeps the
  combined load within site and per-phase limits. Exercise insufficient surplus
  for two minimum-current sessions, priority allocation, and 1P/3P transitions.
- Repeat with the selected real GX scheduler. Passing a synthetic MQTT test does
  not qualify Opportunity Loads, cloud scheduling or linked-vehicle pairing.

Automated tests cover named deployment persistence, reset/recovery, process and
installer isolation, and two MQTT transports sharing one broker endpoint with
independent commands and restart leases. They do not substitute for the physical
qualification above.
