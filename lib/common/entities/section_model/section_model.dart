import 'package:comics_app/common/entities/module_detail_model/media_status.dart';

class SectionModel {
  String? id;
  String? name;
  String? cover;
  int? count;
  int? type;
  int? showType;
  int? likeCount;
  int? commentCount;
  int? userId;
  String? userName;
  String? portrait;
  bool? isFree;
  MediaStatus? mediaStatus;

  SectionModel({
    this.id,
    this.name,
    this.cover,
    this.count,
    this.type,
    this.showType,
    this.likeCount,
    this.commentCount,
    this.userId,
    this.userName,
    this.portrait,
    this.isFree,
    this.mediaStatus,
  });

  @override
  String toString() {
    return 'SectionModel(id: $id, name: $name, cover: $cover, count: $count, type: $type, showType: $showType, likeCount: $likeCount, commentCount: $commentCount, userId: $userId, userName: $userName, portrait: $portrait, isFree: $isFree, mediaStatus: $mediaStatus)';
  }

  factory SectionModel.fromJson(Map<String, Object?> json) => SectionModel(
        id: json['id'] as String?,
        name: json['name'] as String?,
        cover: json['cover'] as String?,
        count: json['count'] as int?,
        type: json['type'] as int?,
        showType: json['showType'] as int?,
        likeCount: json['likeCount'] as int?,
        commentCount: json['commentCount'] as int?,
        userId: json['userId'] as int?,
        userName: json['userName'] as String?,
        portrait: json['portrait'] as String?,
        isFree: json['isFree'] as bool?,
        mediaStatus:
            json['mediaStatus'] == null ? null : MediaStatus.fromJson(json['mediaStatus']! as Map<String, Object?>),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'cover': cover,
        'count': count,
        'type': type,
        'showType': showType,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'userId': userId,
        'userName': userName,
        'portrait': portrait,
        'isFree': isFree,
        'mediaStatus': mediaStatus?.toJson(),
      };

  SectionModel copyWith({
    String? id,
    String? name,
    String? cover,
    int? count,
    int? type,
    int? showType,
    int? likeCount,
    int? commentCount,
    int? userId,
    String? userName,
    String? portrait,
    bool? isFree,
    MediaStatus? mediaStatus,
  }) {
    return SectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cover: cover ?? this.cover,
      count: count ?? this.count,
      type: type ?? this.type,
      showType: showType ?? this.showType,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      portrait: portrait ?? this.portrait,
      isFree: isFree ?? this.isFree,
      mediaStatus: mediaStatus ?? this.mediaStatus,
    );
  }
}
