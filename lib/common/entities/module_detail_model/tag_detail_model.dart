class TagDetailModel {
  String? id;
  String? name;

  TagDetailModel({
    this.id,
    this.name,
  });

  TagDetailModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
