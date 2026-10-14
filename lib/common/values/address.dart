import '../entities/config.dart';

///地址数据
class Address {
  /// 文档统一网关路径（相对选线后的业务根域名）
  static const String gatewayPath = "a/main/request";

  /// API域名
  static late String baseUrl;

  /// API域名 + 基本的PATH
  static late String baseApiPath;

  /// 服务端上传地址（完整 URL，含路径），由后台 `APP.uploadUrl` 下发。
  ///
  /// 业务侧（图片 / 视频上传）直接以 `Address.uploadUrl` 作为请求目标，
  /// 无需再拼接 `/vid/uploadStatic` 等子路径。该字段一般情况下不会为空，
  /// 若为空则属于后台未下发配置的问题，由后端排查。
  static String? uploadUrl;
  /// 聊天模块上传地址。
  static String? chatUploadUrl;

  ///图片加载地址
  static String? baseImagePath;

  ///官网地址
  static String? baseGroupUrl;

  ///落地页地址
  static String? groundURl;

  ///代理规则
  static String? proxyRuleUrl;

  ///常见问题
  static String? commonQuestion;

  /// 活动地址
  static String? activityUrl;

  /// 落地页地址
  static String? landUrl;

  /// 福利广场应用中心链接
  static String? appCenterUrl;
  static String? audioUrl;

  /// 分享链接
  static String? shareUrlLink;

  /// 商务合作
  static String? businessCooperation;

  /// 官方邮箱
  static String? groupEmail;

  /// m3u8 视频解密密钥内容
  static dynamic m3u8SecretContent;

  /// 图片 CDN 线路（`APP.pictureUrls`）
  static List<PlayLineConfig>? pictureLines;

  /// 当前选中的图片 CDN 线路域名。
  static String? pictureLine;

  /// h5视频播放线路域名
  static List<PlayLineConfig>? h5PlayLines;

  /// 当前选中的h5视频播放线路域名，未选择时默认使用[h5PlayLines]第一条。
  static String? h5PlayLine;

  /// qv1视频播放线路域名
  static List<PlayLineConfig>? qvPlayLines;

  static List<Domain> cdnAddressLists = [];
  static List<SourceList>? sourceList;

  /////通过支付宝API解析银行卡号发卡行和银行卡类别、获取银行LOGO
  static const ALI_CCD_API =
      "https://ccdcapi.alipay.com/validateAndCacheCardInfo.json?_input_charset=utf-8&cardBinCheck=true&cardNo=";

  /// 图片 CDN 根域名：优先 [pictureLine]，否则 [pictureLines] 第一条，再回退 [baseImagePath]。
  static String get pictureBaseUrl {
    final String? selectedLine = pictureLine?.trim();
    if (selectedLine != null && selectedLine.isNotEmpty) {
      return selectedLine;
    }
    final String? line = pictureLines?.isNotEmpty == true
        ? pictureLines!.first.line?.trim()
        : null;
    if (line != null && line.isNotEmpty) {
      return line;
    }
    return (baseImagePath ?? '').trim();
  }

  /// H5视频播放域名，默认取播放线路第一条。
  static String get h5PlayBaseUrl {
    final String? selectedLine = h5PlayLine?.trim();
    if (selectedLine != null && selectedLine.isNotEmpty) {
      return selectedLine;
    }

    final String? line = h5PlayLines?.isNotEmpty == true
        ? h5PlayLines!.first.line?.trim()
        : null;
    return (line == null || line.isEmpty) ? baseApiPath : line;
  }

  static String buildH5VideoUrl(
    String? sourceUrl, {
    String? token,
    bool withCdn = true,
  }) {
    final String source = sourceUrl ?? '';
    if (source.isEmpty ||
        source.startsWith('http://') ||
        source.startsWith('https://')) {
      return source;
    }

    // 兼容两端的「斜杠多写 / 漏写」：base 末尾的连续 `/` 全削，source 前面的
    // 连续 `/` 全削，再用一个 `/` 连起来。这样：
    //   base = `https://x.com/`     + source = `/a/b.mp4`  → `https://x.com/a/b.mp4`
    //   base = `https://x.com`      + source = `a/b.mp4`   → `https://x.com/a/b.mp4`
    //   base = `https://x.com//`    + source = `///a/b`    → `https://x.com/a/b`
    final String baseUrl = h5PlayBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    final String relPath = source.replaceFirst(RegExp(r'^/+'), '');
    final StringBuffer url = StringBuffer('$baseUrl/$relPath');
    final List<String> query = <String>[];

    if (token != null && token.isNotEmpty) {
      // query.add('token=$token');
    }
    if (withCdn) {
      // 预留 CDN 拼接位
    }
    if (query.isNotEmpty) {
      url.write('?${query.join('&')}');
    }
    return url.toString();
  }
}
