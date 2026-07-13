# 로그인 및 회원가입 플로우 구현 요구사항

> 관련 이슈: 로그인 및 회원가입 플로우 구현
> 작성일: 2026-04-28
> 상태: 초안

## 1. 배경 및 목표

소셜 로그인은 별도 이슈([#17 KAKAO 로그인 연동])에서 진행 중이므로, 본 이슈에서는 **소셜 로그인 이후의 회원가입 플로우**를 우선 완성하고 임시 진입 화면으로 이를 검증한다.

### 범위
- 임시 로그인 뷰 (회원가입 진입 / 메인 진입 분기 버튼)
- 약관 동의 화면
- 프로필 입력 화면 (이미지 선택 바텀시트, 닉네임 입력)
- 출발지 검색 및 선택 화면 (Kakao Local Keyword API 연동)
- 임시 메인(Home) 진입

### 비범위
- 실제 소셜 로그인 SDK 연동 (별도 이슈)
- 회원가입 결과를 서버에 영속화 (별도 이슈)
- 3D Face 프로필 이미지 리소스 자체 (현재는 placeholder 텍스트로 대체)

## 2. 화면 구성

### 2.1 임시 로그인 뷰 (`TempLoginView`)

소셜 로그인 이슈가 끝나기 전 회원가입 플로우를 검증하기 위한 진입 화면이다.

- 앱 메인(`@main`)에서 일단 임시로 호출되어야 한다.
- 두 버튼을 배치한다.
  - **회원가입 플로우 진입**: 약관 동의 화면(2.2)으로 push.
  - **메인 진입**: 임시 `HomeView`로 전환.
- 소셜 로그인 이슈가 머지되면 본 화면은 제거하고 실제 로그인 흐름으로 교체한다.

### 2.2 약관 동의 화면 (`TermsAgreementView`)

#### 레이아웃
- 상단 타이틀 라벨: `"{앱이름}에 참여하려면\n약관 동의가 필요해요"`
- "전체 동의하기" 버튼
- 약관 동의 항목 리스트 (3개, 모두 필수)
- 최하단 "시작하기" 버튼

#### 약관 항목 (현재 기준, 변경 가능)
| 순서 | 타이틀 |
| --- | --- |
| 1 | (필수) 서비스 이용 약관 |
| 2 | (필수) 개인정보 수집 및 이용 동의 |
| 3 | (필수) 위치정보 수집 이용 동의 |

> 약관 항목은 추후 변경될 수 있으므로 상수/Enum 또는 데이터로 관리하여 추가/수정이 용이하도록 구현한다.

#### 약관 항목 아이템 UI (leading → trailing)
1. 체크마크 아이콘 — 활성화 시 black, 비활성화 시 gray
2. 약관 타이틀 라벨 — `"(필수) {약관명}"`
3. `>` 아이콘 버튼 — 탭 시 해당 약관의 PDF를 앱 내에서 표시 (PDFKit, 풀스크린 sheet)

#### 동작
- "전체 동의하기" 토글 시 모든 필수 약관이 함께 활성화/비활성화된다.
- 모든 필수 약관이 개별로 활성화되면 "전체 동의하기"도 자동 활성화된다.
- "시작하기" 버튼: 모든 필수 약관 활성화 시에만 활성화.
  - 텍스트 컬러: 항상 white.
  - 백그라운드: rounded rectangle. 비활성화 시 gray, 활성화 시 black.
- "시작하기" 탭 시 프로필 입력 화면(2.3)으로 push.

#### PDF 처리
- 임시 placeholder PDF 3개를 `Resources`에 번들로 포함한다.
- PDFKit 기반 `PDFView`로 sheet 또는 push 형태로 표시한다.
- 추후 서버 또는 외부 URL로 교체 가능한 구조로 둔다.

### 2.3 프로필 입력 화면 (`ProfileInputView`)

#### 레이아웃
- 상단 좌측 백버튼 (텍스트 라벨 없음)
- 인사 라벨: `"반가워요 {이름}님"` — 이름은 소셜 로그인을 통해 받아온 값을 주입.
  - 본 이슈에서는 임시로 `"김반가워"`를 사용.
- 프로필 이미지 영역 (원형)
  - 우측 하단에 **카메라 아이콘**을 흰색 원형 백그라운드와 함께 오버레이.
  - 프로필 이미지 영역 탭 시 프로필 선택 바텀시트(2.3.1) 표시.
- 닉네임 텍스트필드
  - 입력 시 우측 끝에 `x` 버튼이 나타나 입력값을 한 번에 지울 수 있다.
  - 빈 값일 때 placeholder `"닉네임을 입력해주세요"`(gray) 표시.
- 최하단 "다음" 버튼: 닉네임이 입력되어 있을 때만 활성화.

#### 동작
- "다음" 탭 시 출발지 검색 화면(2.4)으로 push.

#### 2.3.1 프로필 이미지 선택 바텀시트

- 화면의 절반 정도 높이로 표시 (`.presentationDetents([.medium])` 등).
- 구성:
  - 상단: 현재 선택된 프로필 이미지 미리보기.
  - 그 아래: 8개 컴포넌트를 2 × 4 그리드로 배치.
    - **(0,0)** — 카메라: AVFoundation으로 카메라 캡처. 촬영한 사진을 미리보기에 주입.
    - **(0,1)** — 갤러리: 시스템 사진 선택기(`PhotosPicker`)를 통해 이미지 선택.
    - **(0,2) ~ (1,3)** — 3D Face 프리셋(현재 리소스 없음). 임시로 `"3D face"` 텍스트 placeholder만 표시.
  - 하단: "프로필 삭제" 버튼 + "저장하기" 버튼 가로 배치.
    - 두 버튼 모두 rounded rectangle.
    - **프로필 삭제**: 바텀시트에서 선택했던 후보 이미지를 폐기하고 부모 뷰의 프로필 이미지에 반영하지 않은 채 닫는다.
    - **저장하기**: 바텀시트에서 선택한 이미지를 부모 뷰의 프로필 이미지로 반영하고 닫는다.

#### 권한 처리
- `Info.plist`에 다음 usage description 추가:
  - `NSCameraUsageDescription`
  - `NSPhotoLibraryUsageDescription`
- 권한 요청 프롬프트 노출.
- **거절 시**: 권한이 필요한 이유를 설명하고 시스템 설정으로 이동할 수 있는 알럿을 제공한다 (`UIApplication.openSettingsURLString`).

### 2.4 출발지 검색 및 선택 화면 (`DepartureSearchView`)

#### 레이아웃
- 상단 좌측 백버튼.
- 타이틀 라벨: `"{닉네임}님\n미리 출발지만 등록해주세요"` — 2.3에서 입력한 닉네임 주입.
- 검색 트리거 버튼 뷰 (탭 가능한 placeholder)
  - leading 돋보기 아이콘 + trailing 텍스트.
  - 텍스트 placeholder: `"지역, 지하철역 명으로 찾기"`
  - 탭 시 검색 바텀시트(2.4.1) 표시.
  - 검색 후 역명이 선택되면 placeholder 대신 선택된 역명을 표시.
- 최하단 "다음" 버튼: 역명이 주입된 상태에서만 활성화.
- "다음" 탭 시 임시 `HomeView`로 전환.

#### 2.4.1 출발지 검색 바텀시트

- 네비게이션 바 영역만 남기고 화면 거의 전체를 덮는 높이 (`.presentationDetents([.large])` 또는 커스텀 detent).
- 구성:
  - 상단 우측 `x` 버튼.
  - 검색 입력 행: 돋보기 아이콘 + 텍스트필드. 백그라운드는 옅은 gray의 rounded rectangle.
  - 검색 결과 리스트.
- 키워드 변경 시 Kakao Local Keyword Search API 호출 → 결과 리스트 갱신.
- 리스트 아이템 탭 시:
  - 바텀시트가 닫힌다.
  - 부모 화면의 검색 트리거 버튼 텍스트가 placeholder에서 선택된 역명으로 교체된다.

#### 검색 API & 필터링/정렬 로직
참고 코드: `/Users/kimhyeji/KakaoMapTest/KakaoMapTest/KakaoMapTest/KeywordSearch/`

##### 차용할 부분
- **Kakao Local 키워드 검색 호출 로직**
  - 엔드포인트: `https://dapi.kakao.com/v2/local/search/keyword.json`
  - `category_group_code=SW8` (지하철역 한정)
  - `Authorization: KakaoAK {REST_API_KEY}` 헤더
- **응답 모델 구조** (`place_name`, `address_name`, `road_address_name`, `x`, `y`)
- **필터링 로직**
  - 서울 한정 필터: `addressName.hasPrefix("서울") || roadAddressName.hasPrefix("서울")`
  - 역명 prefix 필터: 검색어가 `"역"`으로 끝나면 trailing `"역"` 제거 후 `stationKey`(공백 앞부분)에 prefix 포함되는 결과만 유지
- **정렬 로직** (anchor 기반)
  - **Priority 1**: 역명에 검색어가 포함된 결과. 동일 역명(호선만 다름)끼리 연속 배치되도록 그룹 anchor 인덱스 사용.
  - **Priority 2**: 그 외 결과. P1 첫 결과(anchor)로부터의 제곱 거리 오름차순.
  - 단일 정렬 키 `(rank, groupIndex|distance, originalIndex)`로 안정적 tie-break.

##### 차용하지 않을 부분
- 행정구역 필터 토글 (사용자에게 의미가 모호하므로 항상 ON 상태로 고정).
- 결과 카운트 라벨 (회원가입 플로우 단순화 우선).
- `print` 기반 디버그 로그 — 프로젝트 `Logger` 유틸로 교체.

##### 통합 방식
- 카카오 호출 코드를 그대로 옮기지 않고, **Bangawo의 멀티모듈 아키텍처에 맞춰 재구현**한다.
  - `Network/Networking`: 공통 HTTP 클라이언트 (기존 활용).
  - `Data/API`: Kakao Local 엔드포인트 정의.
  - `Data/Repository`: `LocationSearchRepository` 구현.
  - `Domain/DataInterface`: `LocationSearchRepositoryProtocol` 인터페이스.
  - `Domain/Entity`: `Station` 엔티티 (Kakao DTO → 도메인 모델 매핑).
  - `Domain/UseCase`: `SearchStationsUseCase` (필터/정렬 로직은 UseCase 또는 Reducer 측에 위치, 추후 결정).
  - `Presentation`: `DepartureSearchFeature` (TCA `@Reducer`).

#### Kakao REST API Key 관리
- 기존 비공개 xcconfig 자동화 흐름([#13])에 `KAKAO_REST_API_KEY` 항목을 추가한다.
- `Info.plist`에 `KAKAO_REST_API_KEY = $(KAKAO_REST_API_KEY)` 형태로 노출하고, 런타임에 `Bundle`을 통해 로드하는 헬퍼를 둔다.
- 키가 코드/Git에 포함되지 않도록 한다.

### 2.5 임시 메인 (`HomeView`)

- 본 이슈에서는 빈 화면 또는 단순 텍스트 라벨 정도로 충분하다.
- 추후 실제 메인 피처와 교체될 임시 진입점 역할.

## 3. 네비게이션 흐름

```
TempLoginView
 ├─ [회원가입] → TermsAgreementView
 │                 └─ [시작하기] → ProfileInputView
 │                                   └─ [다음] → DepartureSearchView
 │                                                 └─ [다음] → HomeView
 └─ [메인 진입] → HomeView
```

- TCA 1.8+ 기준 `@Reducer enum Destination` 패턴으로 네비게이션 스택을 구성한다.
- 각 화면은 별개의 `@Reducer` Feature.
- Feature 간 데이터 전달:
  - 약관 동의 결과 → 프로필 입력으로 직접 전달 X (단순 통과).
  - 닉네임/이름 → 출발지 검색 화면 타이틀에 주입.
  - 프로필 이미지/닉네임/출발지 → 회원가입 완료 시 (서버 영속화 이슈에서) 함께 전송.

## 4. 아키텍처 매핑

| 구성 요소 | 모듈 | 비고 |
| --- | --- | --- |
| 임시 로그인 뷰 | `App` | 소셜 로그인 머지 시 제거 |
| 회원가입 Feature 트리 | `Presentation/Presentation` | TCA `@Reducer` |
| `Station` 엔티티 | `Domain/Entity` | Kakao DTO → 도메인 매핑 |
| 위치 검색 인터페이스 | `Domain/DataInterface` | Repository 프로토콜 |
| Search UseCase | `Domain/UseCase` | 필터/정렬 호출 |
| Kakao Local API | `Data/API` | 엔드포인트, DTO |
| 위치 검색 Repository | `Data/Repository` | 인터페이스 구현 |
| HTTP 클라이언트 | `Network/Networking` | 기존 활용 |
| 약관 PDF | `App/Resources` (또는 `Shared`) | 임시 placeholder 3개 |
| 카메라/갤러리 권한 안내 | `Shared/Utill` 또는 `Presentation` | 설정 이동 알럿 헬퍼 |

> 파일/타겟 추가·삭제 시 `./tuisttool generate`를 실행한다.

## 5. TCA 컨벤션 적용 포인트

- `@Reducer` + `@ObservableState` 사용.
- Action 네이밍은 "발생한 사건": `agreeAllToggleTapped`, `nextButtonTapped`, `stationsResponse(Result<...>)`, `imageSelected(Image?)` 등.
- 검색 키워드 입력은 디바운싱(`.debounce`) 후 `.run` Effect로 호출하여 매 키 입력마다 API 폭주 방지.
- `[weak self]` 패턴 클로저는 SwiftUI 단계에서는 불필요. 단, 비-TCA 헬퍼/뷰모델에서는 컨벤션 준수.
- API 호출은 Reducer 내부가 아니라 Effect로 분리.
- 일시적 UI 상태(텍스트필드 focus 등)는 SwiftUI `@State`.

## 6. 완료 조건

- [ ] 임시 로그인 뷰가 앱 진입 시 표시되고 두 버튼이 동작한다.
- [ ] 약관 동의 화면이 컨벤션에 맞게 구현되고 모든 동의 시에만 "시작하기"가 활성화된다.
- [ ] 약관 PDF가 임시 리소스로 sheet에 표시된다.
- [ ] 프로필 입력 화면에서 카메라/갤러리/3D face placeholder 그리드를 가진 바텀시트가 동작한다.
- [ ] 카메라/갤러리 권한 거절 시 설정 이동 알럿이 표시된다.
- [ ] 닉네임 입력 시 클리어(`x`) 버튼이 동작하고, 입력 시에만 "다음"이 활성화된다.
- [ ] 출발지 검색 바텀시트에서 Kakao 키워드 검색 결과가 차용한 필터/정렬 로직대로 표시된다.
- [ ] 결과 선택 시 부모 화면에 역명이 주입되고 "다음"이 활성화된다.
- [ ] "다음" 탭 시 임시 `HomeView`로 전환된다.
- [ ] `KAKAO_REST_API_KEY`가 비공개 xcconfig 자동화 흐름에 통합되어 코드/Git에 노출되지 않는다.

## 7. 후속/연결 이슈

- 소셜 로그인 SDK 연동 (#17 등).
- 회원가입 결과 서버 영속화.
- 3D Face 프로필 프리셋 이미지 리소스 추가.
- 약관 본문 실제 PDF/URL 교체.
