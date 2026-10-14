//检查 当前集数是否有播放权限
import 'package:comics_app/common/entities/module_detail_model/content_model_extension.dart';
import 'package:comics_app/common/utils/const.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../entities/module_detail_model/all_media_info_model.dart';
import '../entities/module_detail_model/content_model.dart';
import '../store/event_tracking_manager.dart';
import '../store/user.dart';
import '../values/enum.dart';
import '../widgets/golden_beans_buying.dart';
import '../widgets/memberPaying.dart';
import '../widgets/new_gold_paying.dart';

class CheckPermissionUtils {
  static Future<bool> checkBuyPermission(
      AllMediaInfoModel model, int index, ValueChanged<AllMediaInfoModel> modelChange) async {
    bool isVip = UserStore.to.isVip();
    int currentIndex = index;
    ContentModel? mediaInfoContents = model.contents[index];
    int listenPermission = mediaInfoContents.listenPermission ?? -1;
    if (listenPermission == -1) {
      showToast(msg: "数据有误");
      return false;
    }
    "idd".printInfo(
        info:
            "==${mediaInfoContents.needPermission}==checkPlayPermission===>${mediaInfoContents.listenPermission}=>>${mediaInfoContents.hasPaid}");
    if (mediaInfoContents.needPermission == 2) {
      return true;
    }
    if (!(mediaInfoContents.isActive ?? false)) {
      showToast(msg: "当前章节未上架");
      return false;
    }
    if (listenPermission != 0) {
      if (model.kind == KindConst.NOVELKIND || model.kind == KindConst.AUDIOKIND) {
        //已购买全本
        if (model.mediaStatus?.hasPaid ?? false) {
          return true;
        }
        if (model.price == 0) {
          return true;
        }
        if (mediaInfoContents.hasPaid == true) {
          "dd".printInfo(info: "$index===>${mediaInfoContents.hasPaid}===>");
          return true;
        }
      } else {
        if (mediaInfoContents.hasPaid == true) {
          return true;
        }
        //已购买全本
        if (model.mediaStatus?.hasPaid ?? false) {
          return true;
        }
      }
    }
    //未购买全本
    switch (listenPermission) {
      //会员
      case 0:
        if (isVip) {
          return true;
        }
        EventTrackingManager().addVideoVipGraphicss(model.id, model.title, GraphicsType.vip);
        if (model.kind == KindConst.NOVELKIND || model.kind == KindConst.AUDIOKIND) {
          var result = await openMemberPaying(
              id: model.id ?? "",
              title: model.title,
              isnovelOrComic: true,
              chatId: mediaInfoContents.id ?? "",
              isShowCoupon: true,
              productType: 28);
          if (result == PaySuccess.exchangeSuccessFullly) {
            model.contents[index].mediaStatus?.hasPaid = true;
            modelChange(model);
            return true;
          }
        } else {
          var result = await openMemberPaying(
              id: model.id ?? "",
              title: mediaInfoContents.name,
              isnovelOrComic: true,
              isShowCoupon: true,
              productType: 28,
              chatId: mediaInfoContents.id ?? "");
          if (result == PaySuccess.exchangeSuccessFullly) {
            model.contents[index].mediaStatus?.hasPaid = true;
            modelChange(model);
            return true;
          }
        }
        return false;
      //金币购买
      case 1:
        if (model.kind == KindConst.NOVELKIND || model.kind == KindConst.AUDIOKIND) {
          var isOk = await openGoldenBeansBuying(
              id: model.id!,
              price: model.price ?? 0,
              productType: 28,
              isShowCoupon: true,
              chapId: mediaInfoContents.id);
          if (isOk == PaySuccess.successfulPurchase) {
            model.mediaStatus?.hasPaid = true;
            modelChange(model);
            return true;
          }
          if (isOk == PaySuccess.exchangeSuccessFullly) {
            model.contents[index].mediaStatus?.hasPaid = true;
            modelChange(model);
            return true;
          }
          return false;
        } else {
          var isOk = await openNewGoldBeanPaying(
            isShowCoupon: true,
            productType: 28,
            isnovelOrComic: true,
            info: model,
            currentIndex: currentIndex,
          );
          if (isOk == PaySuccess.successfulAllEsp) {
            model.mediaStatus?.hasPaid = true;
            modelChange(model);
            return true;
          }
          //购买成功
          if (isOk == PaySuccess.successfulPurchase) {
            model.contents[currentIndex].mediaStatus?.hasPaid = true;
            modelChange(model);
            return true;
          }
          if (isOk == PaySuccess.exchangeSuccessFullly) {
            model.contents[currentIndex].mediaStatus?.hasPaid = true;
            modelChange(model);
            return true;
          }
        }
        return false;
      //免费
      case 2:
        return true;
      default:
        return false;
    }
  }
}
