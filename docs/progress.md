# Project status and continuation

## Current state (2026-10-01)

- New October project: MoonPatch, direction 工具库.
- Local path: `C:\Users\XJY\Desktop\MoonBit黑客松\moonpatch`.
- RFC 6901 pointer handling and all six RFC 6902 operations are implemented
  in MoonBit, with a JS-target CLI and immutable failure behavior.
- Local full verification passes; exact checks are in `docs/acceptance.md`.
- A clean Git archive of code commit `dc2a832` passed the same full check in
  a separate extraction directory.
- Repository is local. There is no GitHub remote, public CI result or
  Mooncakes release yet.
- The current October website says October 31 deadline; the linked charter
  still contains September dates. See `docs/competition.md` before filing.
- The actual one-page proposal must be authored by the participant. Use
  `docs/application-facts.md` to check facts, not as copy-ready submission.

## Resume in a later session

1. Read `README.zh-CN.md`, `docs/competition.md`, `docs/architecture.md` and
   `docs/acceptance.md` before changing claims.
2. Run `node scripts/verify.mjs`. The script detects the local sibling
   `.tools/moonjmes-toolchain` on this machine; elsewhere install MoonBit or
   set `MOON_BIN` and `MOON_HOME`.
3. Review the ecosystem overlap in `THIRD_PARTY_NOTICES.md` again before
   application. If a focused RFC 6902 MoonBit library has appeared, reassess
   the separate project boundary.
4. Complete the GitHub and Mooncakes steps in `docs/publishing.md`, then
   record exact SHAs and URLs in `docs/acceptance.md`.
5. Let the participant handle contest group membership, account login,
   human-authored application and final form submission. Organizer approval
   and support payments remain external decisions.
