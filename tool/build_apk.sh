#!/usr/bin/env bash
# Builds the release APKs (one per ABI) and copies them to build/release/
# under a name that carries the app name and version, for example
# MaTontine-1.0.0+2-arm64-v8a.apk.
#
# Usage: tool/build_apk.sh [extra flutter build flags]
# The version comes from pubspec.yaml, unless --build-name / --build-number
# are passed, in which case those values are used for the file names too.
set -euo pipefail

cd "$(dirname "$0")/.."

app_name="MaTontine"
version_line="$(grep -E '^version:' pubspec.yaml | head -n 1)"
version="${version_line#version:}"
version="${version// /}"
build_name="${version%%+*}"
build_number=""
[[ "$version" == *+* ]] && build_number="${version#*+}"

for arg in "$@"; do
  case "$arg" in
    --build-name=*) build_name="${arg#--build-name=}" ;;
    --build-number=*) build_number="${arg#--build-number=}" ;;
  esac
done

full_version="$build_name"
[[ -n "$build_number" ]] && full_version="$build_name+$build_number"

flutter build apk --release --split-per-abi "$@"

src_dir="build/app/outputs/flutter-apk"
out_dir="build/release"
mkdir -p "$out_dir"

copied=0
for apk in "$src_dir"/app-*-release.apk; do
  [[ -e "$apk" ]] || continue
  abi="$(basename "$apk")"
  abi="${abi#app-}"
  abi="${abi%-release.apk}"
  target="$out_dir/$app_name-$full_version-$abi.apk"
  cp "$apk" "$target"
  echo "→ $target"
  copied=$((copied + 1))
done

if [[ "$copied" -eq 0 ]]; then
  echo "No APK found in $src_dir" >&2
  exit 1
fi
