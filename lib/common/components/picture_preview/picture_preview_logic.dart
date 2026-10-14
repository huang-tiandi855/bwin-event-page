import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/common/widgets/golden_beans_buying.dart';
import 'package:get/get.dart';

import '../../widgets/memberPaying.dart';
import 'picture_preview_state.dart';

class PicturePreviewLogic extends GetxController {
  final PicturePreviewState state = PicturePreviewState();

  @override
  void onInit() {
    super.onInit();


    state.swiperController.index = state.curIndex.value;

    if(state.postItem == null){
      return;
    }
    bool isVip = UserStore.to.isVip();
    if (state.postItem?.coins != 0 &&
        !state.postItem!.vidStatus!.hasPaid! &&
        !ConfigStore.to.shortVideoPaied!.contains(state.postItem!.id)) {
      if (state.curIndex > 2) {
        state.swiperController.index = 2;
        state.swiperController.move(2);
        openGoldenBeansBuying(
          id: state.postItem!.id.toString(),
          price: state.postItem!.coins ?? 0,
          productType: 1,
          isShowCoupon: false,
          isShortVideo: false,
        ).then((value) {
          if (value == PaySuccess.exchangeSuccessFullly ||
              value == PaySuccess.successfulPurchase) {
            //Get.back();
            ConfigStore.to.shortVideoPaied?.add(state.postItem!.id!);
          }
        });

        return;
      }
    }


    if (!isVip && state.postItem!.coins == 0) {
      if (state.curIndex > 2) {
        state.swiperController.index = 2;
        state.swiperController.move(2);
        openMemberPaying(isShowCoupon: false, title: '开通会员查看帖子详情');
        return;
      }
    }


  }

  void onIndexChanged(int index) {
    state.curIndex.value = index;
    update(['pageIndex']);
    if (state.postItem == null) {
      return;
    }
    bool isVip = UserStore.to.isVip();
    if (state.postItem?.coins != 0 &&
        !state.postItem!.vidStatus!.hasPaid! &&
        !ConfigStore.to.shortVideoPaied!.contains(state.postItem!.id) && (state.postItem?.seedLinkStatus??-1) <1) {
      if (index > 2) {
        state.swiperController.move(2);
        openGoldenBeansBuying(
          id: state.postItem!.id.toString(),
          price: state.postItem!.coins ?? 0,
          productType: 1,
          isShowCoupon: false,
          isShortVideo: false,
        ).then((value) {
          if (value == PaySuccess.exchangeSuccessFullly ||
              value == PaySuccess.successfulPurchase) {
            //Get.back();
            ConfigStore.to.shortVideoPaied?.add(state.postItem!.id!);
          }
        });

        return;
      }
    }

    if (!isVip && state.postItem!.coins == 0) {
      if (index > 2) {
        state.swiperController.move(2);
        openMemberPaying(isShowCoupon: false, title: '开通会员查看帖子详情');
        return;
      }
    }
  }
}
