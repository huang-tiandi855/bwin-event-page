import 'dart:async';
import 'dart:io';

import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

/// 系统升级弹窗（与 [SplashLogic.checkUpgrade] / 设置中心 检查更新 共用）。
Future<void> showAppUpgradeDialog(
  BuildContext context,
  CheckVersionBean version,
) {
  final bool forced = version.forcedUpdate == true;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (BuildContext ctx) => WillPopScope(
      onWillPop: () async => !forced,
      child: AppUpgradeDialog(version: version),
    ),
  );
}

class AppUpgradeDialog extends StatefulWidget {
  const AppUpgradeDialog({
    super.key,
    required this.version,
  });

  final CheckVersionBean version;

  @override
  State<AppUpgradeDialog> createState() => _AppUpgradeDialogState();
}

class _AppUpgradeDialogState extends State<AppUpgradeDialog> {
  /// 与背景图 [AssetsGenImage.icUpgradeBg]（1029×1503）保持一致的纵横比，
  /// 让背景里烤死的「橙色箭头 + 内框」与代码绘制的标题 / 内容区域对齐。
  static const double _bgAspect = 343 / 473;

  late final StreamController<double> _percentStreamController;

  /// 是否已经触发了一次「下载 + 安装」流程，避免按钮被连点 / 进度回调
  /// 多次到达 100% 时重复发起。
  bool _downloading = false;

  /// 是否已经把 APK 交给系统安装器；避免 progress 回调和 await 返回都触发一次。
  bool _installTriggered = false;

  bool get _forced => widget.version.forcedUpdate == true;

  @override
  void initState() {
    super.initState();
    _percentStreamController = StreamController<double>.broadcast();
    _percentStreamController.add(0);
  }

  @override
  void dispose() {
    _percentStreamController.close();
    super.dispose();
  }

  Future<void> _onUpgradeTap() async {
    if (!Platform.isAndroid) {
      // iOS 走 App Store / TestFlight，下载行为另行处理；此处保持与旧版一致：
      // 不做任何动作，由调用方决定是否在 iOS 上展示该弹窗。
      return;
    }
    if (_downloading) return;
    _downloading = true;
    _installTriggered = false;

    final String? url = widget.version.url;
    if (url == null || url.isEmpty) {
      _downloading = false;
      showToast(msg: '下载地址为空');
      return;
    }

    final Directory? dir = await getExternalStorageDirectory();
    if (dir == null) {
      _downloading = false;
      showToast(msg: '无法访问存储目录');
      return;
    }
    final String saveDirectory = path.join(dir.path, 'apk');
    final Directory saveDir = Directory(saveDirectory);
    if (!await saveDir.exists()) {
      saveDir.createSync(recursive: true);
    }
    final int time = DateTime.now().microsecondsSinceEpoch;
    final String savePath = path.join(saveDirectory, '$time.apk');

    try {
      await HttpRequest().downApk(
        url,
        savePath,
        onReceiveProgress: (int count, int total) {
          if (total <= 0) return;
          final double value = count / total;
          if (!_percentStreamController.isClosed) {
            _percentStreamController.add(value.clamp(0.0, 1.0));
          }
          // 注意：不要在这里触发安装。dio 的 onReceiveProgress 在 count==total
          // 时回调，此刻 HTTP 响应未必结束、文件流还没 close，APK 内容可能不完整，
          // 系统安装器读到一个尺寸 / 校验对不上的 APK 就会回 RESULT_FIRST_USER (1)
          // → install_plugin 把它当成 "Install Cancel"。安装必须放到 download
          // 整体 await 返回之后再做。
        },
      );
    } catch (e) {
      _downloading = false;
      debugPrint('downApk error: $e');
      showToast(msg: '下载失败，请重试');
      return;
    }

    await _installDownloadedApk(savePath);
    _downloading = false;
  }

  /// 真正把下载好的 APK 交给系统安装器。做了四件事：
  /// 1. 校验文件确实存在且大小合理，避免把空文件 / HTML 错误页喂给安装器；
  /// 2. 自己用 permission_handler 把 REQUEST_INSTALL_PACKAGES 拿好，
  ///    绕开 install_plugin 2.1.0 里那条「跳设置授权后不会自动重试安装」的死路；
  /// 3. 用 [_installTriggered] 保证只触发一次；
  /// 4. install_plugin 在「系统安装器返回失败」时统一回 `Install Cancel`，
  ///    这里给出更可读的提示，不要让用户以为是自己点了取消。
  Future<void> _installDownloadedApk(String savePath) async {
    if (_installTriggered) return;
    _installTriggered = true;

    final File apk = File(savePath);
    if (!apk.existsSync()) {
      showToast(msg: '安装包不存在，请重试');
      return;
    }
    final int size = apk.lengthSync();
    if (size < 1024) {
      // 小于 1KB 基本可以判定不是有效 APK（极大概率是接口返回了错误页 / HTML）。
      try {
        apk.deleteSync();
      } catch (_) {}
      showToast(msg: '安装包损坏，请重试');
      return;
    }

    // 在调用 install_plugin 之前先确保「安装未知应用」权限到手。
    // install_plugin 2.1.0 的权限申请回调链是坏的（系统设置返回的永远是
    // RESULT_CANCELED，但它只在 RESULT_OK 时才重试安装），所以这里手动兜底。
    final bool ok = await _ensureInstallPackagesPermission();
    if (!ok) {
      showToast(msg: '未获得安装权限，请在系统设置中允许安装未知应用');
      return;
    }

    try {
      final dynamic result = await InstallPlugin.installApk(savePath);
      debugPrint('installApk result: $result');
      if (result is Map && result['isSuccess'] != true) {
        // install_plugin 把「系统安装失败 (RESULT_FIRST_USER)」也叫做
        // "Install Cancel"，这里给一个更准确的中文提示。常见原因：
        //   - APK 签名 / 包名 / versionCode 与已安装版本冲突
        //   - APK 损坏或下载未完整落盘
        //   - 用户在系统安装器里点了取消
        showToast(msg: '安装失败，请检查安装包或稍后重试');
      }
    } catch (e) {
      debugPrint('installApk error: $e');
      showToast(msg: '安装失败：$e');
    }
  }

  /// 拿到 `REQUEST_INSTALL_PACKAGES` 权限。
  ///
  /// 关键点：从系统设置回来之后必须**重新查 status**，不能信
  /// `Permission.requestInstallPackages.request()` 的返回值——它在某些
  /// Android 版本上即使用户已经打开了开关，也会返回 `denied`，导致出现
  /// 「明明授权了却提示安装失败」的现象。
  Future<bool> _ensureInstallPackagesPermission() async {
    if (!Platform.isAndroid) return true;
    PermissionStatus status = await Permission.requestInstallPackages.status;
    if (status.isGranted) return true;
    status = await Permission.requestInstallPackages.request();
    if (status.isGranted) return true;
    // 跳完设置回来再确认一次，绕开部分机型 request() 误报 denied 的问题。
    final PermissionStatus rechecked =
        await Permission.requestInstallPackages.status;
    return rechecked.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBody(),
              if (!_forced) ...[
                20.h.verticalSpace,
                _buildFloatingClose(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final double width = 343.w;
    final double height = width / _bgAspect;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景：自带橙色箭头 + 内容框；用 BoxFit.fill 撑满，宽高比已对齐。
          AssetsGen.images.upgrade.icUpgradeBg.image(fit: BoxFit.fill),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 110.w, 12.w, 18.w),
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final CheckVersionBean ver = widget.version;
    return Column(
      children: [
        40.h.verticalSpace,
        _buildInfoRow(ver),
        12.h.verticalSpace,
        Expanded(child: _buildUpdateContentArea(ver)),
        17.h.verticalSpace,
        StreamBuilder<double>(
          initialData: 0.0,
          stream: _percentStreamController.stream,
          builder: (BuildContext context, AsyncSnapshot<double> s) {
            final double p = (s.data ?? 0.0).clamp(0.0, 1.0);
            return p > 0 ? _buildProgress(p) : _buildButtons();
          },
        ),
        4.h.verticalSpace,
        Text(
          '建议在wifi环境下更新，以获得更好的下载体验',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(CheckVersionBean ver) {
    final String? rawSize = ver.size?.trim();
    final bool hasSize = rawSize != null && rawSize.isNotEmpty;
    final String version = (ver.verName ?? '').trim();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Expanded(
            child: _UpgradeInfoCell(
              icon: AssetsGen.images.upgrade.icUpgradeVersion,
              label: '版本号',
              value: version.isEmpty ? '-' : 'v$version',
            ),
          ),
          if (hasSize)
            Expanded(
              child: _UpgradeInfoCell(
                icon: AssetsGen.images.upgrade.icUpgradePackageSize,
                label: '更新包大小',
                value: rawSize,
              ),
            )
          else
            const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildUpdateContentArea(CheckVersionBean ver) {
    // 背景图里已经烤死了一个内容框；这里只在框里填内容，外框不再重绘。
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10.w, 20.h, 10.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '更新内容',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          14.h.verticalSpace,
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                (ver.description ?? '').trim().isEmpty
                    ? '暂无更新内容'
                    : ver.description!,
                style: TextStyle(
                  height: 1.5,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _UpgradePrimaryButton(onTap: _onUpgradeTap),
        if (!_forced) ...[
          12.w.horizontalSpace,
          _UpgradeSecondaryButton(onTap: () => Get.back()),
        ],
      ],
    );
  }

  Widget _buildProgress(double percent) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          LinearPercentIndicator(
            animation: true,
            animateFromLastPercent: true,
            lineHeight: 8.w,
            percent: percent,
            barRadius: Radius.circular(8.w),
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white.withOpacity(0.15),
            progressColor: const Color(0xFFE1351F),
          ),
          8.h.verticalSpace,
          Text(
            '${(percent * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingClose() {
    return GestureDetector(
      onTap: Get.back,
      behavior: HitTestBehavior.opaque,
      child: AssetsGen.images.upgrade.icDialogClose
          .image(width: 36.w, height: 36.w),
    );
  }
}

/// 「立即更新」实心按钮：直接使用烤死了文案的 `ic_upgrade_btn.webp`。
///
/// 因为按钮背景与文案是一张图，无法替换文字；如果产品要做文案 A/B
/// 实验需要换成「Container + 渐变 + Text」组合，并保留与图片一致的红色渐变。
class _UpgradePrimaryButton extends StatelessWidget {
  const _UpgradePrimaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AssetsGen.images.upgrade.icUpgradeBtn.image(
        width: 150.w,
        height: 33.w,
        fit: BoxFit.fill,
      ),
    );
  }
}

/// 「稍后提醒」描边按钮：与实心按钮等宽等高，用 1.w 红色描边 + 透明填充，
/// 视觉上与设计稿的 outlined 红色按钮对齐。
class _UpgradeSecondaryButton extends StatelessWidget {
  const _UpgradeSecondaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 150.w,
        height: 33.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: const Color(0xFFE9C099), width: 1.w),
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Text(
          '稍后提醒',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0XFFFFB57E),
          ),
        ),
      ),
    );
  }
}

/// 弹窗顶部信息行的单格（图标 + 标签 + 值），用于「版本号」「更新包大小」。
class _UpgradeInfoCell extends StatelessWidget {
  const _UpgradeInfoCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  final AssetGenImage icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon.image(width: 26.w, height: 26.w),
        7.w.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            4.h.verticalSpace,
            Text(
              value,
              style: TextStyle(
                color: Colors.white.withOpacity(.5),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
