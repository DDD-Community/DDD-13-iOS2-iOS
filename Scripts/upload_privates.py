#!/usr/bin/env python3
import base64
import json
import os
import subprocess
import sys
from pathlib import Path
from urllib import request
from urllib.error import HTTPError

REPO_SLUG = "khyeji98/DDD-iOS2-iOS-private"
BRANCH = "main"
CONFIG_DIR = Path("Config")
FILES = [
    "Dev.xcconfig",
    "Stage.xcconfig",
    "Prod.xcconfig",
    "Release.xcconfig",
    "Secrets.xcconfig",
]
API_ROOT = f"https://api.github.com/repos/{REPO_SLUG}"


# GitHub REST API 호출 헬퍼. PAT 인증 헤더를 붙이고 JSON 응답을 반환한다.
def api(method: str, path: str, body: dict | None = None) -> dict:
    token = os.environ.get("GITHUB_ACCESS_TOKEN", "")
    if not token:
        print("ERROR: GITHUB_ACCESS_TOKEN is not set", file=sys.stderr)
        sys.exit(1)

    url = f"{API_ROOT}{path}"
    data = json.dumps(body).encode() if body is not None else None
    req = request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"token {token}")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("X-GitHub-Api-Version", "2022-11-28")
    if data is not None:
        req.add_header("Content-Type", "application/json")

    try:
        with request.urlopen(req) as res:
            return json.loads(res.read().decode())
    except HTTPError as e:
        payload = e.read().decode(errors="replace")
        print(f"ERROR: {method} {path} -> HTTP {e.code}", file=sys.stderr)
        print(payload, file=sys.stderr)
        if e.code == 422 and path.startswith("/git/refs/"):
            print(
                "원격이 로컬보다 앞서 있습니다. `make download-privates` 후 재시도해 주세요.",
                file=sys.stderr,
            )
        sys.exit(1)


# 로컬 파일의 git blob SHA-1 계산. GitHub 원격 blob SHA 와 같은 포맷이라 직접 비교 가능.
def git_hash_object(path: Path) -> str:
    result = subprocess.run(
        ["git", "hash-object", str(path)],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def main() -> None:
    # 1. 브랜치의 최신 커밋 SHA 조회
    ref = api("GET", f"/git/ref/heads/{BRANCH}")
    latest_commit_sha = ref["object"]["sha"]

    # 2. 최신 커밋이 가리키는 base tree SHA 조회
    commit = api("GET", f"/git/commits/{latest_commit_sha}")
    base_tree_sha = commit["tree"]["sha"]

    # 3. base tree 에서 원격 파일별 blob SHA 목록 확보 (변경 감지 기준값)
    tree = api("GET", f"/git/trees/{base_tree_sha}")
    remote_map = {entry["path"]: entry["sha"] for entry in tree.get("tree", [])}

    # 4. 로컬 파일을 원격과 비교 → 다른 파일만 blob 으로 업로드해 tree 엔트리로 수집
    changed: list[dict] = []
    for file in FILES:
        local_path = CONFIG_DIR / file
        if not local_path.exists():
            print(f"SKIP {file} (로컬 파일 없음)")
            continue

        local_sha = git_hash_object(local_path)
        if local_sha == remote_map.get(file):
            print(f"SKIP {file} (변경 없음)")
            continue

        content_b64 = base64.b64encode(local_path.read_bytes()).decode()
        blob = api("POST", "/git/blobs", {
            "content": content_b64,
            "encoding": "base64",
        })
        changed.append({
            "path": file,
            "mode": "100644",
            "type": "blob",
            "sha": blob["sha"],
        })
        print(f"STAGED {file}")

    # 변경된 파일이 없으면 커밋/ref 갱신 없이 종료
    if not changed:
        print("변경 없음")
        return

    # 5. 변경된 blob 들을 base tree 위에 얹어 새 tree 생성
    new_tree = api("POST", "/git/trees", {
        "base_tree": base_tree_sha,
        "tree": changed,
    })

    # 6. 새 tree 로 커밋 생성 후 브랜치 ref 를 새 커밋으로 이동 (push 효과)
    message = "[CHORE]: " + ", ".join(c["path"] for c in changed) + " 업데이트"
    new_commit = api("POST", "/git/commits", {
        "message": message,
        "tree": new_tree["sha"],
        "parents": [latest_commit_sha],
    })

    api("PATCH", f"/git/refs/heads/{BRANCH}", {"sha": new_commit["sha"]})

    print(f"Done. commit={new_commit['sha'][:7]} files={len(changed)}")


if __name__ == "__main__":
    main()
