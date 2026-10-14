import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/loading_animation.dart';
import 'package:flutter/material.dart';

///进度提示框
class YJLoadingDialog {
  static final Map<BuildContext, YJLoadingDialog> _cache = {};
  int _retain = 0;
  final OverlayEntry _entry;

  YJLoadingDialog(this._retain, this._entry);

  static void show(BuildContext? context) {
    if (context == null) {
      return;
    }
    YJLoadingDialog? loading = _cache[context];
    loading ??= YJLoadingDialog(0, _buildLoading(context));
    loading._retain++;
    _cache[context] = loading;
  }

  static OverlayEntry _buildLoading(BuildContext context) {
    OverlayEntry entry = OverlayEntry(builder: (context) {
      return PopScope(
          canPop: false,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withAlpha(100),
            alignment: Alignment.center,
            child: const Center(
              child: YJFlickr(
                leftDotColor: AppColor.leftDotColor,
                rightDotColor: AppColor.rightDotColor,
                size: 26,
              ),
            ),
          ));
    });
    Overlay.of(context).insert(entry);
    return entry;
  }

  static void dismiss(BuildContext? context) {
    if (context == null) {
      return;
    }
    YJLoadingDialog? loading = _cache[context];
    if (loading != null) {
      loading._retain--;
      if (loading._retain <= 0) {
        loading._entry.remove();
        _cache.remove(context);
      }
    }
  }
}
