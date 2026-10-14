import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/style/text_styles.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/widgets/CustomLoadingWidget.dart';
import 'package:comics_app/pages/common/splash/splash_logic.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:comics_app/common/utils/system_ui_util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../entities/sign_entity.dart';
import '../../res/r.dart';
import '../../services/storage.dart';
import '../../values/storage.dart';

///公用appBar
AppBar commonRightBtnAppBar(String title,
    {String? rightText, Color? rightTextColor, Function? onRightTap}) {
  return AppBar(
    //leadingWidth: 17.w,
    backgroundColor: Colors.white,
    title: Text(
      title,
      style: TextStyle(
          fontSize: 16.sp,
          color: AppColor.primaryText,
          fontWeight: FontWeight.w500),
    ),
    leading: commonBack(),
    actions: [
      InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          if (onRightTap != null) onRightTap();
        },
        child: Container(
          height: kToolbarHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            rightText ?? "",
            style: TextStyle(
                fontSize: 14.sp,
                color: rightTextColor ?? AppColor.c666666,
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    ],
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(1.w),
      child: Divider(color: AppColor.lineColor, height: 1.w),
    ),
  );
}

///公用appBar
AppBar commonLRBtnAppBar(String title,
    {String? rightText,
    Color? rightTextColor,
    required Function onLeftTap,
    Function? onRightTap}) {
  return AppBar(
    //leadingWidth: 17.w,
    backgroundColor: Colors.white,
    title: Text(
      title,
      style: TextStyle(
          fontSize: 18.sp,
          color: AppColor.primaryText,
          fontWeight: FontWeight.w500),
    ),
    leading: IconButton(
      onPressed: () {
        onLeftTap();
      },
      iconSize: 18.w,
      padding: EdgeInsets.only(left: AppLocation.appHorizontal),
      alignment: Alignment.centerLeft,
      icon: SvgPicture.asset(
        R.back,
        width: 18.w,
        color: Colors.black,
      ),
    ),
    actions: [
      InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          if (onRightTap != null) onRightTap();
        },
        child: Container(
          height: kToolbarHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            rightText ?? "",
            style: TextStyle(
                fontSize: 15.sp,
                color: rightTextColor ?? AppColor.warmGrey,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    ],
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(1.w),
      child: Divider(color: AppColor.lineColor, height: 1.w),
    ),
  );
}

///公用appBar
///
/// [bottom] 非空时作为 AppBar 底部区域（如 `TabBar` 外包一层 [PreferredSize]），
/// 为空时仍使用底部分割线（由 [isShowLine] 控制是否可见）。
AppBar commonAppBar(String title,
    {List<Widget>? actions,
    bool? isShowTitle,
    bool isShowLine = false,
    Color? bgColor,
    Color? leadingColor = Colors.white,
    Color? titleColor,
    PreferredSizeWidget? bottom}) {
  return AppBar(
    toolbarHeight: kAppBarToolbarHeight,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    title: isShowTitle ?? true
        ? Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              color: titleColor ?? Colors.white,
              fontWeight: FontWeight.w600,
            ),
          )
        : null,
    leading: commonBack(color: leadingColor),
    actions: actions,
    backgroundColor: bgColor ?? Colors.black,
    bottom: bottom ??
        PreferredSize(
          preferredSize: Size.fromHeight(1.w),
          child: Divider(
              color: isShowLine ? AppColor.lineColor : Colors.transparent,
              height: 1.w),
        ),
  );
}

Widget commonLine({Color lineColor = AppColor.lineColor}) {
  return Divider(color: lineColor, height: 1);
}

Widget commonBack({
  VoidCallback? callback,
  Color? color,
  EdgeInsets? padding,
  BoxConstraints? constraints,
}) {
  return IconButton(
    onPressed: () {
      if (callback != null) {
        callback();
      } else {
        Get.back();
      }
    },
    constraints: constraints,
    iconSize: 20.w,
    padding: padding ?? EdgeInsets.only(left: 10.w),
    alignment: Alignment.centerLeft,
    icon: SvgPicture.asset(
      R.back,
      width: 22.w,
      color: color ?? AppColor.white,
    ),
  );
}

///公用提交按钮
GestureDetector commonSubmitButton(String title, {Function? onSubmitTap}) {
  return GestureDetector(
    onTap: () {
      if (onSubmitTap != null) onSubmitTap.call();
    },
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      width: double.infinity,
      height: 45.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xfffbcf17),
        borderRadius: BorderRadius.circular(22.5.w),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xff080703),
          fontWeight: FontWeight.w600,
          fontSize: 18.sp,
        ),
      ),
    ),
  );
}

///公用提交按钮
GestureDetector commonSubmitButton2(String title, {Function? onSubmitTap}) {
  return GestureDetector(
    onTap: () {
      if (onSubmitTap != null) onSubmitTap.call();
    },
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      width: double.infinity,
      height: 44.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: BorderRadius.circular(22.5.w),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xffffffff),
          fontWeight: FontWeight.w600,
          fontSize: 18.sp,
        ),
      ),
    ),
  );
}

///公用提交按钮2
GestureDetector commonSubSubmitButton(String title,
    {double? width, double? height, double? fontSize, Function? onSubmitTap}) {
  return GestureDetector(
    onTap: () {
      if (onSubmitTap != null) onSubmitTap.call();
    },
    child: Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xfffbcf17),
        borderRadius: BorderRadius.circular(22.5.w),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xff080703),
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    ),
  );
}

///公用提交按钮2
GestureDetector commonSubSubmitButton2(String title,
    {double? width, double? height, double? fontSize, Function? onSubmitTap}) {
  return GestureDetector(
    onTap: () {
      if (onSubmitTap != null) onSubmitTap.call();
    },
    child: Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xff7145E7),
        borderRadius: BorderRadius.circular(22.5.w),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xffffffff),
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    ),
  );
}

///在线客服UI
GestureDetector buildOnlineServiceUI({String? questionText}) => GestureDetector(
      onTap: () => AppNavigator.to.commonToCustomerService(),
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: questionText ?? "支付中如有问题，请联系   ",
                    style: TextStyle(
                      color: const Color.fromRGBO(142, 141, 155, 1),
                      fontSize: 13.sp,
                    ),
                  ),
                  TextSpan(
                    text: '在线客服',
                    style: TextStyle(
                      color: const Color.fromRGBO(176, 159, 217, 1),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

///创建标题UI
Text buildSubTitleUI(String? title) => Text(
      title ?? "",
      style: TextStyle(
          fontSize: 16.sp,
          color: AppColor.c333333,
          fontWeight: FontWeight.w700),
    );

///开通会员按钮 UI
GestureDetector joinMembershipButton(String title,
        {double width = 77, double height = 24, GestureTapCallback? onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          gradient: LinearGradient(
            colors: [Color(0xffe4b286), Color(0xffffe9d6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          children: [
            Text(title,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );

showPayForDialogUI({String? title, Function? onTap}) {
  Get.dialog(Scaffold(
    backgroundColor: Colors.transparent,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            ///背景图
            /*Positioned(
                top: 0,
                right: 0,
                left: 0,
                height: 355.w,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 34.w),
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/png/pay_dialog_bg.png',
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                )),*/

            Container(
              margin: EdgeInsets.symmetric(horizontal: 34.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(229, 254, 255, 1),
                      Color.fromRGBO(255, 255, 255, 1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.w)),
              child: Stack(
                children: [
                  /*Positioned(
                      right: 12.w,
                      top: 12.w,
                      child: InkWell(
                        onTap: () {
                          Config.IS_SHOW_PAYMENT_TIPS = true;
                          Get.back();
                        },
                        child: SvgPicture.asset(R.close, width: 16.w),
                      )),*/
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppLocation.appHorizontal),
                        child: Column(
                          children: [
                            SizedBox(height: 18.w),
                            Text('温馨提示',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                            SizedBox(height: 12.w),
                            Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 400,
                                height: 1,
                                decoration: const BoxDecoration(
                                    color: Color(0xFF333333)),
                              ),
                            ),
                            SizedBox(height: 12.w),
                            Text(
                              "1.支付成功后，一般会在3-5分钟内到账，如超时未到账，请联系在线客服为您处理。\n"
                              "\n2.受特殊行业限制，如支付失败可尝试重新发起订单，系统将会自动切换备用的支付通道。\n"
                              "\n3.本APP有稳定的广告收益，产品稳定安全，请放心充值使用,如遇报毒提示忽略即可。",
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.black,
                                  height: 1.8),
                            ),
                            SizedBox(height: 18.w),
                            // Image.asset(R.rechgTip,
                            //     fit: BoxFit.cover, height: 102.w),
                            SizedBox(height: 20.w),
                            /*GestureDetector(
                              onTap: () => Get.to(
                                  () => const HelpQuestionPage(helpType: 3),
                                  opaque: false),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "支付遇到问题",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      height: 1.1,
                                      color: const Color(0xff898989),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Color(0xff898989),
                                  ),
                                ],
                              ),
                            ),*/
                            SizedBox(height: 16.w)
                          ],
                        ),
                      ),
                      /*Container(
                          width: double.infinity,
                          height: 1.w,
                          color: AppColor.whiteBackground),
                      SizedBox(height: 14.w),*/
                      GestureDetector(
                        onTap: () {
                          if (onTap != null) {
                            onTap.call();
                            Get.back();
                            return;
                          }
                          Get.back();
                        },
                        child: Image.asset(
                          "assets/images/png/wozhidaole.png",
                          width: 196.w,
                          height: 38.w,
                        ),
                      ),
                      SizedBox(height: 24.w),
                    ],
                  )
                ],
              ),
            ),
          ],
        )
      ],
    ),
  ));
}

///列表item
GestureDetector buildCommonFuncItemUI(String title, String? subTitle,
        {bool? hideRightArrow = false, GestureTapCallback? onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        height: 49.w,
        child: Row(
          children: [
            Text(title,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColor.c333333,
                  fontWeight: FontWeight.w700,
                )),
            const Spacer(),
            Text(
              subTitle ?? "",
              style: const TextStyle(color: AppColor.c999999),
            ),
            SizedBox(width: 10.w),
            Icon(
              Icons.arrow_forward_ios,
              color: (hideRightArrow ?? false)
                  ? Colors.transparent
                  : AppColor.arrowColour,
              size: 14,
              weight: 6,
            ),
          ],
        ),
      ),
    );

showAccountCredentialsDialog() {
  Get.dialog(Scaffold(
    backgroundColor: Colors.transparent,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 34.w),
          padding: EdgeInsets.only(top: 1.h * 0.5),
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16.w)),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 18.w),
                    Text('账号凭证',
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.w800)),
                    SizedBox(height: 18.w),
                    Opacity(
                      opacity: 0.10,
                      child: Container(
                        width: 296,
                        height: 1,
                        decoration:
                            const BoxDecoration(color: Color(0xFF333333)),
                      ),
                    ),
                    SizedBox(height: 12.w),
                    Text(
                      '受行业限制,APP无法正常使用时需升级,未绑定手机号码会导致账号信息丢失.\n请及时绑定手机号码或保存账号凭证,以免VIP信息丢失,造成巨大财产损失!\n账号丢失的用户可前往 [我的]-设置中心-账号找回通过多途径找回,原账号的VIP信息会转移至新账号上.',
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.black, height: 1.8),
                    ),
                    SizedBox(height: 18.w),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.SETTING_CENTER);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "绑定手机号码  ",
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.2,
                              color: const Color.fromRGBO(51, 51, 51, 1),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12.sp,
                            weight: 3,
                            color: const Color(0xff898989),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.w)
                  ],
                ),
              ),
              SizedBox(height: 14.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      width: 124,
                      height: 37,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x7FAEAEC0),
                            blurRadius: 20,
                            offset: Offset(5, 5),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0xFFFFFFFF),
                            blurRadius: 20,
                            offset: Offset(-5, -5),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: const SizedBox(
                        width: 56,
                        height: 20,
                        child: Text(
                          '我已保存',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFB09FD9),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      StorageService.to
                          .white(Storage.isSaveAccountCredentials, true);
                      Get.toNamed(AppRoutes.ACCOUNT_CREDENTIALS);
                    },
                    child: Container(
                      width: 124,
                      height: 37,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x7FAEAEC0),
                            blurRadius: 20,
                            offset: Offset(5, 5),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0xFFFFFFFF),
                            blurRadius: 20,
                            offset: Offset(-5, -5),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: const SizedBox(
                        width: 56,
                        height: 20,
                        child: Text(
                          '保存图片',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFB09FD9),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /* GestureDetector(
                onTap: () {
                  StorageService.to
                      .white(Storage.isSaveAccountCredentials, true);
                  Get.toNamed(AppRoutes.ACCOUNT_CREDENTIALS);
                },
                child: Text('保存账号凭证',
                    style: TextStyle(fontSize: 18.sp, color: AppColor.black)),
              ),*/
              SizedBox(height: 24.w),
            ],
          ),
        ),
        SizedBox(height: 60.w),
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: SvgPicture.asset(R.closeY, width: 31.w),
        )
      ],
    ),
  ));
}

///APP线路检测失败
Future<bool> appLineDialog({VoidCallback? onTap}) async {
  var res = await Get.dialog(
    barrierDismissible: true,
    Material(
      type: MaterialType.transparency,
      child: Center(
          child: Stack(
        children: [
          Container(
            height: 335.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColor.primaryDialogBgColor,
                borderRadius: BorderRadius.circular(10.r)),
            margin: EdgeInsets.symmetric(horizontal: 34.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 20.w),
                Container(
                  alignment: Alignment.center,
                  height: 28.w,
                  child: Text("系统提示",
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.w500)),
                ),
                18.h.verticalSpace,
                Opacity(
                  opacity: 0.10,
                  child: Container(
                    width: 296,
                    height: 1,
                    decoration: const BoxDecoration(color: Colors.white54),
                  ),
                ),
                Container(height: 14.w),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "APP线路检测失败",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    )),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    alignment: Alignment.centerLeft,
                    child: // 解决方案: 1.请检测您的网络是否正常,是否打开VPN; 2.关闭APP后10分钟后再次尝试; 3.前往官网地址xaw.cc下载最新版本; 4.前往官方TG/土豆交流群反馈问题. 5.备用网址:ht
                        RichText(
                            text: TextSpan(children: [
                      TextSpan(
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColor.white,
                              height: 2),
                          text:
                              "解决方案:\n1.请检测您的网络是否正常,是否打开VPN;\n2.关闭APP后10分钟后再次尝试;\n3.前往官网地址"),
                      TextSpan(
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColor.bluishPurple,
                              height: 2),
                          text: " luoyou.tv",
                          recognizer: TapGestureRecognizer()..onTap = () {}),
                      TextSpan(
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColor.white,
                              height: 2),
                          text: "下载最新版本;"),
                    ]))),
                Container(height: 28.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Get.back();

                        final CustomerLoadingWidget loadingDialog =
                            CustomerLoadingWidget(title: "加载中...");

                        // 选线成功时 [DetectLineManager] 会广播
                        // `closeLoadingDialog` 关闭弹窗。这里用一次性 receiver
                        // 自移除：旧实现里同一个事件的 receiver 每次点击都会
                        // 注册一遍且永不清理，多次切换线路会让旧 receiver
                        // 反复调用 `loadingDialog.cancel()`（[Navigator.pop]），
                        // 把无关页面也意外弹掉。
                        late final void Function(dynamic, dynamic) receiver;
                        receiver = (_, __) {
                          loadingDialog.cancel();
                          FBroadcast.instance()
                              .remove(receiver, key: "closeLoadingDialog");
                        };
                        FBroadcast.instance()
                            .register("closeLoadingDialog", receiver);

                        loadingDialog.show(Get.context);

                        Get.find<SplashLogic>().getNewDomain();
                      },
                      child: Container(
                        width: 108.w,
                        height: 38.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: AppColor.primaryButtonColor,
                            borderRadius: BorderRadius.circular(100.r)),
                        child: Text(
                          "切换线路",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColor.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     //TODO：群聊跳转
                    //     AppNavigator.to.launchWebUrl('https://t.me/yaojingdm1');
                    //     if (onTap != null) {
                    //       onTap();
                    //     }
                    //   },
                    //   child: Container(
                    //     width: 136.w,
                    //     height: 38.w,
                    //     alignment: Alignment.center,
                    //     decoration: BoxDecoration(
                    //         color: AppColor.bluishPurple,
                    //         borderRadius: BorderRadius.circular(20.w)),
                    //     child: Text(
                    //       "前往群聊",
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //           color: const Color.fromRGBO(255, 255, 255, 1),
                    //           fontSize: 18.sp,
                    //           fontWeight: FontWeight.w500),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                Container(height: 28.w),
              ],
            ),
          ),
        ],
      )),
    ),
  );
  return res ?? false;
}

///邀请码绑定成功
showToastDialog(BuildContext context, String tips) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        backgroundColor: const Color(0xff1B164C),
        title: Center(
            child: Text(tips, style: AppTextStyles.kUserProfileTextStyle)),
        content: const Text(''),
      );
    },
  );
}

Future<bool> customSign(SignEntity signEntity) async {
  var res = await Get.dialog(
    barrierDismissible: true,
    Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          alignment: Alignment.center,
          height: (Get.width - 90.w) * 1.2716,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.w),
              image: const DecorationImage(
                  image: AssetImage(R.signBg), fit: BoxFit.cover)),
          margin: EdgeInsets.symmetric(horizontal: 45.w),
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.w),
              Text('签到成功',
                  style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.white)),
              SizedBox(height: 4.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 2.w),
                decoration: BoxDecoration(
                    color: AppColor.cfbcf2f,
                    borderRadius: BorderRadius.circular(12.w)),
                child: Text("已累计签到${signEntity.signCount}天",
                    style: TextStyle(fontSize: 13.sp, color: AppColor.c1b164c)),
              ),
              SizedBox(height: 60.w),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (index) {
                  /*if (index == 1 || index == 4) {
                    return signItem(
                        index: index,
                        couponNum: 1,
                        isShowLine: index != 6,
                        isSign: (signEntity.signCount ?? 0) >= index + 1);
                  }*/

                  if (index == 1) {
                    return signItem(
                        index: index,
                        couponNum: 1,
                        isShowLine: index != 6,
                        isSign: (signEntity.signCount ?? 0) >= index + 1);
                  }

                  if (index == 6) {
                    return signItem(
                        index: index,
                        couponNum: 1,
                        isShowLine: index != 6,
                        isSign: (signEntity.signCount ?? 0) >= index + 1);
                  }
                  return signItem(
                      index: index,
                      isShowLine: index != 6,
                      isSign: (signEntity.signCount ?? 0) >= index + 1);
                }),
              ),
              SizedBox(height: 10.w),
              Center(
                child: Text("累计签到7天奖励观阅券",
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColor.c1b164c,
                        fontWeight: FontWeight.w500)),
              ),
              SizedBox(height: 5.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 64.w,
                      height: 64.w,
                      margin: EdgeInsets.only(top: 2.w),
                      child: Image.asset('assets/images/png/yue.png')),
                  SizedBox(width: 2.w),
                  Text("X2",
                      style: TextStyle(
                          fontSize: 24.sp,
                          color: AppColor.c9521f9,
                          fontWeight: FontWeight.w500))
                ],
              ),
              SizedBox(height: 2.w),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    width: 218.w,
                    height: 39.w,
                    decoration: BoxDecoration(
                        color: AppColor.bluishPurple,
                        borderRadius: BorderRadius.circular(25.w)),
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: 2.5.w),
                    child: Text(
                      "今日已签到",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.w),
              Center(
                child: Text('累计7天/周期 循环签到',
                    style: TextStyle(
                        fontSize: 10.w,
                        color: AppColor.warmGrey,
                        fontWeight: FontWeight.w500)),
              )
            ],
          ),
        ),
      ),
    ),
  );
  return res ?? false;
}

Widget signItem(
    {int couponNum = 0,
    bool isShowLine = true,
    required int index,
    bool isSign = false}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: isSign ? AppColor.c9521ff : AppColor.ccdbbf5,
                borderRadius: BorderRadius.circular(12.w)),
            child: couponNum > 0
                ? Image.asset(R.yue2, width: 18.w, height: 18.w)
                : (isSign
                    ? SvgPicture.asset(R.gou, width: 18.w, height: 18.w)
                    : Text('${index + 1}')),
          ),
          isShowLine
              ? Container(
                  width: 6.w,
                  height: 2.w,
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.w),
                  color: AppColor.ccdbbf5,
                )
              : Container()
        ],
      ),
      couponNum > 0
          ? Container(
              width: 20.w,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Text("x$couponNum",
                  style: TextStyle(
                      color: AppColor.c9521f9,
                      fontSize: 11.w,
                      fontWeight: FontWeight.w500)),
            )
          : Container()
    ],
  );
}
