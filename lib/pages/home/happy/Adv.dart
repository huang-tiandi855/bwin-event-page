class Adv {
  Adv({
      this.id, 
      this.name, 
      this.image, 
      this.url, 
      this.location,this.moduleType,});

  Adv.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    url = json['url'];
    location = json['location'];

    moduleType = json['moduleType'];
  }
  String? id;
  String? name;
  String? image;
  String? url;
  String? location;
  int? moduleType;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['url'] = url;
    map['location'] = location;

    map['moduleType'] = moduleType;

    return map;
  }

}