#!/usr/bin/env bash
# Secret scan, then flip ydescieux2-del/crowd-call public. Usage: bash scripts/publish.sh [--run]
set -euo pipefail
cd "$(dirname "$0")/.."
die() { echo "ABORT: $*"; exit 1; }
[[ -z "$(git status --porcelain)" ]] || die "working tree not clean"
git check-ignore -q _footage || die "_footage/ is not gitignored"
[[ -z "$(git ls-files _footage)" ]] || die "_footage is tracked"
grep -q "MIT License" LICENSE || die "LICENSE is not MIT"
pat='sk-ant-[A-Za-z0-9_-]{10,}|sk-[A-Za-z0-9]{32,}|gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|[A-Z_]*(KEY|TOKEN|SECRET) *= *[A-Za-z0-9_-]{8,}|oauth:[a-z0-9]{20,}'
git grep -nIE "$pat" -- . ':!scripts/publish.sh' && die "key-like string in tracked files" || true
git log --all -p -- . ':!scripts/publish.sh' | grep -IEq "$pat" && die "key-like string in history" || true
git grep -nIE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}|\(?[0-9]{3}\)?[ .-][0-9]{3}[ .-][0-9]{4}' -- . ':!scripts/publish.sh' && die "email/phone in tracked files" || true
echo "scan clean"
if [[ "${1:-}" == "--run" ]]; then
  git push -q origin HEAD
  gh repo edit ydescieux2-del/crowd-call --visibility public --accept-visibility-change-consequences
  gh repo edit ydescieux2-del/crowd-call --add-topic twitch,obs,overlay,openai-codex,hackathon >/dev/null
fi
