// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:comics_app/common/entities/video_model/video_model.dart';

import 'all_media_info_model.dart';
import 'all_module_model.dart';
import 'all_section_model.dart';

class ModuleDetailModel {
  List<AllMediaInfoModel> allMediaInfo;
  List<AllModuleModel> allModule;
  List<AllSectionModel> allSection;
  List<VideoModel> allVideoInfo;
  bool? hasNext;

  ModuleDetailModel({
    this.allMediaInfo = const [],
    this.allModule = const [],
    this.allSection = const [],
    this.allVideoInfo = const [],
    this.hasNext,
  });


  @override
  String toString() {
    return 'ModuleDetailModel{allMediaInfo: $allMediaInfo, allModule: $allModule, allSection: $allSection, allVideoInfo: $allVideoInfo, hasNext: $hasNext}';
  }

  factory ModuleDetailModel.fromJson(Map<String, Object?> json) {
    return ModuleDetailModel(
      allMediaInfo: (json['allMediaInfo'] as List<dynamic>?)
              ?.map((e) => AllMediaInfoModel.fromJson(e as Map<String, Object?>))
              .toList() ??
          [],
      allModule: (json['allModule'] as List<dynamic>?)
              ?.map((e) => AllModuleModel.fromJson(e as Map<String, Object?>))
              .toList() ??
          [],
      allSection: (json['allSection'] as List<dynamic>?)
              ?.map((e) => AllSectionModel.fromJson(e as Map<String, Object?>))
              .toList() ??
          [],
      allVideoInfo: (json['allVideoInfo'] as List<dynamic>?)
              ?.map((e) => VideoModel.fromJson(e as Map<String, Object?>))
              .toList() ??
          [],
      hasNext: json['hasNext'] as bool?,
    );
  }

  Map<String, Object?> toJson() => {
        'allMediaInfo': allMediaInfo.map((e) => e.toJson()).toList(),
        'allModule': allModule.map((e) => e.toJson()).toList(),
        'allSection': allSection.map((e) => e.toJson()).toList(),
        'allVideoInfo': allVideoInfo.map((e) => e.toJson()).toList(),
        'hasNext': hasNext,
      };

  ModuleDetailModel copyWith({
    List<AllMediaInfoModel>? allMediaInfo,
    List<AllModuleModel>? allModule,
    List<AllSectionModel>? allSection,
    List<VideoModel>? allVideoInfo,
    bool? hasNext,
  }) {
    return ModuleDetailModel(
      allMediaInfo: allMediaInfo ?? this.allMediaInfo,
      allModule: allModule ?? this.allModule,
      allSection: allSection ?? this.allSection,
      allVideoInfo: allVideoInfo ?? this.allVideoInfo,
      hasNext: hasNext ?? this.hasNext,
    );
  }

  ModuleDetailModel applyWith(ModuleDetailModel data) {
    return copyWith(
      allMediaInfo: allMediaInfo..addAll(data.allMediaInfo),
      allModule: allModule..addAll(data.allModule),
      allSection: allSection..addAll(data.allSection),
      allVideoInfo: allVideoInfo..addAll(data.allVideoInfo),
      hasNext: data.hasNext,
    );
  }
}
