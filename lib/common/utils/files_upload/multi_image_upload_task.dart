import '../base_task.dart';
import 'multi_image_model.dart';
import 'package:logger/logger.dart';

import 'multi_image_upload_helper.dart';

/// 多图片上传任务
/// 其实也可以通过 组合的方式将不同的helper注入到BaseTask中
class MultiImageUploadTask extends BaseTask<MultiImageModel> with MultiImageUploadHelper {
  @override
  String get tag => "MultiImageUploadTask";
  final List<String> localPaths;
  final bool isUploadChatImages;
  MultiImageUploadTask(this.localPaths, { this.isUploadChatImages = false, ProgressChanged? updateListener})
      : super(updateListener: updateListener);
  @override
  void sonDoExecute() async {
    Logger().i(tag, 'begin Upload doInBackgroud');
    running = true;
    try {
      var model = await uploadFile(localPaths, isUploadChatImages);
      if (null != model) {
        onDone(model);
      } else {
        onError('upload failed: model is null');
      }
    } catch (e) {
      Logger().e(tag, 'sonDoExecute()...error:$e');
      onError(e);
    }
    running = false;
    Logger().i(tag, 'end Upload doInBackgroud');
  }
}
