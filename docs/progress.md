# Project status and continuation

## Current state (2026-10-19)

- Local repository: `C:\Users\XJY\Desktop\MoonBit黑客松\moonpatch`; public target: https://github.com/JingLan0v0/MoonPatch.
- The organizer rejected the first October proposal for overlap with forey217/moonconfig and lack of disclosure. The GitHub link itself was accepted in the later notice.
- MoonPatch 0.2.0 adds guarded rollback receipts to its RFC 6902 engine. The API, CLI `--receipt`, tests, three round-trip examples and documentation are prepared. See [architecture](architecture.md), [comparison](moonconfig-comparison.md), and [application facts](application-facts.md).
- Actual GitHub, CI, Mooncakes 0.2.0, and fresh-consumer state are recorded only after verification in [acceptance](acceptance.md). Do not infer them from local tests.
- The participant must update the Feishu form by 2026-10-31 for reconsideration. Organizer acceptance and payment remain external decisions.

## Resume checklist

1. Read this file, [competition requirements](competition.md), [comparison](moonconfig-comparison.md), and [acceptance evidence](acceptance.md).
2. Run `node scripts/verify.mjs`. It locates the sibling `.tools/moonjmes-toolchain` on this machine; elsewhere install MoonBit or set `MOON_BIN`/`MOON_HOME`.
3. Match the intended commit to public `main`; check Windows and Ubuntu CI on the same SHA.
4. Check Mooncakes 0.2.0 and compile a fresh consumer. Follow [publishing notes](publishing.md) for another release.
5. Review the desktop proposal against the current form; the participant edits and submits the form. Do not claim approval without an organizer notice.
