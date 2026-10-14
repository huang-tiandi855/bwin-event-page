import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_pickers/image_pickers.dart';

import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'custom_picture_management.dart';

///上传视频控件
class VideoUploadMangeWidget extends StatefulWidget {
  final List<String>? picList;
  final double? width;
  final ImageTyp? imageType;
  final double? height;

  ///删除item
  final ValueChanged<int>? deleteItemCallback;
  final VoidCallback? deleteCoverCallback;

  ///添加图片
  final VoidCallback? addItemCallback;

  ///选择封面
  final VoidCallback? onSelectCover;

  final UploadType? uploadType;
  final String? videoPath;
  final String? videoCover;

  const VideoUploadMangeWidget({
    Key? key,
    this.picList,
    this.addItemCallback,
    this.width,
    this.height,
    this.deleteItemCallback,
    this.deleteCoverCallback,
    this.onSelectCover,
    this.imageType = ImageTyp.FILE,
    this.uploadType = UploadType.UPLOAD_IMG,
    this.videoPath,
    this.videoCover,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoUploadState();
}

class _VideoUploadState extends State<VideoUploadMangeWidget> {
  @override
  Widget build(BuildContext context) {
    var picWidgetList = <Widget>[];

    ///添加封面控件
    picWidgetList.add(widget.videoCover == null || widget.videoCover == "" ? _buildVideoCoverUI() : _buildVideoCover());

    ///显示添加视频图标
    picWidgetList.add(widget.videoPath == null || widget.videoPath == "" ? _buildAddVideoUI() : _buildVideoUI());

    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 4.w),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  "添加封面",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18.w),
                ),
                SizedBox(width: 73.w),
                Text(
                  "添加视频",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18.w),
                ),
              ],
            )),
        SizedBox(height: 16.w),
        GridView(
          //padding: EdgeInsets.all(Dimens.pt11),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, //横轴三个子widget
            childAspectRatio: 1, //宽高比为1时，子widget
            mainAxisSpacing: 12.w,
            crossAxisSpacing: 12.w,
          ),
          children: picWidgetList,
        ),
      ],
    );
  }

  ///真实封面UI
  GestureDetector _buildVideoCover() => GestureDetector(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                //设置四周圆角 角度
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                //设置四周边框
                border: Border.all(width: 0.6, color: const Color.fromRGBO(159, 166, 180, 1)),
              ),
              child: _getImageType(widget.videoCover.toString()),
            ),
            // 删除
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                child: Image.asset(
                  "assets/images/png/publish_select_close.png",
                  width: 14.w,
                  height: 14.w,
                ),
                onTap: () => widget.deleteCoverCallback?.call(),
              ),
            ),
          ],
        ),
        onTap: () {
          if (ImageTyp.FILE == widget.imageType) {
            ImagePickers.previewImages([widget.videoCover], 0);
          }
        },
      );

  ///真实视频UI
  GestureDetector _buildVideoUI() => GestureDetector(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                //设置四周圆角 角度
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                //设置四周边框
                border: Border.all(width: 0.6, color: const Color.fromRGBO(159, 166, 180, 1)),
              ),
              child: _getImageType(widget.picList!.isNotEmpty ? widget.picList![0].toString() : widget.videoCover),
            ),
            //视频播放按钮
            SvgPicture.asset("assets/images/svg/ic_upload_play.svg", width: 24.w, height: 24.w),
            // 删除
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                child: Image.asset(
                  "assets/images/png/publish_select_close.png",
                  width: 14.w,
                  height: 14.w,
                ),
                onTap: () => widget.deleteItemCallback?.call(0),
              ),
            ),
          ],
        ),
        onTap: () {
          ImagePickers.previewVideo(widget.videoPath.toString());
        },
      );

  Widget _getImageType(String? videoCover) {
    if (widget.imageType == ImageTyp.ASSETS) {
      return Image.asset(
        videoCover.toString(),
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
      );
    } else if (widget.imageType == ImageTyp.FILE) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.file(
          File(videoCover.toString()),
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return CustomImage(
        url: videoCover.toString(),
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
      );
    }
  }

  ///创建视频封面UI
  GestureDetector _buildVideoCoverUI() => GestureDetector(
        onTap: widget.onSelectCover,
        child: Container(
          width: 83.w,
          height: 83.w,
          padding: const EdgeInsets.all(40),
          decoration: ShapeDecoration(
            color: const Color.fromRGBO(255, 255, 255, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                width: 1,
                color: Color.fromRGBO(44, 48, 58, 1),
                style: BorderStyle.solid,
              ),
            ),
          ),
          child: Image.asset(
            "assets/images/png/picture_plus.png",
            width: 16,
            height: 16,
            color: const Color.fromRGBO(93, 100, 114, 1),
          ),
        ),
      );

  ///添加视频UI
  GestureDetector _buildAddVideoUI() => GestureDetector(
        onTap: widget.addItemCallback,
        child: Container(
          width: 83.w,
          height: 83.w,
          padding: const EdgeInsets.all(40),
          decoration: ShapeDecoration(
            color: const Color.fromRGBO(255, 255, 255, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                width: 1,
                color: Color.fromRGBO(44, 48, 58, 1),
                style: BorderStyle.solid,
              ),
            ),
          ),
          child: SvgPicture.asset(
            "assets/images/svg/ic_upload_play.svg",
            width: 16,
            height: 16,
            color: const Color.fromRGBO(93, 100, 114, 1),
          ),
        ),
      );
}
