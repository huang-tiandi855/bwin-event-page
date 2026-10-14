import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../common/store/config.dart';
import 'account_credentials_logic.dart';
import 'account_credentials_state.dart';

/// 账号凭证（深色主题 + 顶部装饰图 + 信息卡 + 保存图片）
class AccountCredentialsPage extends StatelessWidget {
  AccountCredentialsPage({Key? key}) : super(key: key);

  final logic = Get.find<AccountCredentialsLogic>();
  final state = Get.find<AccountCredentialsLogic>().state;

  String get _userId {
    final u = UserStore.to.getUserInfoModel;
    if (u?.uid != null && (u!.uid ?? 0) > 0) return (u.uid ?? 0).toString();
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar(
        '账号凭证',
        isShowLine: false,
        bgColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  // 卡片叠在底图上：顶距底图顶部 200.w；总高度预留避免裁剪
                  final stackH = 227.w + 222.w;
                  return RepaintBoundary(
                    key: state.boundaryKey,
                    child: SizedBox(
                      width: w,
                      height: stackH,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 10.w,
                            child: AssetsGen.images.mine.qrcodeImg
                                .image(width: 189.w, height: 283.w),
                          ),
                          Positioned(
                            top: 65.w,
                            right: 14.w,
                            child:
                                AssetsGen.images.mine.qrcodeCredentials.image(
                              width: 159.w,
                              height: 160.w,
                            ),
                          ),
                          Positioned(
                            top: 222.w,
                            left: 0,
                            right: 0,
                            child: _CredentialCard(
                              state: state,
                              userId: _userId,
                              darkWebUrl:
                                  ConfigStore.to.configBean.shareUrl ?? "",
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 22.w),
              Center(
                child: GestureDetector(
                  onTap: logic.saveAccountCredentials,
                  child: AssetsGen.images.mine.qrcodeSaveBtn.image(
                    width: 139.w,
                    height: 51.w,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CredentialCard extends StatelessWidget {
  const _CredentialCard({
    required this.state,
    required this.userId,
    required this.darkWebUrl,
  });

  final AccountCredentialsState state;
  final String userId;
  final String darkWebUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5850B),
              Color(0xFFFF6D6E),
            ]),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 26.w, 18.w, 26.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 二维码 + 四角框
                GetBuilder<AccountCredentialsLogic>(
                  id: 'QrContent',
                  builder: (_) {
                    return SizedBox(
                      width: 119.w,
                      height: 119.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          IgnorePointer(
                            child: AssetsGen.images.mine.qrcodeBorder.image(
                              width: 119.w,
                              height: 119.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (state.cardModel != null)
                            QrImageView(
                              key: ValueKey(
                                '${state.cardModel?.idCard}_${state.cardModel?.idCardPwd}',
                              ),
                              //{"idCard":"34M","idCardPwd":"3XVHU"}
                              data:
                                  '{"idCard":"${state.cardModel?.idCard}","idCardPwd":"${state.cardModel?.idCardPwd}"}',
                              backgroundColor: Colors.white,
                              size: 110.w,
                            ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: SizedBox(
                    height: 119.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'ID $userId',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.w,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFD3636),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            '萝幼院地址：$darkWebUrl',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '提示可通过官方客服找回账号',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primaryYellowColor,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.w),
            Text(
              'APP更新可能导致会员掉线，请勿删除此凭证（截图保存），此凭证是您永久有效的登录路径。',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
