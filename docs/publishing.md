# GitHub and Mooncakes publication checklist

The public GitHub repository is
[JingLan0v0/MoonPatch](https://github.com/JingLan0v0/MoonPatch).
The module name is `JingLan0v0/moonpatch`; it has not been registered on
Mooncakes. Do not claim installation or a successful public CI run until the
corresponding external page exists.

1. Confirm the `main` branch of the public repository matches the intended
   local commit, and enter the exact root URL in the contest form.
2. Confirm the Windows and Ubuntu Actions jobs pass on that SHA. Resolve
   any platform-specific differences before submission.
3. Continue with meaningful, traceable development commits. The linked
   charter says at least ten valid commits; never create empty or artificial
   commits to satisfy the count.
4. With the owner's Mooncakes login, run `moon publish --dry-run`; inspect
   the archive for README, license, source and test notices and absence of
   `_build`, credentials and local toolchains.
5. Publish the intended version, verify its public package page, then create
   a new consumer module, `moon add JingLan0v0/moonpatch@VERSION`, compile it
   and call `apply` on a small real patch.
6. Save the public repository, CI, package and consumer evidence in
   `docs/acceptance.md`. The participant writes the one-page application in
   their own words and submits it through the current official form.

Publication does not happen automatically when code is pushed to GitHub.
