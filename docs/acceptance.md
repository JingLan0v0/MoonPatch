# Acceptance evidence

## Local evidence (2026-10-01)

`node scripts/verify.mjs` completed successfully with MoonBit
`0.10.14+7d59c7ec9` on the JS target and Node.js 24. It runs:

- `moon fmt --check`, `moon check --target js`, `moon test --target js`,
  `moon info --target js`, and CLI build;
- eight MoonBit unit tests covering pointers, the six operations, atomic
  failure, numeric equality, movement and malformed inputs;
- three end-to-end examples with committed expected JSON;
- real CLI subprocess tests for stdin, BOM, UTF-8 failures, diagnostics,
  16 MiB input limit and version;
- **108/108 enabled** cases from the vendored Apache-2.0
  [json-patch-tests](https://github.com/json-patch/json-patch-tests) at
  `2a928f9044aad35c74e2788d498bcf2c6b91adea`.

The upstream suite has 112 records; four are explicitly marked `disabled`
and are skipped. This evidence is local only. It does not prove GitHub CI,
Mooncakes publication, October initial review, final acceptance, or payment.

The code commit `dc2a832` was verified in the working tree and again from a
fresh `git archive` extraction. The archive excludes `.git`, `_build`, local
toolchains, credentials and temporary caches. A later documentation-only
commit does not change the tested code; verify a new code commit separately.

## External evidence to add after publication

| Check | Expected evidence | Current state |
|---|---|---|
| Public repository | Root URL and remote SHA | Not created |
| Windows and Ubuntu CI | Action run for the same SHA | Not run remotely |
| Mooncakes | Public `JingLan0v0/moonpatch` page and exact version | Not published |
| Fresh consumer | New module installs released version and applies a patch | Not run |
| October application | Form receipt and organizer response | Participant/organizer action |

Never replace these states with inferred success. Update the table with links
and the exact commit SHA when each external check finishes.
