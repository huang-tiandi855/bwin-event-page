
class OfficeItemData {
  String? officialName;
  String? officialDesc;
  String? officialImg;
  String? officialUrl;
  String? officialType;

  static List<OfficeItemData> toList(List<dynamic>? mapList) {
    List<OfficeItemData> list = [];
    if (mapList == null) return list;
    Iterator iterator = mapList.iterator;
    while (iterator.moveNext()) {
      Map<String, dynamic> current = iterator.current;
      OfficeItemData? item = fromMap(current);
      if (item != null) list.add(item);
    }
    return list;
  }

  static OfficeItemData? fromMap(Map<String, dynamic>? json) {
    if (json == null) return null;
    OfficeItemData officeItemData = OfficeItemData();
    officeItemData.officialName = json['officialName'];
    officeItemData.officialDesc = json['officialDesc'];
    officeItemData.officialImg = json['officialImg'];
    officeItemData.officialType = json['officialType'];
    officeItemData.officialUrl = json['officialUrl'];
    return officeItemData;
  }
}
