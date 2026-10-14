import '../module_detail_model/all_media_info_model.dart';

class RankModel {
  List<RankInfo>? rankList;
  List<AllMediaInfoModel>? mediaList;
  bool? hasNext;

  RankModel.fromJson(dynamic json) {
    if (json['rankInfo'] != null) {
      rankList = [];
      json['rankInfo'].forEach((v) {
        rankList?.add(RankInfo.fromJson(v));
      });
    }
    if (json['mediaList'] != null) {
      mediaList = [];
      json['mediaList'].forEach((v) {
        mediaList?.add(AllMediaInfoModel.fromJson(v));
      });
    }
    hasNext = json['hasNext'];
  }
}

class RankInfo{
  String? name;
  int? kind;
  int? sort;
  RankInfo.fromJson(dynamic json) {
    kind = json['kind'];
    name = json['name'];
    sort = json['sort'];
  }
}