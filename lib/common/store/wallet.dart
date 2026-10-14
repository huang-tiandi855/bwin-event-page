import 'package:comics_app/common/apis/wallet.dart';
import 'package:comics_app/common/entities/wallet_model.dart';
import 'package:get/get.dart';

///钱包
class WalletStore extends GetxController {
  static WalletStore get to => Get.find();

  final Rx<WalletModel> _walletModel = WalletModel().obs;

  void saveWalletModel(WalletModel walletModel) {
    _walletModel.value = walletModel;
  }

  WalletModel? get getWalletModel => WalletStore.to._walletModel.value;

  ///刷新钱包信息
  Future refreshWallet() async {
    WalletModel wallet = await WalletApi.getWallet();
    if (wallet.uid != null) saveWalletModel(wallet);
  }

  int obtainTotalCoin(){
   return  (getWalletModel?.amount??0) + (getWalletModel?.income??0);
  }
}
