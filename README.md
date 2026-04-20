# DDD 13기 iOS 2팀 iOS

## Setup

### AI 도구 연동
프로젝트 규칙은 [AGENTS.md](./AGENTS.md)에 정의되어 있습니다.
Claude Code 사용 시 심볼릭 링크를 연결하세요.
```bash
ln -s AGENTS.md CLAUDE.md
```

### 빌드 환경 구성

`Config/*.xcconfig` 파일은 비공개 repo([DDD-iOS2-iOS-private](https://github.com/khyeji98/DDD-iOS2-iOS-private))에서 관리됩니다.

1. private repo의 collaborator로 추가받습니다 (소유자에게 GitHub username 전달).
2. private repo README의 안내에 따라 본인 PAT(classic, `repo` scope)을 발급합니다.
3. 다음 명령으로 xcconfig를 받고 프로젝트를 생성합니다.
   ```bash
   make download-privates   # 첫 실행 시 PAT 입력, 이후 .env에 캐시
   make generate
   ```

자세한 절차/트러블슈팅은 private repo의 README를 참조하세요.
