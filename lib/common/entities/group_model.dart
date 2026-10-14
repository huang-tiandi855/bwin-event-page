class GroupModel {
  String? name;
  String? iconUrl;
  String? jumpUrl;

  GroupModel(
      {required this.name, required this.iconUrl, required this.jumpUrl});

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      name: json['name'],
      iconUrl: json['iconUrl'],
      jumpUrl: json['jumpUrl'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconUrl': iconUrl,
      'jumpUrl': jumpUrl,
    };
  }
}
