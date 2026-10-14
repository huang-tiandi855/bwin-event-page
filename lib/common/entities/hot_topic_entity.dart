import 'dart:convert';
import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/hot_topic_entity.g.dart';

@JsonSerializable()
class HotTopicEntity {

	List<HotTopicList>? list;
	bool? hasNext;
  
  HotTopicEntity();

  factory HotTopicEntity.fromJson(Map<String, dynamic> json) => $HotTopicEntityFromJson(json);

  Map<String, dynamic> toJson() => $HotTopicEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class HotTopicList {

	String? id;
	String? name;
	String? tagDesc;
	String? coverImg;
	int? playCount;
	int? collCount;
	bool? hasCollected;
  bool? hasSelected;
  
  HotTopicList();

  factory HotTopicList.fromJson(Map<String, dynamic> json) => $HotTopicListFromJson(json);

  Map<String, dynamic> toJson() => $HotTopicListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}