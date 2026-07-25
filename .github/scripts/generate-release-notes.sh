#!/usr/bin/env bash
#
# 직전 태그(없으면 최초 커밋)부터 HEAD 까지의 커밋을 커밋 컨벤션 헤더별로
# 그룹핑해 GitHub Release 본문(Markdown)을 stdout 으로 출력한다.
#
# 사용법: generate-release-notes.sh <version>   (예: generate-release-notes.sh 1.0.1)
#
# 커밋 컨벤션: "[HEADER]: 메시지"  (docs/commit-convention.md)
set -euo pipefail

VERSION="${1:?사용법: generate-release-notes.sh <version>}"
TAG="v${VERSION}"

# ── 비교 기준(직전 태그) 탐색 ────────────────────────────────
# 현재 만들려는 태그(v<version>)는 제외해 재실행 시에도 올바른 직전 태그를 찾는다.
PREV_TAG="$(git describe --tags --abbrev=0 --exclude="${TAG}" 2>/dev/null || true)"

if [ -n "$PREV_TAG" ]; then
  RANGE="${PREV_TAG}..HEAD"
else
  # 태그가 하나도 없으면 최초 커밋부터 전체를 대상으로 한다.
  RANGE="HEAD"
fi

# 머지 커밋을 제외하고 "짧은해시<TAB>제목" 형태로 수집한다.
COMMITS="$(git log "$RANGE" --no-merges --pretty=format:'%h%x09%s' || true)"

# ── 헤더별 그룹핑 (awk 단일 패스) ────────────────────────────
# 정규식은 awk 본문에 리터럴로 둔다. (-v 로 넘기면 백슬래시가 이스케이프되어 깨짐)
BODY="$(printf '%s\n' "$COMMITS" | awk -F'\t' '
  BEGIN {
    n = split("FEAT,FIX,HOTFIX,REFACTOR,ADD,TEST,DOCS,CHORE", order, ",")
    title["FEAT"]     = "✨ 새로운 기능"
    title["FIX"]      = "🐛 버그 수정"
    title["HOTFIX"]   = "🚑 긴급 수정"
    title["REFACTOR"] = "♻️ 리팩터링"
    title["ADD"]      = "➕ 추가"
    title["TEST"]     = "✅ 테스트"
    title["DOCS"]     = "📝 문서"
    title["CHORE"]    = "🔧 기타"
  }
  $2 == "" { next }
  {
    hash = $1
    subj = $2
    if (subj ~ /^\[[A-Z]+\]:/) {
      header = subj
      sub(/^\[/, "", header)
      sub(/\].*/, "", header)           # "[FEAT]: ..." → "FEAT"
      msg = subj
      sub(/^\[[A-Z]+\]:[ \t]*/, "", msg)
    } else {
      header = ""
    }
    if (!(header in title)) {            # 컨벤션 밖(또는 미등록 헤더)
      header = "_OTHER_"
      msg = subj                         # 원문 그대로 노출
    }
    bucket[header] = bucket[header] "- " msg " (" hash ")\n"
  }
  END {
    for (i = 1; i <= n; i++) {
      k = order[i]
      if (k in bucket) printf "### %s\n\n%s\n", title[k], bucket[k]
    }
    if ("_OTHER_" in bucket) printf "### 그 외\n\n%s\n", bucket["_OTHER_"]
  }
')"

# ── 출력 ─────────────────────────────────────────────────────
{
  if [ -n "$BODY" ]; then
    printf '%s' "$BODY"
  else
    printf '_이번 릴리즈에는 기록된 커밋이 없습니다._\n\n'
  fi

  # 비교 링크(GitHub Actions 환경 + 직전 태그가 있을 때만)
  if [ -n "${GITHUB_SERVER_URL:-}" ] && [ -n "${GITHUB_REPOSITORY:-}" ] && [ -n "$PREV_TAG" ]; then
    printf '**전체 변경사항**: %s/%s/compare/%s...%s\n' \
      "$GITHUB_SERVER_URL" "$GITHUB_REPOSITORY" "$PREV_TAG" "$TAG"
  fi
}
