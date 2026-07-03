# Alfen Settings Checklist

Use this checklist when setting up an Alfen Eve charger for Phaeton, or when
Phaeton can read the charger but cannot control current or phase switching. It
is meant for practical support conversations, not as a replacement for Alfen's
ACE Service Installer documentation.

The hosted public version is available at:
`https://phaeton.virtunet.io/docs/alfen-settings`.

## Before You Start

You need access to the charger with Alfen ACE Service Installer using an account
that can change Smart Charging / Load Balancing settings. Some options are
installer-level or require the Active Load Balancing license to be present on
the charger.

For exact ACE Service Installer screens, use Alfen's
[Smart Charging functionalities, Active Load Balancing, and Smart Charging
Network](https://aceservice.alfen.com/en-us/knowledgebase/article/KA-01167)
article and its attached smart-charging documents.

Keep site safety limits under the control of the responsible installer. Do not
raise a safe current, station limit, or phase-switching option beyond what the
installation, charger, and vehicle can safely support.

## Required Alfen Settings

In ACE Service Installer, check the Alfen Smart Charging / Load Balancing pages:

| Area | Setting | Expected value for Phaeton |
| --- | --- | --- |
| Active balancing | Active Load Balancing | Enabled and licensed |
| Active balancing | Data Source | Energy Management System |
| Active balancing | Safe current | Set to a safe site-specific fallback current |
| TCP/IP EMS | Mode | Socket for a single Phaeton-controlled charger |
| TCP/IP EMS | Validity time | `300 s` recommended, and always longer than Phaeton's current update interval |
| Modbus TCP/IP | Allow reading | Enabled |
| Modbus TCP/IP | Allow writing maximum currents | Enabled |
| Active balancing | Allow 1- and 3-phased charging | Enabled when Phaeton may switch phases |

The default Phaeton current update interval is `30000 ms`. Alfen's default
validity time of `60 s` is enough for the default interval, but `300 s` gives a
more comfortable field margin while still allowing the charger to fall back to
safe current if Phaeton goes offline. If the site uses a shorter validity time
or a longer Phaeton update interval, make the validity time comfortably longer
than the Phaeton interval.

For double-socket Alfen chargers, add and validate each controlled socket
separately. The first socket, or a single-socket charger, uses socket slave ID
`1`; the second socket uses socket slave ID `2`.

Safe current is the charger's fallback when EMS setpoints expire or Phaeton is
offline. It must be configured before Alfen will reliably accept maximum-current
writes.

Only enable `Allow 1- and 3-phased charging` when the physical installation and
charger configuration support it. If this Alfen checkbox is unavailable or
intentionally disabled, leave Phaeton Auto 1P/3P switching disabled and do not
use the manual phase toggle as a troubleshooting signal.

## Phaeton Checks

After saving the charger settings, open Phaeton:

1. Go to `Configuration -> Charger`.
2. Select the built-in `alfen-eve` profile.
3. Confirm the charger IP address and Modbus TCP port, usually `502`.
4. Run the charger connection test.
5. Run `Test Alfen Control`.

`Test Alfen Control` should report that Alfen control is accepted. The most
important checks are:

- the current setpoint readback matches the value Phaeton wrote
- the EMS validity timer is active
- the Active Load Balancing safe current is configured
- Alfen reports that the Modbus setpoint is accounted for

If the connection test succeeds but `Test Alfen Control` says the setpoint is
not accounted for, Phaeton can reach the charger, but the charger is not using
Phaeton as the EMS controller. Re-check Active Load Balancing, Data Source =
Energy Management System, TCP/IP EMS mode, write permission for maximum
currents, validity time, and safe current.

## Symptom Checklist

### Phaeton Can Read The Charger But Current Does Not Change

Check:

- Active Load Balancing is enabled and licensed.
- Data Source is `Energy Management System`, not `Meter`.
- TCP/IP EMS mode is `Socket` for this setup.
- `Allow writing maximum currents` is enabled.
- Safe current is configured and greater than `0 A`.
- TCP/IP EMS validity time is longer than Phaeton's current update interval.
- `Test Alfen Control` reports `setpoint accounted: yes`.

### Charging Falls Back After A Short Time

This usually means the Alfen validity timer is expiring.

Check:

- TCP/IP EMS validity time is not shorter than Phaeton's current update
  interval.
- Phaeton is running continuously and logs do not show charger reconnect loops.
- The charger and Phaeton remain on the same network without firewall or Wi-Fi
  interruptions.
- `Test Alfen Control` shows a positive validity time after the write.

### Phase Switching Fails

Check:

- `Allow 1- and 3-phased charging` is enabled in the Alfen Active balancing
  menu.
- The Phaeton charger profile is still `alfen-eve` or a custom profile with the
  Alfen phase register correctly mapped.
- The installation supports both 1-phase and 3-phase charging.
- Phaeton logs do not contain `Phase switching support probe failed`.

After changing the Alfen checkbox, try the phase change again from Manual mode
before judging Auto mode. Auto mode may wait for phase-switch timers, solar
surplus, schedule windows, or battery SoC rules.

Phaeton intentionally verifies phase-switch support with a write and read-back
instead of inferring support from voltage readings. Even when the Alfen setting
is enabled, phase switching can fail or synchronize slowly, so use the Manual
mode test and read-back result as the source of truth.

## Support Bundle

When asking for help, include enough evidence to avoid guessing:

- Phaeton version and platform, for example Cerbo GX or Raspberry Pi.
- Alfen model, firmware version, and whether Active Load Balancing is licensed.
- A screenshot of Alfen `Active balancing` showing Active Load Balancing, Data
  Source, safe current, and the 1-/3-phase checkbox.
- A screenshot of Alfen `TCP/IP EMS` showing mode and validity time.
- A screenshot or copied text from Phaeton `Test Alfen Control`.
- Phaeton full log from `Logs -> Download full log`; enable temporary `DEBUG`
  capture from the Logs view while reproducing the issue when possible.
- Alfen charger logs or event export when available.
- The exact time of the test and what was expected, for example "Manual 6 A did
  not change the charger" or "switch to 1 phase failed".

Redact passwords, tokens, public IP addresses, and customer-specific network
details before sharing logs or screenshots outside the trusted support boundary.
