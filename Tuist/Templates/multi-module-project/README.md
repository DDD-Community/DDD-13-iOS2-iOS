# 멀티 모듈 프로젝트 템플릿

이 템플릿을 사용하여 새로운 멀티 모듈 iOS 프로젝트를 생성할 수 있습니다.

## 사용법

```bash
# 새 디렉토리에서 템플릿 생성
mkdir MyNewProject
cd MyNewProject
tuist scaffold multi-module-project --name MyNewProject

# 추가 옵션과 함께 생성
tuist scaffold multi-module-project \
  --name MyAwesomeApp \
  --bundle_id com.mycompany.awesome \
  --team_id YOUR_TEAM_ID
```

## 매개변수

- `--name` (필수): 프로젝트 이름
- `--bundle_id` (선택): 번들 ID 접두사 (기본값: io.Roy.Module)
- `--team_id` (선택): 개발팀 ID (기본값: N94CS4N6VR)

## 생성 후 설정

1. 팀 ID와 번들 ID를 실제 값으로 변경
2. `tuist generate`로 프로젝트 생성
3. Xcode에서 프로젝트 열기