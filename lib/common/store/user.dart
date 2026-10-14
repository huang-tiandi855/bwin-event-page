import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/code.dart';
import 'package:comics_app/common/services/servers.dart';
import 'package:comics_app/common/values/storage.dart';
import 'package:get/get.dart';

import '../entities/user_info_model_entity.dart';
import '../entities/user_right_entity.dart';

class UserStore extends GetxController {
  static UserStore get to => Get.find();
  final Rx<UserInfoModelEntity> _rxUserInfoModel = UserInfoModelEntity().obs;
  final RxList<UserRightWatchReadCoupon> userRightWatchReadCouponList =
      <UserRightWatchReadCoupon>[].obs; //观阅券
  RxInt selectIndex = 0.obs;
  UserInfoModelEntity? get getUserInfoModel =>
      UserStore.to._rxUserInfoModel.value;

  ///保存用户信息；若含会话 token（含接口字段 `accessToken` 解析到 [UserInfoModelEntity.token]），写入 [Storage.token]。
  saveUserInfo(UserInfoModelEntity info) {
    _rxUserInfoModel.value = info;
    final String? t = info.token?.trim();
    final String? tokenValidDate = info.tokenValidDate;
    if (t != null && t.isNotEmpty) {
      StorageService.to.white(Storage.token, t);
      if (tokenValidDate != null && tokenValidDate.isNotEmpty) {
        StorageService.to.white(Storage.tokenValidDate, tokenValidDate);
      }
    }
  }


  void applyLocalAiTaskCost({
    int gold = 0,
    int imageTimes = 0,
    int videoTimes = 0,
  }) {
    final info = _rxUserInfoModel.value;
    if (gold > 0) {
      final current = info.walletApp ?? 0;
      final next = current - gold;
      info.walletApp = next < 0 ? 0 : next;
    }
    if (imageTimes > 0) {
      final current = info.aiUndressTimes ?? 0;
      final next = current - imageTimes;
      info.aiUndressTimes = next < 0 ? 0 : next;
    }
    if (videoTimes > 0) {
      final current = info.aiFaceSwapTimes ?? 0;
      final next = current - videoTimes;
      info.aiFaceSwapTimes = next < 0 ? 0 : next;
    }
    _rxUserInfoModel.refresh();
    update();
  }

  isVip() {
    return _rxUserInfoModel.value.isVip;
  }

  isNormalVip() {
    return _rxUserInfoModel.value.isNormalVip;
  }

  isDarkVip() {
    return _rxUserInfoModel.value.isDarkVip;
  }

  isAllVip() {
    return _rxUserInfoModel.value.isAllVip;
  }

  /// 会话 accessToken（仅存 [Storage.token]，不含 Jwt 回退）。请求头 `accessToken` 使用。
  String? getAccessToken() {
    final dynamic v = StorageService.to.read(Storage.token);
    if (v == null) {
      return null;
    }
    final String s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  ///获取TOKEN
  String? getToken() {
    String? token;
    if (StorageService.to.read(Storage.token) != null) {
      token = StorageService.to.read(Storage.token);
    } else if (StorageService.to.read(Storage.jwtToken) != null) {
      token = StorageService.to.read(Storage.jwtToken);
    } else {
      token = null;
    }

    return token;
  }

  ///删除TOKEN
  removeToken() {
    StorageService.to.remove(Storage.token);
    StorageService.to.remove(Storage.jwtToken);
  }

  /// 文档公共参数 jwtToken（来自 jwt-token 接口，非登录接口）
  String? getJwtToken() {
    final dynamic v = StorageService.to.read(Storage.jwtToken);
    if (v == null) {
      return null;
    }
    final String s = v.toString();
    return s.isEmpty ? null : s;
  }

  void saveJwtToken(String jwt) {
    StorageService.to.white(Storage.jwtToken, jwt);
  }

  void removeJwtToken() {
    StorageService.to.remove(Storage.jwtToken);
  }

  ///更新用户信息
  Future<bool> updateUser(data) async {
    BaseRespBean result = await UserApi.updateUser(data);
    bool updateSuccess = false;
    if (result.isSuccess && Code.isDocSuccess(result.bizCode)) {
      updateSuccess = true;
      UserInfoModelEntity? userInfoModel = await UserApi.getMineInfo();
      if (userInfoModel != null) saveUserInfo(userInfoModel);
    } else {
      // showToast(msg: result.msg ?? '保存个性签名失败，请稍后再试～');
    }

    return updateSuccess;
  }

  ///刷新用户信息
  Future<bool> refreshUser() async {
    UserInfoModelEntity? userInfoModel = await UserApi.getMineInfo();
    if (userInfoModel != null) saveUserInfo(userInfoModel);
    return true;
  }

  Future<bool> loginByAccount(String mobile, String password) async {
    UserInfoModelEntity? userInfoModel =
        await UserApi.loginByAccount(mobile, password);
    if (userInfoModel != null) {
      saveUserInfo(userInfoModel);
      return true;
    }
    return false;
  }

  ///刷新用户观阅券
  Future<bool> refreshRights() async {
    BaseRespBean baseRespBean = await UserApi.getGoldVideoCoupons();
    if (baseRespBean.isSuccess) {
      UserRightEntity userRightEntity =
          UserRightEntity.fromJson(baseRespBean.data);
      List<UserRightWatchReadCoupon> list =
          userRightEntity.watchReadCoupon ?? [];
      userRightWatchReadCouponList.value =
          list.where((element) => !((element.used ?? true))).toList();

      return true;
    }
    return false;
  }
}
