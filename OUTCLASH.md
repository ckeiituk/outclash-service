# OutClash service fork

This repository is a **branding overlay** on top of upstream
[`UruhaLushia/sparkle-service`](https://github.com/UruhaLushia/sparkle-service)
(formerly `xishang0128/sparkle-service`). It produces the privileged service binary
bundled by the OutClash app.

## Model

- **Source is kept pristine-upstream.** The Go module path
  (`github.com/UruhaLushia/sparkle-service`) and all `*.go` files match upstream
  verbatim, so `git merge upstream/main` never conflicts on branding.
- **Branding is applied at build time** by [`scripts/rebrand.sh`](scripts/rebrand.sh):
  it rewrites the lowercase `sparkle` / Capitalized `Sparkle` string literals to
  `outclash` / `OutClash` (service pipe `\\.\pipe\outclash\service`, unix socket
  `/tmp/outclash-service.sock`, Windows service `OutClashService`, dirs, help text).
  It deliberately does **not** touch the module/import path or the ALL-CAPS contract
  identifiers (`SPARKLE_*` env vars, `SPARKLE-AUTH-V2` signing context) that the
  OutClash app speaks verbatim.
- **Our CI and scripts survive upstream merges** via `.gitattributes` (`merge=ours`).

## Workflows

- `.github/workflows/build.yml` — runs `rebrand.sh`, builds the 14-target matrix as
  `outclash-service-<goos>-<output>`, and republishes the rolling `pre-release`
  (the tag the app's `scripts/prepare.mjs` downloads).
- `.github/workflows/sync-upstream.yml` — weekly (and manual) `git merge upstream/main`;
  on a clean merge pushes to `main`, which triggers `build.yml`. On conflict it fails
  for manual resolution.

## Why a fork (instead of pulling sparkle directly like koala)

To keep an OutClash-branded service identity (`OutClashService` / `\\.\pipe\outclash\service`)
distinct from `SparkleService`, so OutClash and koala-clash can coexist as installs without
their privileged services colliding.
