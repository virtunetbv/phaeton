# GX USB installer independent review — 2026-09-08

Issue: [#384](https://gitlab.virtunet.io/virtunet/phaeton/-/work_items/384).

**Scope update:** after the historical code-based hardware trial below, the
product owner explicitly selected direct first-visit administrator creation with
no setup code. [ADR 0053](https://gitlab.virtunet.io/virtunet/phaeton/-/blob/main/docs/adr/0053-create-first-admin-directly-without-a-setup-code.md)
records that different trust model. The original claim-based conclusions do not
apply to it; a focused review of the updated implementation is recorded next.

## Updated first-visit account review

The independent reviewer found **no actionable findings** in the updated flow.
It verified the per-instance completion mutex, state recheck through persistence,
post-setup authentication/session invalidation, and the USB status/fingerprint-only
result. It independently passed 18 Rust wizard tests, five wizard JavaScript
tests, 23 USB fixture tests, formatting, budgets and whitespace checks.

The implementer also passed the real HTTPS runtime regression: no code is
generated or required, retired files are cleaned up, TLS identity persists, and
setup cannot reset credentials after completion or restart. This flow trusts
network access until the first account is created. It is intentionally different
from proving possession of private physical-media authorization.

The new USB builder refuses releases older than 0.58.0. The old v0.57.0 archive
identified below continues to represent only the earlier code-based trial.

## Private trial packaging follow-up

The same independent agent reviewed the added trial-signing path, CI job
selection, artifact rules and SSH handoff after integration with current main.
It found no actionable findings and independently passed 25 USB fixture tests,
13 SSH installer tests, 10 portal installation tests, ShellCheck, shell syntax
and whitespace checks. Read-only GitLab inspection confirmed protected `v*` tags
require Maintainer access. The reviewer did not inspect the production signing
key, execute the real signing job, or test artifact access using other accounts;
the artifact access setting alone does not establish isolation from CI job tokens
or downstream artifact forwarding.

Implementation-side CI subsequently passed on `fe57e03`, including the complete
MR pipeline and protected `v0.58.0-usb-trial.1` pipeline. The real private signing
job succeeded, and the downloaded archive independently passed signature,
payload and reviewed-source comparison. The fresh 2026-09-09 supervised trial
reached first-account setup with SSH disabled and internet blocked, then passed
post-setup authorization and licensed restart without the stick. Exact artifact
digests, CI links, observations and remaining physical limits are in the
[qualification record](gx-usb-installation.md). These later results were obtained
by the implementer and operator, not by the blind reviewer.

## Review independence

At the operator's request, a separate reviewer agent received the issue and
repository instructions with no implementation conversation or rationale. It
reviewed the code before consulting the new design documents, reproduced
findings independently, and did not edit files or access the physical GX.
This is an independent agent review, not an external audit or hardware qualification.

## Findings and corrections

| Severity | Finding | Correction and regression evidence |
| --- | --- | --- |
| P1 | Readiness queried `/api/setup`, which is not the setup-status route. A permissive curl mock concealed the failure. | Use `/api/setup/status`, verify TLS with the actual device certificate, and distinguish HTTP status from response content. Real-runtime HTTPS test passes. |
| P1 | Bootstrap persists default `config.yaml` before setup, so treating any config as completed blocked claim recovery. | Permit owned, prepared installations with the exact executable to recover the handoff. Decide claim eligibility using live setup status; suppress stale claims after completion. |
| P2 | Payload preceded the veto hook; Venus ignores errors extracting `rc`, allowing truncated archives into generic `/data` extraction. | Put the pre-hook first and payload last. Reviewer reproduced direct compressed-prefix truncation through the pinned Venus wrapper and confirmed extraction is vetoed. |
| P2 | Rewriting `rc.local` with mode 0755 widened access to an existing private startup script. | Preserve ownership and read permissions; add only owner execute permission. New startup files use 0700. |
| P1 | Enabling autostart before making preparation durable left a boot/config interruption window. | Sync the prepared marker before changing `rc.local`; use a separate durable autostart marker. Resume incomplete activation without reinstalling the executable. |
| P2 | Prepared handoff recovery still required space for another complete release. | Use a bounded 1 MiB workspace requirement and skip payload restaging for an eligible prepared executable. Regression covers absent staging payload and limited free space. |
| P2 | The GX timeout fallback initially left child processes alive when the helper received SIGTERM/SIGINT. | Forward cancellation by killing and reaping the private process group, including signals arriving during process creation. Tests cover both signals and delayed descendant writes. |

The first six fixes passed focused re-review with no remaining actionable
findings before physical preflight. That preflight found the trial GX's reduced
BusyBox lacks `timeout` and `ln -T`. The bundled standard-library Python helper
provides bounded subprocess groups and atomic no-replace symlinks using the
already installed interpreter; it installs no system packages. Its additional
cancellation finding was corrected. Final focused re-review found **no remaining
actionable findings**, supporting a supervised hardware trial.

## Validation and limits

- Reviewer independently ran 22 signed-fixture installer tests, the opt-in real
  HTTPS runtime test, ShellCheck and whitespace checks before the platform change.
- Runtime regression starts a native executable with temporary data on loopback,
  checks restart preservation, completes setup, restores a stale claim file,
  checks suppressed export, and confirms claim replay is rejected.
- Platform tests cover atomic lock creation, existing directory/file/symlink
  preservation, timeout/status handling, descendants, missing native `timeout`,
  and termination cleanup.
- Final independent helper review passed four platform tests and all 22 installer
  fixture cases with Python fallback forcibly selected, plus direct SIGTERM/SIGINT
  cancellation reproductions, ShellCheck and whitespace checks. The implementer
  also passed all 32 focused GX tests (22 USB fixtures, four platform helpers,
  one real-runtime HTTPS case and five existing SSH installer cases).
- Implementation-side physical preflight identified Cerbo GX (`einstein`), Venus
  `v3.80~39`, ARMv7, Python 3.12.13 and OpenSSL 3.5.5. Harmless temporary-directory
  helper checks passed on that device. Its removable-media script SHA-256 is
  `98a15d06ec4d10d6974cd72e5abfcd353e0b495b07205a9b0483dec8626d972e`.
- The supervised trial archive contains the signature-verified v0.57.0 ARMv7
  release and reviewed installer. Its filename is
  `venus-data-phaeton-0.57.0-armv7.tgz`, size 8,246,410 bytes, SHA-256
  `c46a237169f281c6f638ff63e056dbd7570f7041698d9ef3c140c06a57f132e6`.
  This identifies the locally built trial artifact; no release was published.

The outer archive and its hooks execute with physical-media root authority.
Bundled payload verification cannot authenticate a replaced hook and trust
anchor; authentic first-party distribution and custody of the stick remain
prerequisites. FAT32 privacy likewise depends on custody. No private signing or
device TLS key is exported. For the historical 0.57.0 trial only, the unused setup
claim was private bearer authorization and had to be deleted from the stick;
the current 0.58.0 installer generates no such claim.

This review does not establish removable-media boot compatibility, interrupted
power durability, safe-removal timing, firmware-update survival, or novice
usability. Those remain in the [qualification checklist](gx-usb-installation.md).
The blind reviewer did not run heavyweight CI or perform physical qualification.
Subsequent implementer/operator CI and supervised hardware evidence is recorded
separately above; it does not complete the qualification checklist.
