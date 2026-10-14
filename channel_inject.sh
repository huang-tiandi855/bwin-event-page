#!/bin/bash
#注入渠道码到 APK 中
# ./channel_inject.sh <apk路径> <渠道码> [输出目录]
# 默认输出到 APK 同级 channel/ 目录
#示例：
#./channel_inject.sh ./release/xaw_260702_1209_1.0.9_12/xaw_260702_1209_1.0.9_12.apk 9528
#检测渠道码是否注入成功
#java -jar walle-cli-all.jar show <apk路径>
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WALLE_CLI="${SCRIPT_DIR}/android/tools/walle-cli-all.jar"

usage() {
  cat <<EOF
用法: $(basename "$0") <apk路径> <渠道码> [输出目录]

将 Walle 渠道码写入已有 APK，输出文件名与 apk_build.sh 渠道包一致：
  {基础包名}_{渠道码}.apk

示例:
  $(basename "$0") ./release/xaw_260702_1209_1.0.9_12/xaw_260702_1209_1.0.9_12.apk 9528
  $(basename "$0") ./base.apk 9528 ./output/channel

未指定输出目录时，默认写入 APK 同级目录下的 channel/ 文件夹。
EOF
}

trim_line() {
  echo "$1" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

apk_input="$1"
channel_code=$(trim_line "$2")
output_dir="${3:-}"

if [[ -z "$channel_code" ]]; then
  echo "\033[31m[错误] 渠道码不能为空\033[0m"
  exit 1
fi

if [[ ! -f "$WALLE_CLI" ]]; then
  echo "\033[31m[错误] 缺少 walle-cli：$WALLE_CLI\033[0m"
  exit 1
fi

if [[ ! -f "$apk_input" ]]; then
  echo "\033[31m[错误] APK 不存在：$apk_input\033[0m"
  exit 1
fi

apk_src="$(cd "$(dirname "$apk_input")" && pwd)/$(basename "$apk_input")"
apk_basename="$(basename "$apk_src" .apk)"
apk_dir="$(dirname "$apk_src")"

if [[ -z "$output_dir" ]]; then
  output_dir="${apk_dir}/channel"
else
  output_dir="$(mkdir -p "$output_dir" && cd "$output_dir" && pwd)"
fi

output_apk="${output_dir}/${apk_basename}_${channel_code}.apk"
mkdir -p "$output_dir"

echo "> Inject channel: ${channel_code}"
echo ">   From: $apk_src"
echo ">   To:   $output_apk"

if ! java -jar "$WALLE_CLI" put -c "$channel_code" "$apk_src" "$output_apk"; then
  echo "\033[31m[错误] 渠道包生成失败\033[0m"
  exit 1
fi

echo "> Done: $(basename "$output_apk")"
