import 'dart:typed_data';

/// 与 Web `imageXorDecrypt.ts` / Java `decode(byte[])` 一致：首字节为单字节密钥，其后与密钥异或。
Uint8List? xorKeyDecode(Uint8List bytes) {
  if (bytes.length < 2) return null;
  final int key = bytes[0];
  final Uint8List out = Uint8List(bytes.length - 1);
  for (int i = 1; i < bytes.length; i++) {
    out[i - 1] = bytes[i] ^ key;
  }
  return out;
}

bool isLikelyImageBytes(Uint8List bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff) {
    return true;
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47) {
    return true;
  }
  if (bytes.length >= 3 &&
      bytes[0] == 0x47 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46) {
    return true;
  }
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return true;
  }
  return false;
}

// --- 旧版 CDN 加密（魔数头 / 固定 XOR / 前 100 字节字符串 key）---

final List<Uint8List> _legacyFeaturesList = <Uint8List>[
  Uint8List.fromList(<int>[0xff, 0xd8, 0xff]),
  Uint8List.fromList(
      <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
  Uint8List.fromList(<int>[0x47, 0x49, 0x46]),
];

const List<int> _encryptMagicNumber = <int>[
  0x88,
  0xA8,
  0x30,
  0xCB,
  0x10,
  0x76
];

const int _legacyEncryptKey = 0xA3;
const int _legacyEncryptedLen = 100;
final Uint8List _legacyDecryptKey =
    Uint8List.fromList('2019ysapp7527'.codeUnits);

bool _legacyIsEncryptedImage(Uint8List imgBytes) {
  bool isDecrypted = false;
  final int featuresLen = _legacyFeaturesList.length;
  for (int i = 0; i < featuresLen; i++) {
    isDecrypted = false;
    for (int j = 0; j < _legacyFeaturesList[i].length; j++) {
      if (_legacyFeaturesList[i][j] != imgBytes[j]) {
        isDecrypted = true;
        break;
      }
    }
    if (isDecrypted) {
      continue;
    } else {
      break;
    }
  }
  return isDecrypted;
}

Uint8List _legacyXorBaseAllLength(Uint8List src) {
  var index = -1;
  const int marker = 0x7fffffff;
  return Uint8List.fromList(
    src
        .map((int it) {
          index++;
          if (index < _encryptMagicNumber.length &&
              it == _encryptMagicNumber[index]) {
            return marker;
          }
          return it ^ _legacyEncryptKey;
        })
        .where((int element) => element != marker)
        .toList(),
  );
}

Uint8List _legacyXorBaseLength(Uint8List src, Uint8List key, int length) {
  int srcLen = src.length;
  int keyLen = key.length;
  if (length > srcLen || length <= 0) {
    length = srcLen;
  }
  for (int i = 0; i < length; i += keyLen) {
    for (int j = 0; j < keyLen && i + j < length; j++) {
      src[i + j] ^= key[j];
    }
  }
  return src;
}

/// 仅旧协议解密（不含首字节密钥 XOR）。
Uint8List legacyDecryptImage(Uint8List imgBytes) {
  if (imgBytes.isEmpty) {
    return imgBytes;
  }
  var isAll = false;
  for (int i = 0; i < _encryptMagicNumber.length; i++) {
    if (_encryptMagicNumber[i] != imgBytes[i]) {
      continue;
    }
    isAll = true;
  }
  if (isAll) {
    imgBytes = _legacyXorBaseAllLength(imgBytes);
  } else {
    if (_legacyIsEncryptedImage(imgBytes)) {
      imgBytes = _legacyXorBaseLength(imgBytes, _legacyDecryptKey, _legacyEncryptedLen);
    }
  }
  return imgBytes;
}

/// 对 HTTP 拉取到的 body 做统一解码（与 Web 行为对齐并兼容旧 CDN）。
///
/// 1. 已是合法图片魔数 → 原样返回（明文图）。
/// 2. [xorEnabled] 为 true 时尝试 `xorKeyDecode`，魔数校验通过则返回。
/// 3. 否则走 [legacyDecryptImage]。
Uint8List decodeFetchedBody(Uint8List raw, {required bool xorEnabled}) {
  if (raw.isEmpty) return raw;
  if (isLikelyImageBytes(raw)) {
    return raw;
  }
  if (xorEnabled) {
    final Uint8List? decoded = xorKeyDecode(raw);
    if (decoded != null && isLikelyImageBytes(decoded)) {
      return decoded;
    }
  }
  return legacyDecryptImage(raw);
}
