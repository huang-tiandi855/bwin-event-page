import 'all_tag_model.dart';

class AllModuleModel {
  List<AllModuleAllSectionModel>? allSection;
  String? id;
  String? name;


  @override
  String toString() {
    return 'AllModuleModel{allSection: $allSection, id: $id, name: $name}';
  }

  AllModuleModel({
    this.allSection,
    this.id,
    this.name,
  });

  AllModuleModel.fromJson(Map<String, dynamic> json) {
    allSection = json['allSection'] == null
        ? []
        : List<AllModuleAllSectionModel>.from(json['allSection']!
            .map((x) => AllModuleAllSectionModel.fromJson(x)));
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() => {
        'allSection': allSection == null
            ? []
            : List<dynamic>.from(allSection!.map((x) => x.toJson())),
        'id': id,
        'name': name,
      };
}

class AllModuleAllSectionModel {
  List<AllTagModel> allTags;
  String? id;
  String? mid;
  String? name;

  AllModuleAllSectionModel({
    this.allTags = const [],
    this.id,
    this.mid,
    this.name,
  });

  factory AllModuleAllSectionModel.fromJson(Map<String, dynamic> json) {
    return AllModuleAllSectionModel(
      allTags: (json['allTags'] as List<dynamic>?)
              ?.map((e) => AllTagModel.fromJson(e))
              .toList() ??
          [],
      id: json['id'],
      mid: json['mid'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'allTags': allTags.map((x) => x.toJson()),
        'id': id,
        'mid': mid,
        'name': name,
      };
}
