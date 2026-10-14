import 'dart:convert';
import 'dart:typed_data';

import 'package:comics_app/common/utils/logger.dart';
import 'package:comics_app/common/values/config.dart';
import 'package:encrypt/encrypt.dart';

/// 与 `gatewayCrypto.ts` / 后端 `/a/main/request` 约定：密钥下标 `time % 密钥数组长度`（毫秒，与 [Config.GATEWAY_ENCRYPT_KEY_INDEX_USE_SECONDS] 可切换秒级）。
String pickGatewayEncryptKey(int timeMillis) {
  final List<String> keys = Config.API_ENCRYPT_KEYS;
  if (keys.isEmpty) {
    return Config.encryptKey;
  }
  int t = timeMillis.abs();
  if (Config.GATEWAY_ENCRYPT_KEY_INDEX_USE_SECONDS) {
    t ~/= 1000;
  }
  return keys[t % keys.length];
}

/// 网关信封加密：与 `gatewayCrypto.ts` 的 `encryptGatewayDataObject` 一致。
/// AES-128-ECB + PKCS7；[keyStr] UTF-8 须为 **16 字节**（当前密钥串均为 ASCII 16 字符）；输出为 **纯密文** Base64（无 OpenSSL 盐、无 nonce）。
String encryptGatewayEnvelopeString(String plainText, String keyStr) {
  final Uint8List keyBytes = Uint8List.fromList(utf8.encode(keyStr));
  if (keyBytes.length != 16) {
    throw ArgumentError(
      'Gateway AES-128 key must be 16 bytes (UTF-8), got ${keyBytes.length}',
    );
  }
  final Encrypter encrypter = Encrypter(
    AES(Key(keyBytes), mode: AESMode.ecb, padding: 'PKCS7'),
  );
  final Encrypted enc = encrypter.encryptBytes(utf8.encode(plainText));
  return enc.base64;
}

/// 网关信封解密：与 `gatewayCrypto.ts` 的 `decryptGatewayDataString` 一致。
///
/// [logDecryptedPlaintext] 为 false 时不打印明文（例如 [HttpLogInterceptor] 已单独打日志）。
String decryptGatewayEnvelopeString(
  String cipherBase64,
  String keyStr, {
  bool logDecryptedPlaintext = true,
}) {
  final String s = cipherBase64.trim();
  if (s.isEmpty) {
    throw ArgumentError('empty gateway cipher');
  }
  final Uint8List keyBytes = Uint8List.fromList(utf8.encode(keyStr));
  if (keyBytes.length != 16) {
    throw ArgumentError(
      'Gateway AES-128 key must be 16 bytes (UTF-8), got ${keyBytes.length}',
    );
  }
  final Encrypter encrypter = Encrypter(
    AES(Key(keyBytes), mode: AESMode.ecb, padding: 'PKCS7'),
  );
  final String plain = encrypter.decrypt64(s);
  if (logDecryptedPlaintext && Config.GATEWAY_DECRYPT_LOG_PLAINTEXT) {
    l.d('decryptGatewayEnvelopeString 解密结果: $plain', tag: 'gateway_crypto');
  }
  return plain;
}

/// 从网关/业务响应里的 [time]（毫秒或与文档一致的字符串）推导选密钥用的时间戳。
int millisForGatewayKeyFromResponse(dynamic timeField) {
  if (timeField == null) {
    return DateTime.now().millisecondsSinceEpoch;
  }
  if (timeField is int) {
    return timeField;
  }
  if (timeField is String) {
    final int? asInt = int.tryParse(timeField);
    if (asInt != null) {
      return asInt;
    }
    try {
      return DateTime.parse(timeField).millisecondsSinceEpoch;
    } catch (_) {}
  }
  return DateTime.now().millisecondsSinceEpoch;
}

/// 与网关约定一致：按响应 [time] 选密钥，对 [cipherBase64] 做 AES-128-ECB PKCS7 解密。
String decryptGatewayCipherWithResponseTime(
  String cipherBase64,
  dynamic timeField, {
  bool logDecryptedPlaintext = true,
}) {
  final int ts = millisForGatewayKeyFromResponse(timeField);
  return decryptGatewayEnvelopeString(
    cipherBase64,
    pickGatewayEncryptKey(ts),
    logDecryptedPlaintext: logDecryptedPlaintext,
  );
}
