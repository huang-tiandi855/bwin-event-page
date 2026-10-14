
import '../../store/user.dart';
import '../../values/address.dart';
import 'media_status.dart';
import 'package:path/path.dart' as path;

class ContentModel {
  String? audioUrl;
  int? countBrowse;
  int? countCollect;
  int? countComment;
  int? countDisLike;
  int? countLike;
  int? countPurchases;
  String? createdAt;
  int? episodeNumber;
  int? height;
  String? id;
  int? listenPermission;
  String? md5;
  String? mediaId;
  int? mediaSize;
  MediaStatus? mediaStatus;
  String? name;
  int? playTime;
  int? price;
  double? ratio;
  String? text;
  String? updateTime;
  List<String>? urlSet;
  String? videoUrl;
  int? weight;
  bool? isActive;

  bool? isPlayed;
  String? localPath;
  String? isLoaderRunning;
  String? loadProgress;

  ContentModel(
      {this.audioUrl,
      this.countBrowse,
      this.countCollect,
      this.countComment,
      this.countDisLike,
      this.countLike,
      this.countPurchases,
      this.createdAt,
      this.episodeNumber,
      this.height,
      this.id,
      this.listenPermission,
      this.md5,
      this.mediaId,
      this.mediaSize,
      this.mediaStatus,
      this.name,
      this.playTime,
      this.price,
      this.ratio,
      this.text,
      this.updateTime,
      this.urlSet,
      this.videoUrl,
      this.weight,
      this.isActive});

  ContentModel.fromJson(Map<String, dynamic> json) {
    audioUrl = json["audioUrl"];
    countBrowse = json["countBrowse"];
    countCollect = json["countCollect"];
    countComment = json["countComment"];
    countDisLike = json["countDisLike"];
    countLike = json["countLike"];
    countPurchases = json["countPurchases"];
    createdAt = json["createdAt"];
    episodeNumber = json["episodeNumber"];
    height = json["height"];
    id = json["id"];
    listenPermission = json["listenPermission"];
    md5 = json["md5"];
    mediaId = json["mediaId"] ?? json["mediaID"];
    mediaSize = json["mediaSize"];
    mediaStatus = json["mediaStatus"] == null
        ? null
        : MediaStatus.fromJson(json["mediaStatus"]);
    name = json["name"];
    playTime = json["playTime"];
    price = json["price"];
    ratio = double.tryParse((json["ratio"] ?? 1).toString());
    text = json["text"];
    updateTime = json["updateTime"];
    urlSet = json["urlSet"] == null
        ? []
        : List<String>.from(json["urlSet"]!.map((x) => x));
    videoUrl = json["videoUrl"];
    weight = json["weight"];
    isActive = json["isActive"];
  }

  bool get hasPaid => mediaStatus?.hasPaid ?? false;

  Map<String, dynamic> toJson() => {
        "audioUrl": audioUrl,
        "countBrowse": countBrowse,
        "countCollect": countCollect,
        "countComment": countComment,
        "countDisLike": countDisLike,
        "countLike": countLike,
        "countPurchases": countPurchases,
        "createdAt": createdAt,
        "episodeNumber": episodeNumber,
        "height": height,
        "id": id,
        "listenPermission": listenPermission,
        "md5": md5,
        "mediaId": mediaId,
        "mediaSize": mediaSize,
        "mediaStatus": mediaStatus?.toJson(),
        "name": name,
        "playTime": playTime,
        "price": price,
        "ratio": ratio,
        "text": text,
        "updateTime": updateTime,
        "urlSet":
            urlSet == null ? [] : List<dynamic>.from(urlSet!.map((x) => x)),
        "videoUrl": videoUrl,
        "weight": weight,
        "localPath": localPath
      };

  String get realVideoUrl {
    final String? v = videoUrl;
    if (v == null || v.isEmpty) return '';
    return Address.buildH5VideoUrl(
      v,
      token: UserStore.to.getToken(),
      withCdn: false,
    );
  }

  String get getRealAudioUrl {
    if (audioUrl == null || audioUrl!.isEmpty) {
      return "";
    }
    if (!audioUrl!.startsWith("http") && !audioUrl!.startsWith("https")) {
      return path.join(Address.audioUrl ?? '', audioUrl);
    }
    return audioUrl!;
  }
}
