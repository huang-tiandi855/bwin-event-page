import 'package:comics_app/common/routers/app_navigator.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/common_dialog/app_upgrade_dialog.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'state.dart';

class SettingCenterLogic extends GetxController {
  final SettingCenterState state = SettingCenterState();

  @override
  void onReady() {
    super.onReady();
    refreshNetworkImageCacheLabel();
  }

  Future<void> refreshNetworkImageCacheLabel() async {
    final bytes = await state.customNetworkImageCache.diskCacheFolderBytes();
    state.cacheSizeLabel = _formatCacheSizeMb(bytes);
    update();
  }

  Future<void> markCacheCleared() async {
    await state.customNetworkImageCache.emptyCache();
    await refreshNetworkImageCacheLabel();
    showToast(msg: '清除成功');
  }

  Future<void> checkAppUpdate() async {
    final lastVersion = ConfigStore.to.configBean.lastVersion;
    if (lastVersion == null || lastVersion.verName == null || lastVersion.verName!.isEmpty) {
      showToast(msg: '暂无更新');
      return;
    }
    final packageInfo = await PackageInfo.fromPlatform();
    final local = packageInfo.version;
    if (_versionNeedsUpdate(local, lastVersion.verName!)) {
      final ctx = Get.context;
      if (ctx != null && ctx.mounted) {
        await showAppUpgradeDialog(ctx, lastVersion);
      }
    } else {
      showToast(msg: '已经是最新版本');
    }
  }

  void openSelectAvatar() async {
    final result = await Get.toNamed(AppRoutes.SETTING_CENTER_SELECT_AVATAR);
    if (result == true) {
      update();
    }
  }

  void openEditNickname() async {
    final result = await Get.toNamed(AppRoutes.SETTING_CENTER_EDIT_NICKNAME);
    if (result == true) {
      update();
    }
  }

  void openEditGender() async {
    final result = await Get.toNamed(AppRoutes.SETTING_CENTER_EDIT_GENDER);
    if (result == true) {
      update();
    }
  }

  void openBindPhone() async {
    final result = await Get.toNamed(AppRoutes.SETTING_CENTER_BIND_PHONE);
    if (result == true) {
      update();
    }
  }

  void openBindInvite() async {
    //   final result = await Get.toNamed(AppRoutes.SETTING_CENTER_BIND_INVITE);
    //   if (result == true) {
    //     update();
    //   }
    // }
    AppNavigator.to.go(AppRoutes.SHARE_INVITE);
  }
}

String _formatCacheSizeMb(int bytes) {
  if (bytes <= 0) return '0MB';
  final mb = bytes / (1024 * 1024);
  if (mb < 0.01) return '0MB';
  return '${mb.toStringAsFixed(1)}MB';
}

bool _versionNeedsUpdate(String version, String newVersion) {
  final localParts = version.split('.');
  final remoteParts = newVersion.split('.');
  for (var i = 0;
      i < 3 && i < remoteParts.length && i < localParts.length;
      i++) {
    final n = int.tryParse(remoteParts[i]) ?? 0;
    final c = int.tryParse(localParts[i]) ?? 0;
    if (n > c) return true;
    if (n < c) return false;
  }
  return false;
}
