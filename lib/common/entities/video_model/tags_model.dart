import 'package:comics_app/common/entities/module_detail_model/all_tag_model.dart';

class TagsModel {
  String? coverImg;
  String? description;
  bool? hasCollected;
  bool? hasFollow;
  String? id;
  String? name;
  int? playCount;
  int? type;
  AllTagModel get convetAllTag {
    AllTagModel model = AllTagModel.fromJson(toJson());
    model.type = 1;
    return model;
  }

  AllTagModel get convertCartoonAllTag {
    AllTagModel model = AllTagModel.fromJson(toJson());
    model.type = 4;
    return model;
  }

  static TagsModel fromJson(Map<String, dynamic>? map) {
    map ??= {};
    TagsModel tagsBean = TagsModel();
    tagsBean.coverImg = map['coverImg'];
    tagsBean.description = map['description'];
    tagsBean.hasCollected = map['hasCollected'];
    tagsBean.hasFollow = map['hasFollow'];
    tagsBean.id = map['id'];
    tagsBean.name = map['name'];
    tagsBean.type = map['type'];
    tagsBean.playCount = map['playCount'];
    return tagsBean;
  }

  Map<String, dynamic> toJson() => {
        "coverImg": coverImg,
        "description": description,
        "hasCollected": hasCollected,
        "hasFollow": hasFollow,
        "id": id,
        "name": name,
        "playCount": playCount,
      };
}
