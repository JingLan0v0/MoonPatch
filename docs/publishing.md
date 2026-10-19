# GitHub and Mooncakes release procedure

Public repository: https://github.com/JingLan0v0/MoonPatch. Module: `JingLan0v0/moonpatch`. Version 0.1.0 was previously published; the guarded rollback API requires **0.2.0**, a new immutable Mooncakes release. GitHub pushes do not update Mooncakes.

1. Run `node scripts/verify.mjs`, inspect the diff, and confirm no credentials, `_build`, local toolchain, or private form data are tracked.
2. Commit substantive changes, push `main`, verify public remote SHA and both Windows/Ubuntu CI jobs on that SHA.
3. Run `./scripts/moon.ps1 publish --dry-run` and inspect the archive. A dry run is not publication; its tool may return nonzero despite HTTP 202 Accepted, so inspect the server message.
4. Run `./scripts/moon.ps1 publish` with the owner's existing login. Verify HTTP 200 and the public Mooncakes 0.2.0 page.
5. In a fresh temporary MoonBit module, run `moon add JingLan0v0/moonpatch@0.2.0`, compile and execute a small `apply_with_receipt`/rollback example.
6. Record exact commit, CI run, registry URL, and consumer result in [acceptance](acceptance.md). The participant then updates Feishu; publishing alone does not resubmit the proposal.

Never print or commit Mooncakes credentials. Only a later version may change published package content.
