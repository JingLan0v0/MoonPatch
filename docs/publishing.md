# GitHub and Mooncakes publication checklist

This repository is local as of 2026-10-01. The module name
`JingLan0v0/moonpatch` uses the owner's known GitHub namespace but has not
been registered on Mooncakes. Do not claim installation or a public CI run
until the corresponding external page exists.

1. Create a new **public** GitHub repository for MoonPatch under `JingLan0v0`.
   The proposed name is `moonbit-moonpatch`; first check that it is available.
2. Add the exact repository URL to `moon.mod`, README and the contest form.
   Set `origin`, push `main`, and verify the remote SHA equals local HEAD.
3. Confirm the Windows and Ubuntu Actions jobs pass on that SHA. Resolve
   any platform-specific differences before submission.
4. Continue with meaningful, traceable development commits. The linked
   charter says at least ten valid commits; never create empty or artificial
   commits to satisfy the count.
5. With the owner's Mooncakes login, run `moon publish --dry-run`; inspect
   the archive for README, license, source and test notices and absence of
   `_build`, credentials and local toolchains.
6. Publish the intended version, verify its public package page, then create
   a new consumer module, `moon add JingLan0v0/moonpatch@VERSION`, compile it
   and call `apply` on a small real patch.
7. Save the public repository, CI, package and consumer evidence in
   `docs/acceptance.md`. The participant writes the one-page application in
   their own words and submits it through the current official form.

Publication does not happen automatically when code is pushed to GitHub.
