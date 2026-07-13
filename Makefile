generate:
	tuist install
	tuist generate

clean:
	rm -rf **/**/**/*.xcodeproj
	rm -rf **/**/*.xcodeproj
	rm -rf **/*.xcodeproj
	rm -rf *.xcworkspace

reset:
	tuist clean
	rm -rf **/**/**/*.xcodeproj
	rm -rf **/**/*.xcodeproj
	rm -rf **/*.xcodeproj
	rm -rf *.xcworkspace

regenerate:
	rm -rf **/**/**/*.xcodeproj
	rm -rf **/**/*.xcodeproj
	rm -rf **/*.xcodeproj
	rm -rf *.xcworkspace
	tuist install
	tuist generate

# Privates 파일 다운로드/업로드

.PHONY: download-privates upload-privates _download-privates _ensure-token

BASE_URL=https://raw.githubusercontent.com/khyeji98/DDD-iOS2-iOS-private/main

XCCONFIG_FILES = \
	Debug.xcconfig \
	Prod.xcconfig \
	Release.xcconfig \
	Secrets.xcconfig

_ensure-token:
	@if [ ! -f .env ]; then \
		printf "Enter your GitHub access token: "; \
		read token; \
		echo "GITHUB_ACCESS_TOKEN=$$token" > .env; \
	fi
	@set -a; . ./.env; set +a; \
	if [ -z "$$GITHUB_ACCESS_TOKEN" ]; then \
		echo "ERROR: GITHUB_ACCESS_TOKEN is empty in .env"; \
		exit 1; \
	fi

download-privates: _ensure-token
	@$(MAKE) --no-print-directory _download-privates

_download-privates:
	@set -a; . ./.env; set +a; \
	mkdir -p Config; \
	for FILE in $(XCCONFIG_FILES); do \
		echo "Downloading $$FILE..."; \
		if ! curl -fsSL \
			-H "Authorization: token $$GITHUB_ACCESS_TOKEN" \
			-o Config/$$FILE \
			$(BASE_URL)/$$FILE; then \
			rm -f Config/$$FILE; \
			echo ""; \
			echo "ERROR: Failed to download $$FILE"; \
			echo "  - 토큰 만료/오타 또는 네트워크 문제일 수 있습니다"; \
			echo "  - .env를 확인하거나 삭제 후 다시 실행해 주세요"; \
			exit 1; \
		fi; \
	done; \
	echo "All xcconfig files downloaded to Config/"

upload-privates: _ensure-token
	@set -a; . ./.env; set +a; \
	python3 Scripts/upload_privates.py
