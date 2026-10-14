/// code : 200
/// msg : "success"
/// tip : ""

class VideoUploadResultModel {
  String? id;
  String? videoUri;
  String? fileName;

  static VideoUploadResultModel? fromMap(Map<String, dynamic> map) {
    VideoUploadResultModel dataBean = VideoUploadResultModel();
    dataBean.id = map['id'];
    dataBean.videoUri = map['serverPath'];
    dataBean.fileName = map['fileName'];
    return dataBean;
  }

  Map toJson() => {
        "id": id,
        "serverPath": videoUri,
        "fileName": fileName,
      };
}
