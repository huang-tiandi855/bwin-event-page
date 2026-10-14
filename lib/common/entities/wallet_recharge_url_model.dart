class RechargeUrlModel {
  String? oid;
  String? payUrl;
  String? sign;

  /// url打开外部支付链接;sdk/打开可以sdk
  String? mode;

  static RechargeUrlModel? fromJson(Map<String, dynamic>? map) {
    if (map == null) return null;
    if (map["data"] != null) {
      var data = map["data"];

      ///返回数据结构错误
      if (data is String) {
        return null;
      }
      RechargeUrlModel bean = RechargeUrlModel();
      bean.oid = data['oid'];
      bean.payUrl = data['payUrl'];
      bean.sign = data['sign'];
      bean.mode = data['mode'];
      return bean;
    }
    return null;
  }

  Map toJson() => {
        "oid": oid,
        "payUrl": payUrl,
        "sign": sign,
        "mode": mode,
      };
}
