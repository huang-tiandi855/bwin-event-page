// ignore_for_file: use_build_context_synchronously

import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import '../../../pages/image/network/custom_image_network.dart';
import '../../entities/user_info_model_entity.dart';
import '../../style/color.dart';
import '../../utils/toast_util.dart';

enum ShareType {
  long,
  short,
}

///分享二维码对话框
class ShareVideoView extends StatefulWidget {
  static Future show(BuildContext context, String? cover,
      {ShareType shareType = ShareType.long}) {
    return showDialog(
      context: context,
      builder: (context) {
        return ShareVideoView(
          cover: cover,
          shareType: shareType,
        );
      },
    );
  }

  final String? cover;
  final ShareType shareType;

  const ShareVideoView(
      {super.key, this.cover, this.shareType = ShareType.long});

  @override
  State<ShareVideoView> createState() => _ShareVideoDialog();
}

class _ShareVideoDialog extends State<ShareVideoView>
    with TickerProviderStateMixin {
  List<bool> checkedList = [];

  double videoWidth = 0;
  double videoHeight = 0;
  late double sharePanelHeight = Screen.width / 4 * 3;
  double? coverHeight;
  double? qrCodeHeight;
  UserInfoModelEntity? get userData => UserStore.to.getUserInfoModel;
  @override
  void initState() {
    super.initState();

    coverHeight = (sharePanelHeight - 40) / 2;
    qrCodeHeight = (sharePanelHeight - 40) / 5;
  }

  /// 复制链接
  void _onCopyLink() {
    if (userData?.shareUrl.isNotEmpty ?? false) {
      Clipboard.setData(ClipboardData(text: userData?.shareUrl ?? ""));
      showToast(msg: "复制成功，快去分享吧");
    }
  }

  /// 保存图片
  void _onSaveImg() async {
    //保存图片分享
    //执行缩小动画
    ///保存图片
    await _capturePngAndSaveToGallery();
    setState(() {});
    //   Navigator.pop(context);
  }

  GlobalKey<_ShareVideoDialog> globalKey = GlobalKey();

  /// 将组件转化为图片数据
  Future<void> _capturePngAndSaveToGallery() async {
    RenderRepaintBoundary? boundary =
        globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    ui.Image? image = await boundary?.toImage(pixelRatio: 3.0);
    ByteData? byteData =
        await image?.toByteData(format: ui.ImageByteFormat.png);
    await savePngDataToAblumn(byteData?.buffer.asUint8List());
  }

  /// 保存数据到相册
  Future<bool> savePngDataToAblumn(Uint8List? pngBytes) async {
    if (pngBytes == null) return false;
    var map = await ImageGallerySaver.saveImage(pngBytes);
    if (null != map && map["isSuccess"] == true) {
      showToast(msg: "保存成功");
      Navigator.of(context).pop();
      return true;
    } else {
      showToast(msg: "保存失败，请手动截图");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: RepaintBoundary(
            key: globalKey,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final officialUrl = ConfigStore.to.configBean.shareUrl ?? "";
    return Container(
      width: 326,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: AppColor.primaryDialogBgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.shareType == ShareType.long ? 150 : 326,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomImage(
                  borderRadius: BorderRadius.circular(10.r),
                  url: widget.cover ?? "",
                  height: widget.shareType == ShareType.long ? 150 : 326,
                ),
                Image.asset(
                  "assets/images/share_video_play.png",
                  width: 28,
                  height: 25,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: QrImageView(
                  data: userData?.shareUrl ?? "",
                  size: 120,
                  padding: const EdgeInsets.all(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "官网地址：$officialUrl",
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getCommonButton('复制链接',
                    width: 137,
                    height: 40,
                    radius: 100,
                    onClick: _onCopyLink,
                    color: Colors.white,
                    textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                const Spacer(),
                getCommonButton('保存图片',
                    width: 137,
                    height: 40,
                    radius: 100,
                    onClick: _onSaveImg,
                    color: AppColor.primaryButtonColor,
                    textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
