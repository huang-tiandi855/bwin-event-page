/// 粘贴版信息
class CutInfo {
  // pc是邀请码promoteCode
  String? pc;

  /// dc是渠道 distinctCode
  String? dc;

  static CutInfo? fromMap(Map<String, dynamic> map) {
    CutInfo cutInfo = CutInfo();
    cutInfo.pc = map['pc'];
    cutInfo.dc = map['dc'];
    return cutInfo;
  }

  Map toJson() => pc == null ? {"dc": dc} :  {"pc": pc,};
}
