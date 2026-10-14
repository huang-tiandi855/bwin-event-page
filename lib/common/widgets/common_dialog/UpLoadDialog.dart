
import 'dart:async';

import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/utils/task_manager.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/common/utils/files_upload/upload_video_model.dart';
import 'package:comics_app/pages/circle/publish/publish_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:comics_app/common/utils/files_upload/video_upload_task.dart';

class UpLoadDialog extends StatefulWidget {
  String taskid;

  UploadVideoModel? uploadModel;

  UpLoadDialog(this.taskid, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UpLoadDialogDialogState();
}

class _UpLoadDialogDialogState extends State<UpLoadDialog> {
  bool isPublish = false;
  final StreamController<double> _percentStreamController =
      StreamController.broadcast();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uploadVideo();
  }

  void uploadVideo() {
    taskManager.addTaskToQueue(VideoUploadTask(
      widget.uploadModel?.videoLocalPath ?? "",
      taskId: widget.taskid,
      updateListener: (values, {isSuccess, msg}) {
        if (msg == "上传失败") {
          Get.back();
        }

        if (mounted) {
          //debugPrint("isSuccess----------${isSuccess}");
          //debugPrint("msg----------${msg}");
          //debugPrint("上传进度百分比----------${values}");

          if (mounted) {
            _percentStreamController.add(values);
          }

          if (msg == "上传完成") {
            //showToast(msg: "上传完成");
            Get.back();
            PublishLogic logic = Get.find<PublishLogic>();
            logic.jumpMakeCenter();
            logic.clearUI();
          }
        }
      },
    ));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _percentStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      //height: 1.sh + 30.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: Colors.black.withOpacity(0.4),
      ),
      child: Row(
        children: [
          getWidth(37),
          _buildContent(context),
          getWidth(22),
          Text(
            "正在上传中...",
            style: TextStyle(
                color: const Color.fromRGBO(188, 188, 188, 1), fontSize: 14.w),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return PopScope(
        canPop: false,
        child: SizedBox(
          child: StreamBuilder<double>(
              initialData: 0.0,
              stream: _percentStreamController.stream,
              builder: (context, snapshot) {
                //进度条有弧度
                return CircularPercentIndicator(
                  radius: 20.0,
                  lineWidth: 3.0,
                  animation: true,
                  animateFromLastPercent: true,
                  percent: snapshot.data!,
                  center: Text(
                    "${(snapshot.data! * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.white),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: AppColor.bluishPurple,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  onAnimationEnd: () {
                    /*if (snapshot.data! == 100) {
                          setState(() {
                           // widget.isUploadSuccess = true;

                            //Get.back();

                          });
                        }*/
                  },
                );
              }),
        ));
  }

}
