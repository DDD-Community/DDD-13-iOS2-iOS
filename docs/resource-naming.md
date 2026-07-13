# Resource Naming

## Image (XCAssets)

형식: `{prefix}_{name}_{variant}_{size}`

- `variant`, `size`는 해당되는 경우에만 포함한다.

**prefix**

| prefix | 의미 |
| --- | --- |
| `ic` | icon |
| `sym` | symbol (로고, 브랜드 등) |
| `img` | illustration, 사진 등 일반 이미지 |
| `bg` | background |

**name** — 이미지가 나타내는 대상이나 기능을 snake_case로 작성한다.

**variant** — 스타일, 상태, 방향 등 이미지의 변형을 나타낸다.

| 종류 | 예시 |
| --- | --- |
| 스타일 | `filled`, `outline`, `tonal` |
| 상태 | `active`, `inactive`, `enabled`, `disabled` |
| 방향 | `up`, `down`, `left`, `right` |

**size** — 시맨틱 또는 픽셀 단위로 표기한다.

| 종류 | 예시 |
| --- | --- |
| 시맨틱 | `xs`, `sm`, `md`, `lg` |
| 픽셀 | `16`, `24`, `32` |

**예시**

```
ic_arrow_right_24
ic_heart_filled_active
ic_chevron_down_sm
sym_kakao
img_onboarding_01
bg_main
```

**Swift 코드에서의 접근**
- Tuist가 snake_case → camelCase로 자동 변환하므로 `Image.Asset.icArrowRight24` 형태로 사용한다.
