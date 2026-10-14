class Adv {
  Adv({
      this.id, 
      this.name, 
      this.image, 
      this.url, 
      this.location,});

  Adv.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    url = json['url'];
    location = json['location'];
  }
  String? id;
  String? name;
  String? image;
  String? url;
  String? location;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['image'] = image;
    map['url'] = url;
    map['location'] = location;
    return map;
  }

}