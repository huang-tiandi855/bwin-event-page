#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Flutter 3.16.x 在 Apple Silicon 上仍使用 darwin-x64 的 gen_snapshot，需 Rosetta。
flutter_cmd() {
  if [[ "$(uname -m)" == "arm64" ]]; then
    if ! arch -x86_64 /usr/bin/true 2>/dev/null; then
      echo "\033[31m[错误] Apple Silicon 打包需要 Rosetta，请先执行：\033[0m"
      echo "  sudo softwareupdate --install-rosetta --agree-to-license"
      exit 1
    fi
    arch -x86_64 flutter "$@"
  else
    flutter "$@"
  fi
}

trim_line() {
  echo "$1" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# 定位 release APK（Gradle 会改名为 xaw__release_*.apk）
find_release_apk() {
  local p
  for p in \
    "./build/app/outputs/flutter-apk/app-release.apk" \
    "./build/app/outputs/apk/release/app-release.apk"; do
    if [[ -f "$p" ]]; then
      echo "$p"
      return 0
    fi
  done
  p=$(find ./build/app/outputs/apk/release -maxdepth 1 -name '*.apk' -type f -print0 2>/dev/null \
    | xargs -0 ls -t 2>/dev/null | head -1)
  if [[ -n "$p" && -f "$p" ]]; then
    echo "$p"
    return 0
  fi
  return 1
}

generate_walle_channels() {
  local apk_src="$1"
  local channels_dir="$2"
  local channel_file="$3"
  local walle_cli="$4"

  if [[ ! -f "$walle_cli" ]]; then
    echo "\033[31m[错误] 缺少 walle-cli：$walle_cli\033[0m"
    exit 1
  fi
  if [[ ! -f "$channel_file" ]]; then
    echo "\033[31m[错误] 缺少渠道配置文件：$channel_file\033[0m"
    exit 1
  fi

  rm -rf "$channels_dir"
  mkdir -p "$channels_dir"

  echo "> Generating Walle channel APKs (walle-cli)."
  local channel
  while IFS= read -r channel || [[ -n "$channel" ]]; do
    channel=$(trim_line "$channel")
    [[ -z "$channel" ]] && continue
    if ! java -jar "$walle_cli" put -c "$channel" "$apk_src" "${channels_dir}/${channel}.apk"; then
      echo "\033[31m[错误] 渠道包生成失败：${channel}\033[0m"
      exit 1
    fi
  done < "$channel_file"
}

ver=$(grep 'version:' pubspec.yaml)
configPath=$(grep 'static const bool DEBUG' ./lib/common/values/config.dart | awk -F= '{print $2}')
ver=${ver##'version: '}
ver_safe=${ver//+/_}
time=$(date "+%y%m%d_%H%M")
base_name="91fls_${time}_${ver_safe}"
release_dir="./release/${base_name}"
channel_release_dir="${release_dir}/channel"
channels_dir="./build/app/outputs/channels"
walle_cli="./android/tools/walle-cli-all.jar"
channel_file="./channel"

echo "\033[33m> Check version from 'pubspec.yaml': \033[31m$ver\033[0m"
echo "\033[33m> Check DEBUG from config: \033[31m${configPath:-1}\033[0m"

# 根据 config.dart 中的 DEBUG 字段提示确认
debug_value=$(echo "$configPath" | tr -d ' ;')
if [[ "$debug_value" == "true" ]]; then
  prompt_msg="\033[33m> 确认打包 Debug 线路吗？按回车继续，Ctrl+C 取消：\033[0m"
elif [[ "$debug_value" == "false" ]]; then
  prompt_msg="\033[33m> 确认打包 Release 线路吗？按回车继续，Ctrl+C 取消：\033[0m"
else
  prompt_msg="\033[31m> 未识别 DEBUG 值（${debug_value:-空}），按回车继续，Ctrl+C 取消：\033[0m"
fi
printf "$prompt_msg"
read -r _

mkdir -p release "$release_dir"

echo "> Now begin building apk."
flutter_cmd build apk --target-platform android-arm64 --shrink --split-debug-info=./build/debuginfo

apk_src=$(find_release_apk) || {
  echo "\033[31m[错误] 未找到 release APK，请检查 build/app/outputs/\033[0m"
  exit 1
}

base_dest="${release_dir}/${base_name}.apk"
echo "> Copy base APK."
echo ">   From: $apk_src"
echo ">   To:   $base_dest"
cp "$apk_src" "$base_dest"
echo "> Base APK done: ${base_name}.apk"

channel_count=0
printf "\033[33m> 是否继续打渠道包？按回车继续，输入 n 跳过：\033[0m"
read -r build_channels
if [[ "$build_channels" != "n" && "$build_channels" != "N" ]]; then
  generate_walle_channels "$apk_src" "$channels_dir" "$channel_file" "$walle_cli"

  mkdir -p "$channel_release_dir"
  echo "> Copy channel APKs to ${channel_release_dir}/"
  while IFS= read -r channel_apk; do
    [[ -f "$channel_apk" ]] || continue
    channel=$(basename "$channel_apk" .apk)
    channel_dest="${channel_release_dir}/${base_name}_${channel}.apk"
    cp "$channel_apk" "$channel_dest"
    echo ">   channel/${base_name}_${channel}.apk"
    channel_count=$((channel_count + 1))
  done < <(find "$channels_dir" -maxdepth 1 -name '*.apk' -type f | sort)

  if [[ "$channel_count" -eq 0 ]]; then
    echo "\033[31m[警告] 未生成任何渠道包，请检查 channel 与 walle-cli 配置\033[0m"
  fi
else
  echo "> 已跳过渠道包。"
fi

echo "> Built release directory: $release_dir"
echo ">   Base APK:     ${base_name}.apk"
echo ">   Channel APKs: ${channel_count} files in channel/"
