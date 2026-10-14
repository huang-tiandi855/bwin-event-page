class Se {
  Se({
      this.id, 
      this.name, 
      this.cover, 
      this.count, 
      this.type, 
      this.likeCount, 
      this.commentCount,});

  Se.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    cover = json['cover'];
    count = json['count'];
    type = json['type'];
    likeCount = json['likeCount'];
    commentCount = json['commentCount'];
  }
  String? id;
  String? name;
  String? cover;
  num? count;
  num? type;
  num? likeCount;
  num? commentCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['cover'] = cover;
    map['count'] = count;
    map['type'] = type;
    map['likeCount'] = likeCount;
    map['commentCount'] = commentCount;
    return map;
  }

}