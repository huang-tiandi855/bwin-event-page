/// code : 200
/// data : {"coverImg":"sp/ov/2f/rv/9u/1ece25ec44824164b4fc4d0a106f8146.png"}
/// msg : "success"
/// tip : ""

class ImageUploadResultModel {
  String? coverImg;

  static ImageUploadResultModel? fromMap(Map<String, dynamic> map) {
    ImageUploadResultModel dataBean = ImageUploadResultModel();
    dataBean.coverImg = map['coverImg'];
    return dataBean;
  }

  Map toJson() => {
    "coverImg": coverImg,
  };
}

