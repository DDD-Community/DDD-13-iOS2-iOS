# Commit Convention Rules

## Format
```
[{Header}]: {Message}
```

## Header

| Header     | Description                          |
|------------|--------------------------------------|
| `FEAT`     | 기능 구현 관련 작업                  |
| `FIX`      | 버그나 이슈 수정                     |
| `REFACTOR` | 리팩토링, 코드변경(린팅, 포맷팅 등) |
| `HOTFIX`   | 긴급 수정(릴리즈 직후 이슈 수정)    |
| `DOCS`     | 문서 수정/추가                       |
| `ADD`      | 파일/리소스 추가                     |
| `TEST`     | 테스트 코드 작업                     |
| `CHORE`    | 기타 등등                            |

## Message Rules
- 50글자 이하로 작성한다.
- 마침표 및 특수기호를 붙이지 않는다.
- 한국어로 작성한다.
- 무엇을 왜 변경했는지 기술한다.
- 어떻게를 명시해야 할 경우 빈 줄을 추가하고 본문으로 작성한다.

## Examples
```
[FEAT]: 로그인 화면 UI 구현

[FIX]: 날짜 캐러셀 오프셋 계산 오류 수정

[REFACTOR]: NetworkService를 CoreNetwork 싱글톤 패키지로 교체

[DOCS]: README에 프로젝트 설정 가이드 추가

[FEAT]: 캘린더 뷰에 만족도 시각화 추가

HealthKit 쿼리 결과를 월별로 그룹핑하여
캘린더 셀에 컬러 인디케이터로 표시
```
