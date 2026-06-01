#!/usr/bin/env bash
#
# VPEPlayer SDK 참조 전환 스크립트
# ---------------------------------------------------------------------------
# demoapp 루트에 `.local.env` 파일이 있으면  → 로컬 패키지(../sdk) 참조
#                          없으면            → 바이너리 SwiftPM 패키지(GitHub release) 참조
#
# pbxproj 의 패키지 참조 섹션(XCLocalSwiftPackageReference / XCRemoteSwiftPackageReference)을
# 그 자리에서 교체한다. `.local.env` 는 .gitignore 로 제외되므로, 저장소에 커밋되는 pbxproj는
# 항상 "바이너리 참조" 상태가 기본이다.
#
# 사용:
#   scripts/select-sdk.sh            # .local.env 유무에 따라 자동 전환
#   scripts/select-sdk.sh local      # 강제 로컬
#   scripts/select-sdk.sh remote     # 강제 바이너리
# ---------------------------------------------------------------------------
set -euo pipefail

DEMO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PBX="$DEMO_DIR/VPEDemo.xcodeproj/project.pbxproj"
ENV_FILE="$DEMO_DIR/.local.env"

# 설정 (필요 시 .local.env 에서 override)
REPO_URL="https://github.com/SGRsoft-Dev/vpe2-ios-native-sdk.git"
MIN_VERSION="1.0.4"
LOCAL_PATH="../sdk"
PKG_ID="AA0000000000000000000030"   # pbxproj 내 패키지 reference object id (고정)

# 모드 결정
MODE="${1:-}"
if [ -z "$MODE" ]; then
  if [ -f "$ENV_FILE" ]; then MODE="local"; else MODE="remote"; fi
fi
# .local.env 에서 변수 override (있으면)
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE" || true
  REPO_URL="${VPE_SDK_REPO_URL:-$REPO_URL}"
  MIN_VERSION="${VPE_SDK_MIN_VERSION:-$MIN_VERSION}"
  LOCAL_PATH="${VPE_SDK_LOCAL_PATH:-$LOCAL_PATH}"
fi

echo "▶ SDK 참조 모드: $MODE"

python3 - "$PBX" "$MODE" "$REPO_URL" "$MIN_VERSION" "$LOCAL_PATH" "$PKG_ID" <<'PY'
import re, sys
pbx, mode, repo, ver, localpath, pkg = sys.argv[1:7]
s = open(pbx, encoding="utf-8").read()

local_label  = f'{pkg} /* XCLocalSwiftPackageReference "{localpath}" */'
remote_label = f'{pkg} /* XCRemoteSwiftPackageReference "vpe2-ios-native-sdk" */'

# 1) packageReferences 목록의 라벨 라인 (어느 형태든 한 줄)
s = re.sub(
    r'%s /\* XC(Local|Remote)SwiftPackageReference[^\n]*\*/,' % re.escape(pkg),
    (local_label if mode == "local" else remote_label) + ",",
    s, count=1)

# 2) product dependency 의 package = ... 라인 (있으면 라벨 교체)
s = re.sub(
    r'package = %s /\* XC(Local|Remote)SwiftPackageReference[^\n]*\*/;' % re.escape(pkg),
    "package = " + (local_label if mode == "local" else remote_label) + ";",
    s)

# 3) 패키지 정의 섹션 통째로 교체
local_section = (
    "/* Begin XCLocalSwiftPackageReference section */\n"
    f"\t\t{local_label} = {{\n"
    "\t\t\tisa = XCLocalSwiftPackageReference;\n"
    f"\t\t\trelativePath = {localpath};\n"
    "\t\t};\n"
    "/* End XCLocalSwiftPackageReference section */"
)
remote_section = (
    "/* Begin XCRemoteSwiftPackageReference section */\n"
    f"\t\t{remote_label} = {{\n"
    "\t\t\tisa = XCRemoteSwiftPackageReference;\n"
    f'\t\t\trepositoryURL = "{repo}";\n'
    "\t\t\trequirement = {\n"
    "\t\t\t\tkind = upToNextMajorVersion;\n"
    f"\t\t\t\tminimumVersion = {ver};\n"
    "\t\t\t};\n"
    "\t\t};\n"
    "/* End XCRemoteSwiftPackageReference section */"
)
section_re = re.compile(
    r'/\* Begin XC(?:Local|Remote)SwiftPackageReference section \*/.*?'
    r'/\* End XC(?:Local|Remote)SwiftPackageReference section \*/',
    re.DOTALL)
new_section = local_section if mode == "local" else remote_section
if section_re.search(s):
    s = section_re.sub(lambda _: new_section, s, count=1)
else:
    print("ERROR: package reference section not found", file=sys.stderr); sys.exit(1)

open(pbx, "w", encoding="utf-8").write(s)
print(f"  ✔ pbxproj → {'local (' + localpath + ')' if mode=='local' else 'remote (' + repo + ' @ ' + ver + ')'}")
PY

echo "  완료. Xcode가 열려 있으면 프로젝트를 닫았다 다시 여세요(패키지 재해결)."
