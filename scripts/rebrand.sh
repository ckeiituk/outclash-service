#!/usr/bin/env bash
# Build-time rebrand: sparkle/Sparkle -> outclash/OutClash in string literals,
# WITHOUT touching the Go module/import path (github.com/UruhaLushia/sparkle-service)
# or ALL-CAPS contract identifiers (SPARKLE_* env vars, SPARKLE-AUTH-V2 signing context),
# which the OutClash app speaks verbatim.
#
# The repo source stays pristine-upstream; this transform runs only before `go build`
# (see .github/workflows/build.yml), so `git merge upstream/main` never conflicts on
# branding. Idempotent: safe to run repeatedly.
set -euo pipefail

mapfile -t files < <(grep -rlE 'sparkle|Sparkle' --include='*.go' . || true)
for f in "${files[@]}"; do
  # On every line EXCEPT the module/import path: rebrand lowercase + Capitalized forms.
  # ALL-CAPS SPARKLE (env vars, SPARKLE-AUTH-V2) is deliberately left untouched.
  sed -i -e '/UruhaLushia\/sparkle-service/!{s/sparkle/outclash/g; s/Sparkle/OutClash/g}' "$f"
done

# --- verification: fail loudly so CI never ships a broken or half-applied rebrand ---
grep -q 'pipe\\\\outclash\\\\service' cmd/cmd.go || { echo "FAIL: outclash service pipe missing"; exit 1; }
grep -q 'UruhaLushia/sparkle-service' go.mod      || { echo "FAIL: go module path corrupted"; exit 1; }
# residual brandable literal (lowercase/Capitalized only; ALL-CAPS allowed), excluding module path
if grep -rnE 'sparkle|Sparkle' --include='*.go' . | grep -v 'UruhaLushia/sparkle-service'; then
  echo "FAIL: residual brandable sparkle/Sparkle literal listed above"; exit 1
fi
echo "rebrand OK"
