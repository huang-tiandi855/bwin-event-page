import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/values/address.dart';

/// 与 Web `pickImageJoinBaseUrl` 一致：`pictureUrls[0].line` 优先，否则 `picBaseUrl` / `newPicBaseUrl`。
String pickImageJoinBaseFromConfig(ConfigBean c) {
  final List<PlayLineConfig>? list = c.pictureUrlsList;
  if (list != null && list.isNotEmpty) {
    final String? line = list.first.line?.trim();
    if (line != null && line.isNotEmpty) {
      return line;
    }
  }
  final String? fb = (c.newPicBaseUrl ?? c.picBaseUrl)?.trim();
  return fb ?? '';
}

/// 配置下发后同步到 [Address.baseImagePath]，供历史 `getPath` / 拼接逻辑使用。
void syncAddressBaseImagePathFromConfig(ConfigBean c) {
  final String? selected = Address.pictureLine?.trim();
  if (selected != null &&
      selected.isNotEmpty &&
      (c.pictureUrlsList?.any((e) => e.line?.trim() == selected) ?? false)) {
    Address.baseImagePath = selected;
    return;
  }
  final String base = pickImageJoinBaseFromConfig(c);
  if (base.isNotEmpty) {
    Address.baseImagePath = base;
    Address.pictureLine ??= base;
  }
}

/// 用户切换图片线路后写入 [Address] 并同步 [Address.baseImagePath]。
void applyPictureLineSelection(String? line) {
  final String trimmed = (line ?? '').trim();
  if (trimmed.isEmpty) return;
  Address.pictureLine = trimmed;
  Address.baseImagePath = trimmed;
}

/// 与 Web `resolveDisplayImageUrl` 一致：绝对 URL 原样；否则与图片域名单边去斜杠拼接。
String resolveCdnImageUrl(String? pathOrUrl) {
  final String raw = (pathOrUrl ?? '').trim();
  if (raw.isEmpty) return '';
  final String lower = raw.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return raw;
  }
  final String base = Address.pictureBaseUrl;
  if (base.isEmpty) return '';
  final String b = base.replaceAll(RegExp(r'/+$'), '');
  final String rel = raw.replaceAll(RegExp(r'^/+'), '');
  return '$b/$rel';
}

