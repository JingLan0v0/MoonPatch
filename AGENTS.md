# MoonPatch repository guide

This is an October 2026 MoonBit Hackathon project. Read `docs/progress.md` and
`docs/competition.md` before changing release or contest claims. Run
`node scripts/verify.mjs` for the full local check.

The root package owns RFC 6901 pointers, RFC 6902 operations and diagnostics.
`cmd/main` owns Node.js file/process I/O only. Keep patch semantics in MoonBit
and preserve immutable input behavior. The three `examples/` scenarios and
vendored RFC vectors are acceptance oracles. Do not weaken tests to make a
regression pass.

Do not commit toolchains, `_build`, credentials, or private form information.
Keep upstream test provenance and the prior-project infrastructure reuse in
`THIRD_PARTY_NOTICES.md`. Distinguish local tests, public CI, registry
publication, and organizer acceptance. The event charter says the actual
one-page proposal must be written by the participant.
