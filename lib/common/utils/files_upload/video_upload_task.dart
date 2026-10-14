import 'package:comics_app/common/utils/base_task.dart';
import 'package:logger/logger.dart';

import 'single_video_upload_helper.dart';
import 'video_upload_result_model.dart';

/// 视频分片上传任务
/// 其实也可以通过 组合的方式将不同的helper注入到BaseTask中
class VideoUploadTask extends BaseTask<VideoUploadResultModel>
    with SingleVideoUploadHelper {
  @override
  String get tag => "VideoUploadTask";
  String videoPath;
  VideoUploadTask( this.videoPath, {ProgressChanged? updateListener, String? taskId})
      : super(updateListener: updateListener, taskId: taskId);
  @override
  void sonDoExecute() async {
    
    Logger().d(tag, 'begin Upload doInBackgroud');
    running = true;

    try {
      ///上传视频
      final model = await uploadFile(videoPath);
      if (model == null) {
        doFailed();
        return;
      } else {
        onDone(model);
        running = false;
      }

      // ImageUploadResultModel? imgModel;
      // if (state.videoCover == "") {
      //   final thumbnailFile = await VideoCompress.getFileThumbnail(
      //     state.videoPath.toString(),
      //     quality: 100,
      //     position: -1,
      //   );
      //   imgModel = await uploadImage(thumbnailFile.path);
      // } else if (state.picList.isNotEmpty) {
      //   imgModel = await uploadImage(state.picList[0]);
      // }

      // state.videoRemoteCoverPath = imgModel?.coverImg;
      // if (TextUtil.isEmpty(state.videoRemoteCoverPath)) {
      //   doFailed();
      //   return;
      // }

      // final bool result = await uploadVideoApi();
      // if (result) {
      //   doSuc();
      // } else {
      //   doFailed();
      // }
    } catch (e) {
      Logger().e(tag, 'sonDoExecute()...error:$e');
      doFailed();
    }
    Logger().d(tag, 'end Upload doInBackgroud');
  }

  void doFailed() {
    // 把-1 更新出去；
    //onUpdate(1.0, msg: "上传失败");
    onError("上传失败");
    onUpdate(0, msg: '上传失败');
    running = false;
  }

  // void doSuc() {
  //   //onUpdate(1.0, msg: "上传成功");
  //   onDone(true);
  //   running = false;
  // }
}
