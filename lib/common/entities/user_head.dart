class SwitchAvatarData {
  int? id;
  String? url;

  static List<SwitchAvatarData?>? fromJsonList(List<dynamic>? list) {
    if (list == null) return null;
    return list.map((e) => SwitchAvatarData.fromJson(e)).toList();
  }

  static SwitchAvatarData? fromJson(Map<String, dynamic>? map) {
    if (map == null) return null;
    SwitchAvatarData switchAvatarData = SwitchAvatarData();
    switchAvatarData.url = map["url"];
    switchAvatarData.id = map["id"];
    return switchAvatarData;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['url'] = url;
    map['id'] = id;
    return map;
  }
}
