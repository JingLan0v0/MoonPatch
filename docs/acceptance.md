# Acceptance evidence

## Locally verified on 2026-10-19

`node scripts/verify.mjs` passed on MoonBit JS and Node.js 24. It ran formatting, compilation, 13 MoonBit unit tests, the public library API example, three complete CLI scenarios with forward and rollback round trips, real CLI process checks, and **108/108 enabled** cases of pinned [json-patch-tests](https://github.com/json-patch/json-patch-tests) at `2a928f9044aad35c74e2788d498bcf2c6b91adea`. Four upstream cases are explicitly disabled and skipped. The new receipt tests cover mixed operations, array moves, changed-result refusal, original error index, and root replacement.

`moon publish --dry-run` passed local package validation and extracted-package `moon check`. Mooncakes returned **202 Accepted: Dry run completed successfully; no changes made** for 0.2.0. The current CLI nevertheless exited nonzero after reporting this server status. The archive `_build/publish/JingLan0v0-moonpatch-0.2.0.zip` was inspected and contains source, documentation, tests and license, with no `_build` or credentials. This is a successful server-side preflight, not publication.

## External evidence, tied to exact versions

| Check | State |
|---|---|
| Public GitHub repository | [JingLan0v0/MoonPatch](https://github.com/JingLan0v0/MoonPatch) is public. Record new 0.2.0 remote SHA after push. |
| Windows and Ubuntu CI | Previous [run 36865850203](https://github.com/JingLan0v0/MoonPatch/actions/runs/36865850203) passed on older `722ff72`; new 0.2.0 commit requires its own result. |
| Mooncakes | Version 0.1.0 was previously published and verified. Version 0.2.0 is not yet verified as published. |
| Fresh consumer | New 0.2.0 installation and execution pending. |
| October registration | Initial proposal rejected for overlap with moonconfig and missing explanation of relationship. Revised form submission and organizer review are participant/organizer actions. |

Local tests, CI, registry publication, registration approval, completion acceptance, and payment are separate evidence levels. Do not replace any pending state with an inference.
