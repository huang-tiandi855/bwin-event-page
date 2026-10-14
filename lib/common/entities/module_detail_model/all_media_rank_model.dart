import 'all_media_info_model.dart';

class AllMediaRankModel {
  AllMediaRankModel({
      this.name, 
      this.cover, 
      this.background, 
      this.description, 
      this.type, 
      this.sortCode, this.allMediaInfo = const []});

  AllMediaRankModel.fromJson(dynamic json) {
    name = json['name'];
    cover = json['cover'];
    background = json['background'];
    description = json['description'];
    type = json['type'];
    sortCode = json['sortCode'];
    allMediaInfo = (json['allMediaInfo'] as List<dynamic>?)?.map((e) => AllMediaInfoModel.fromJson(e)).toList() ?? [];

  }
  String? name;
  String? cover;
  String? background;
  String? description;
  num? type;
  num? sortCode;
  List<AllMediaInfoModel>? allMediaInfo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['cover'] = cover;
    map['background'] = background;
    map['description'] = description;
    map['type'] = type;
    map['sortCode'] = sortCode;
    return map;
  }

}