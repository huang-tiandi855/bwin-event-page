import 'package:comics_app/common/entities/modules_config/notice_model.dart';
import 'package:comics_app/common/routers/app_navigator.dart';
import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/widgets/marquee_widget/marquee_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

export 'package:comics_app/common/entities/modules_config/notice_model.dart'
    show NoticeShowType;

/// 公告跑马灯（自动接入 [ConfigStore.noticeList]）。
///
/// 行为：
/// - 通过 `GetBuilder<ConfigStore>` 监听公告数据的加载完成；
/// - 把 [ConfigStore.noticeList] 内所有 [NoticeModel.title] 拼成一条横向滚动文案；
/// - 公告列表为空（数据未到位或后端无下发）时返回 [SizedBox.shrink] —— 不渲染空条；
/// - 透传 [MarqueeAnnouncementBar] 的常用参数（关闭按钮 / 点击回调 / 关闭回调）。
///
/// 调用方不再需要传写死的 marquee 文本，例如：
/// ```dart
/// const NoticeMarqueeBar(showCloseButton: true)
/// ```
class NoticeMarqueeBar extends StatelessWidget {
  const NoticeMarqueeBar({
    required this.showType,
    super.key,
    this.showCloseButton = true,
    this.onTap,
    this.onDismiss,
    this.separator = '   ',
    this.margin,
    this.padding,
  });

  /// 是否展示右侧关闭按钮。
  final bool showCloseButton;

  /// 整体点击回调（透传给 [MarqueeAnnouncementBar.onTap]）。
  final VoidCallback? onTap;

  /// 用户点击关闭按钮的回调（透传给 [MarqueeAnnouncementBar.onDismiss]）。
  final VoidCallback? onDismiss;

  /// 展示位；后端配置为 [NoticeShowType.all] 的会跟着所有位置一起展示。
  final NoticeShowType showType;

  /// 多条公告之间的分隔符（默认 3 个空格，避免视觉粘连）。
  final String separator;

  final EdgeInsetsGeometry? margin;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfigStore>(
      builder: (_) {
        final int target = showType.value;
        final List<NoticeModel> noticeList = ConfigStore.to.noticeList
            .where((NoticeModel e) =>
                (e.showType == target) && (e.title?.isNotEmpty ?? false))
            .toList();
        if (noticeList.isEmpty) return const SizedBox.shrink();
        return MarqueeListBar(
            margin: margin,
            padding: padding,
            showCloseButton: showCloseButton,
            items: noticeList
                .map(
                  (e) => MarqueeItem(
                    // text: 'content:${e.content ?? ""}-title:${e.title ?? ""}-url:${e.url ?? ""}',
                    text: e.content ?? "",
                    onTap: () => AppNavigator.to.go(e.url),
                  ),
                )
                .toList());
      },
    );
  }
}
