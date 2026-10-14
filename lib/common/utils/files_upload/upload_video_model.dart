
///视频上传model
class UploadVideoModel {
  ///视频本地地址
  String? videoLocalPath;

  ///封面本地地址
  List<String> localPicList = [];

  List<String> selectedTagIdList = [];

  int? coins;

  int freeTime = 0;
  int maxVideoTime = 0;

  String? actor;

  String? city;

  String? via;

  String? title;

  String? videoRemotePath;

  String? videoFileId;

  String? coverRemotePath;

  String? taskID;
}
