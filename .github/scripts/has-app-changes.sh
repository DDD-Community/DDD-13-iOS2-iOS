#!/usr/bin/env bash
# 변경 파일 목록을 stdin 으로 받아 앱 바이너리에 영향을 주는 변경이 있는지 판정한다.
#   exit 0 — 영향 있음 (빌드·배포 필요)
#   exit 1 — 전부 문서·설정 (스킵 가능)
#
# pr-validate.yml 과 testflight-deploy.yml 이 같은 기준을 써야 하므로 여기 한 곳에 둔다.
#
# 사용 예:
#   gh pr view "$PR_NUMBER" --json files --jq '.files[].path' | .github/scripts/has-app-changes.sh
set -euo pipefail

# denylist 인 이유: allowlist 는 새 소스 경로가 빠졌을 때 빌드가 조용히 스킵되는 실패로
# 가지만, denylist 는 불필요한 빌드가 한 번 도는 복구 가능한 실패로 떨어진다.
#
# 여기 넣지 않은 것들 —
#   .mise.toml         Tuist 버전을 고정하므로 빌드 결과에 영향을 준다
#   .github/workflows/ 배포 로직 자체라 검증 없이 넘길 수 없다
#   .claude/, CLAUDE.md .gitignore 에서 이미 무시되어 PR 파일 목록에 나타나지 않는다
IGNORE_PATTERNS='\.md$
^docs/
^\.github/ISSUE_TEMPLATE/
^\.github/scripts/
^\.gitignore$
^\.editorconfig$'

files=$(cat)

# 목록을 받지 못했으면 판정할 근거가 없으므로 안전한 쪽(영향 있음)으로 떨어뜨린다
if [ -z "$files" ]; then
    exit 0
fi

printf '%s\n' "$files" \
    | grep -Evf <(printf '%s\n' "$IGNORE_PATTERNS") \
    | grep -q .
