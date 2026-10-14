import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///VIP 帮助中心UI
class HelpQuestionPage extends StatelessWidget {
  final int helpType;

  const HelpQuestionPage({Key? key, this.helpType = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String appBarTitle = "问题详情";
    String title = "";
    String content = "";
    bool hasTitleUI = true;
    switch (helpType) {
      case 0:
        title = "如果重复购买了会员怎么办？";
        content = "同一个账号开通两次会员，会员时长将会根据购买的顺延，不会重叠时间，请您核实账号的到期时间，是否延长两次订购的时长。";
        break;
      case 1:
        title = "支付成功了，但是没有显示成为会员？";
        content =
            "请您核实订单是否支付成功，可在开通会员页面右上角点击【账单明细】查看；\n\n若订单存在但还不是会员，请尝试退出页面，然后再次进入，会员状态会自动刷新。\n\n若您正确操作以上步骤还是不显示会员，请您尝试退出重登的方式。\n\n若仍未解决，请您咨询在线客服。";
        break;
      case 2:
        title = "通常会有哪些原因造成支付失败？";
        content =
            "网络故障等原因，会提示您“支付失败，请重试”，在这种情况下，您不会被扣费，该情况下，可能是短暂的网络不稳定，请您重新进入购买页面进行支付。由于您微信、支付宝等支付方式余额不足，在这种情况下，您不会被扣费，该情况下您完成充值后再进行支付。\n\n还有一种原因是支付通道不稳定，导致订单支付失败，可尝试重新发起订单付款请求，后台会切换支付通道保持支付流畅。\n\n如果您确定已经扣款，可前往会员支付页面，点击右上角“账单明细”在订单列表里面查看消费记录，若无消费记录，请您咨询在线客服。";
        break;
      case 3:
        appBarTitle = "支付问题";
        hasTitleUI = false;
        title = "";
        content =
            "1.因超时支付无法到账，请重新发起。\n\n2.每天发起支付不能超过5次，连续发起且未支付，账号可能被加入黑名单。\n\n3.支付通道在夜间比较忙碌，尝试多次发起，后台会为您自动切换不同支付通道。\n\n4.若充值成功，用户权益通常会在数分钟内到账，请刷新APP或重启。\n\n5.若支付成功并重启APP后依然没有到账，请联系在线客服并提供付款成功凭证截图。";
        break;
      case 4:
        appBarTitle = "账号问题";
        hasTitleUI = false;
        title = "";
        content =
            "本平台登录会自动创建账号，需保存账号凭证或绑定手机号码，才能记录之前的账号信息。受行业限制，APP无法正常使用时需升级，未绑定手机号码会导致账号信息丢失。\n\n请及时绑定手机号码或保存账号凭证，以免VIP信息丢失，造成巨大财产损失！\n账号丢失的用户可在 『我的』页面-账号找回，原账号的VIP信息会转移至新账号上。\n\n『账号凭证』『手机绑定』都没有的情况下，如账号VIP信息丢失，可以提供VIP支付充值凭证截图联系在线客服为您查询核实恢复VIP。";
        break;
      case 5:
        appBarTitle = "报毒提醒";
        hasTitleUI = false;
        title = "";
        content =
            "本平台有主要收益为广告赞助，且保证APP安全无毒，因平台主要展示内容为色情属于特殊行业，某些杀毒软件会误报毒提醒，如遇此类提醒请忽略继续使用。";
        break;
    }

    return Scaffold(
      backgroundColor: AppColor.cf5f5f5,
      appBar: commonAppBar(appBarTitle),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.w, horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasTitleUI)
                Text(
                  title,
                  style: TextStyle(
                      color: AppColor.c333333, fontSize: 15.sp),
                ),
              if (hasTitleUI) SizedBox(height: 12.w),
              Text(
                content,
                style: TextStyle(
                  color: AppColor.c333333,
                  fontSize: 15.sp,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
