// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:typed_data';

import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';

enum ImageTyp { FILE, ASSETS, NET }

//帖子类型， 0 视频，1，图文，2，图片
enum UploadType { UPLOAD_VIDEO, UPLOAD_IMG_AND_TEXT, UPLOAD_IMG }

class PictureMangeWidget extends StatelessWidget {
  final List<String> picList;
  final List<Uint8List> picWebList;
  final double width;
  final ImageTyp imageType;
  final double height;

  ///删除item
  final ValueChanged<int> deleteItemCallback;

  ///添加图片
  final VoidCallback addItemCallback;

  ///选择封面
  // final VoidCallback onSelectCover;

  final UploadType uploadType;
  final String videoPath;

  const PictureMangeWidget(
      {required Key key,
      required this.picList,
      required this.picWebList,
      required this.addItemCallback,
      required this.width,
      required this.height,
      required this.deleteItemCallback,
      // required this.onSelectCover,
      this.imageType = ImageTyp.FILE,
      required this.uploadType,
      required this.videoPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var picWidgetList = <Widget>[];
    for (var index = 0; index < picList.length; index++) {
      var curWidget = GestureDetector(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            /*ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: _getImageType(index)),*/
            Container(
              width: width,
              height: height,
              decoration: const BoxDecoration(
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(10)),
                //设置四周边框
                // border: new Border.all(width: 0.6, color: Color.fromRGBO(159, 166, 180, 1)),
              ),
              child: _getImageType(index),
            ),
            //视频播放按钮
            Visibility(
              visible: uploadType == UploadType.UPLOAD_VIDEO,
              child: GestureDetector(
                child: AssetsGen.images.circle.postPaly
                    .image(width: 34.w, height: 34.w),
                onTap: () async {
                  ImagePickers.previewVideo(videoPath);
                },
              ),
            ),
            // 删除
            Positioned(
                top: 4.w,
                right: 5.w,
                child: GestureDetector(
                  child: AssetsGen.images.circle.publishClose
                      .image(width: 20.w, height: 20.w),
                  onTap: () => deleteItemCallback.call(index),
                )),
            // 上传封面
            // Positioned(
            //   bottom: 0,
            //   child: Visibility(
            //     visible: uploadType == UploadType.UPLOAD_VIDEO,
            //     child: GestureDetector(
            //       onTap: onSelectCover,
            //       child: ClipRRect(
            //         borderRadius: const BorderRadius.only(
            //             bottomLeft: Radius.circular(6),
            //             bottomRight: Radius.circular(6)),
            //         child: Container(
            //           decoration: const BoxDecoration(
            //               borderRadius: BorderRadius.only(
            //                   bottomLeft: Radius.circular(6),
            //                   bottomRight: Radius.circular(6)),
            //               gradient: LinearGradient(
            //                   begin: Alignment.topCenter,
            //                   end: Alignment.bottomCenter,
            //                   colors: [
            //                     Color.fromRGBO(0, 0, 0, 0.6),
            //                     Color.fromRGBO(0, 0, 0, 0.6),
            //                     Color.fromRGBO(0, 0, 0, 1),
            //                   ])),
            //           alignment: Alignment.center,
            //           width: ScreenUtil().screenWidth,
            //           height: 50.w,
            //           child: Text("上传封面",
            //               style:
            //                   TextStyle(color: Colors.white, fontSize: 14.sp)),
            //         ),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
        onTap: () {
          if (ImageTyp.FILE == imageType) {
            ImagePickers.previewImages(picList, index);
          }
        },
      );
      picWidgetList.add(curWidget);
    }

    //显示添加图标
    if ((uploadType == UploadType.UPLOAD_IMG) ||
        (picWidgetList.isEmpty && uploadType == UploadType.UPLOAD_VIDEO)) {
      var addWidget = GestureDetector(
        onTap: addItemCallback,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            dashPattern: const [4, 4],
            strokeWidth: 1,
            color: const Color(0x54F6D073),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AssetsGen.images.circle.publishAdd.image(
                    width: 26.w,
                    height: 26.w,
                  ),
                  getHeight(10.w),
                  Text(
                    uploadType == UploadType.UPLOAD_IMG ? "上传图片" : "上传视频",
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      picWidgetList.add(addWidget);
    } else if (picWidgetList.length > 9) {
      // picList.removeRange(9, picList.length);
      // picWidgetList.removeRange(9, picWidgetList.length);
    }
    return Column(
      crossAxisAlignment: uploadType != UploadType.UPLOAD_VIDEO
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  uploadType != UploadType.UPLOAD_VIDEO ? "添加图集" : "添加视频",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 16.w),
                Text(
                  uploadType != UploadType.UPLOAD_VIDEO
                      ? "最大每张1M以内"
                      : "最大300M以内",
                  style: TextStyle(color: Colors.white.withOpacity(.5)),
                ),
              ],
            )),
        SizedBox(
          height: 10.w,
        ),
        uploadType != UploadType.UPLOAD_VIDEO
            ? GridView(
                //padding: EdgeInsets.all(Dimens.pt11),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, //横轴三个子widget
                  childAspectRatio: 1, //宽高比为1时，子widget
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                children: picWidgetList,
              )
            : Container(
                // constraints: BoxConstraints(maxWidth: 165.w,maxHeight: 220.w,minHeight: 110.w,minWidth: 165.w),
                width: 165.w,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: picWidgetList,
                ),
              ),
      ],
    );
  }

  Widget _getImageType(int index) {
    if (imageType == ImageTyp.ASSETS) {
      return Image.asset(
        picList[index],
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    } else if (imageType == ImageTyp.FILE) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: GetPlatform.isWeb
              ? Image.memory(
                  picWebList[index],
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(picList[index]),
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                ));
    } else {
      return CustomImage(
        url: picList[index],
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
  }
}
