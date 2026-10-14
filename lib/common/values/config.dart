// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:comics_app/common/widgets/countdown_update_model.dart';
import 'package:crypto/crypto.dart';

class Config {
  //是否为DEBUG模式
  static const bool DEBUG = false;

  //域名池（获取域名后，使用域名池进行轮询）
  static List<String> DOMAIN_POOL_URLS = [
    'https://line.lytv.rpwujn.com',
    "https://rbtnefpzqz.xyz",
    "https://zur3jmpyg8.xyz",
  ];

  // 域名池(测试) 没给测试域名
  static List<String> BASE_HOSTS_DEBUG = [
    "https://4j754v4xea.xyz/",
  ];

  //默认请求域名（域名池默认域名，加速）
  static String DEFAULT_BASE_HOST = "";

  //请求域名(域名池获取的备用域名)
  static List<String> BASE_HOSTS_REPLACE = [];

  /// 网关信封选密钥下标：为 true 时用 `(time毫秒/1000) % 密钥数`（与部分 Java 端「秒级时间戳」一致）。
  static bool GATEWAY_ENCRYPT_KEY_INDEX_USE_SECONDS = false;

  /// 为 true 时在 Debug 下打印 [decryptGatewayEnvelopeString] 解密明文（含敏感信息，联调后可关）。
  static bool GATEWAY_DECRYPT_LOG_PLAINTEXT = true;

  /// 为 true 时，在 [HttpLogInterceptor] 打出 `bodyParam` 后追加打印网关 POST 里 [data] 解密后的内层 JSON（仅联调开启）。
  static bool GATEWAY_LOG_DECRYPT_REQUEST_BODY = true;

  /// 文档：GET jwt-token，Header 携带 machineCode（直连上传等场景与 [Address.baseApiPath] 拼完整 URL）
  static const String JWT_TOKEN_API_PATH = 'app/jwt-token';

  //api加密密钥数组
  static List<String> API_ENCRYPT_KEYS = [
    'cmxykjj2nbqhhcca',
    'vthr644nu4w2qgbk',
    's31kkaadk3mp1qt8',
    'nqt7po9q8f4mzj8r',
    'ax1orz01wq5ph4ae',
    'rkor18h0nw98ptmi',
    'chkoczfcfjm2n822',
    '1xuorxwq3pvqcanx',
    'w1dyjl9714759yz9',
    'sbevm2x4sdacxcoz',
  ];

  /// 获取加密后的设备id验签
  static String getDevToken(String devId) {
    String a = "g24p5VJ4fJ";
    String b = "5P#at%Yu";
    String c = "ZPRwQuKl8YlVIr";
    String s = a + b + c + devId + a + b + c;
    var data = utf8.encode(s);
    var chiper = sha256.convert(data);
    return base64Encode(chiper.bytes);
  }

  static String get encryptKey {
    String a = "dkV1a0EmdzE";
    String b = "1ejRWQUQza0FZI2ZrTCNy";
    String c = "Qm5VIVdEaE4=";
    String ret = String.fromCharCodes(base64Decode(a + b + c));
    return ret;
  }

  ///防重放攻击密钥
  static const ANTI_REPLAY_ATTACK_KEY = "kaFtkDJRcchRMTI9";

  ///是否显示过支付提示
  static bool IS_SHOW_PAYMENT_TIPS = false;

  static bool isFirstLoad = true;

  static bool DNS_CUSTOM = false;

  static String DNS_IP = "223.5.5.5";

  static String? aiUndressPrice;

  static int? aiChangeFaceImgPrice;

  static const SWITCH_CDN_ADDRESS = "SWITCH_CDN_ADDRESS";

  /// 图片 CDN / 封面线路切换后广播，用于全局刷新网络图。
  static const SWITCH_PICTURE_LINE = "SWITCH_PICTURE_LINE";

  static Countdown? countdown;

  static int appTheme = 0;

  /// 0:默认主题 1:新春主题

  static bool isNewYearTheme() {
    return appTheme == 1;
  }
}
