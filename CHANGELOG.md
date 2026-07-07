# Changelog

모든 주요 변경 사항은 이 파일에 기록됩니다.

## [2026-07-07] - 코드 컨벤션 체계 구축

### 추가

- `AGENTS.md`: AI 에이전트(Hermes, OpenCode, Claude Code 등) 공용 코드
  컨벤션 정의 (trailing newline, line length, indent, 파일별 규칙)
- `.editorconfig`: 에디터 자동 설정 (들여쓰기, 줄바꿈, charset)

### 변경

- `README.md`: 표 compact 스타일로 변환, 코드 컨벤션 섹션 추가,
  프로젝트 구조에 신규 파일 반영
- `CHANGELOG.md`: 표 compact 스타일로 변환, 본문 72자 줄바꿈
- `scripts/build.sh`: shebang `#!/usr/bin/env bash`로 변경, indent 2칸
  통일, info 메시지 80자 이내로 분할
- `config/opencode.json`: vision description 100자 이내로 단축,
  trailing newline 추가
- `config/hermes.yml`: trailing newline 추가
- `Dockerfile`: trailing whitespace 제거

## [2026-07-07] - Gemma 4 제거 및 모델 구성 개편

### 변경 사항

#### opencode 에이전트

| 에이전트 | 변경 전 | 변경 후 | 사유 |
| - | - | - | - |
| `general` | `ollama-cloud/gemma4:31b` | `ollama-cloud/qwen3.5:cloud` | Gemma 4 대비 한국어 처리 및 멀티모달 성능 우수 |
| `explore` | `ollama-cloud/gemma4:31b` | `ollama-cloud/kimi-k2.7-code` | 코드 베이스 탐색 및 심층 추론에 Kimi K2.7 Code가 압도적 |
| `vision` | `ollama-cloud/gemma4:31b` | `ollama-cloud/qwen3.5:cloud` | 비전 작업 시 Qwen 3.5 Cloud의 멀티모달·한국어 이해력이 Gemma 4보다 우수 |
| `build` | `ollama-cloud/glm-5.1` | `ollama-cloud/glm-5.1` | 변경 없음 |
| `plan` | `ollama-cloud/glm-5.1` | `ollama-cloud/glm-5.1` | 변경 없음 |
| `code` | `ollama-cloud/kimi-k2.7-code` | `ollama-cloud/kimi-k2.7-code` | 변경 없음 |
| `large_project` | `ollama-cloud/glm-5.2` | `ollama-cloud/glm-5.2` | 변경 없음 |

#### Hermes 에이전트

| 항목 | 변경 전 | 변경 후 | 사유 |
| - | - | - | - |
| 기본 모델 | `glm-5.1` | `deepseek-v4-flash` | 자율 루프에서 압도적 속도와 GPU 효율, 안정적 Tool Call로 루프 끊김 방지 |
| 폴백 체인 | `glm-5.1` -> `gemma4:cloud` | `deepseek-v4-flash` -> `qwen3.5:cloud` | 기본 모델 변경에 따른 폴백 체인 업데이트 |
| 비전 보조 | `gemma4:cloud` | `qwen3.5:cloud` | 한국어 비전 이해 및 멀티모달 처리 능력 향상 |
| 웹 추출 | `gemma4:cloud` | `qwen3.5:cloud` | 한국어 요약 품질 향상 |
| 컨텍스트 압축 | `gemma4:cloud` | `qwen3.5:cloud` | 요약 품질 및 한국어 가독성 향상 |

### Gemma 4 제거 사유

1. **에이전트 성능 저하**: Gemma 4(31B)는 범용 벤치마크에서는 준수하나,
   에이전트 워크플로우(Tool Call, JSON 스키마 준수, 장시간 루프
   안정성)에서 일관되게 성능이 저하되는 현상이 확인됨. 특히 Hermes
   Agent의 자율 루프에서 JSON 포맷 오류 및 응답 누락이 빈번히 발생.
2. **한국어 처리 한계**: 한국어 지시사항 이해 및 자연스러운 한국어 출력
   품질이 Qwen 3.5 Cloud에 비해 현저히 낮음. 에이전트 환경에서 한국어
   소통이 잦은 점을 고려하면 치명적 제약.
3. **비전 성능**: 멀티모달 비전 작업(스크린샷 분석, OCR, 차트 해석
   등)에서 Qwen 3.5 Cloud 대비 정확도와 디테일이 부족함. 특히 복잡한 UI
   스크린샷이나 다국어 문서 해석에서 차이가 뚜렷함.
4. **루프 효율성**: Hermes Agent의 10-20단계 자율 루프에서 Gemma 4는
   지연이 크고 출력 토큰 효율이 낮아 클라우드 사용량(Quota)을 빠르게
   소모. DeepSeek V4 Flash로 대체 시 동일 작업 대비 약 3-5배 빠른 루프
   완료 확인.
