import 'package:comics_app/common/utils/base_task.dart';
import 'package:comics_app/common/utils/files_upload/single_video_upload_helper.dart';
import 'package:comics_app/common/utils/files_upload/video_upload_result_model.dart';
import 'package:logger/logger.dart';

/// 单视频整段上传任务（**不分片**）。
///
/// 与历史的 [VideoUploadTask]（分片协议）并存：新业务想用整段上传时挂这个
/// task；旧调用点不动，等机会再统一迁移。
class SingleVideoUploadTask extends BaseTask<VideoUploadResultModel>
    with SingleVideoUploadHelper {
  SingleVideoUploadTask(
    this.videoPath, {
    ProgressChanged? updateListener,
    String? taskId,
  }) : super(updateListener: updateListener, taskId: taskId);

  @override
  String get tag => 'SingleVideoUploadTask';

  /// 本地视频绝对路径。
  final String videoPath;

  @override
  void sonDoExecute() async {
    Logger().i(tag, 'begin Upload doInBackgroud');
    running = true;
    try {
      final model = await uploadFile(videoPath);
      if (model == null) {
        // [uploadFile] 内部已经 `onError` + `onUpdate(0)`，这里只补一次失败兜底
        // 让 [BaseTask] 把状态机推进到 failed，避免上层 `await` 永远拿不到回包。
        onError('upload failed: model is null');
      } else {
        onDone(model);
      }
    } catch (e) {
      Logger().e(tag, 'sonDoExecute()...error:$e');
      onError(e);
    }
    running = false;
    Logger().i(tag, 'end Upload doInBackgroud');
  }
}
