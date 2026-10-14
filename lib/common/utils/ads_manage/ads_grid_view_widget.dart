import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/utils/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../pages/image/network/custom_image_network.dart';
import '../../entities/config.dart';
import '../utils.dart';
import 'ads_info_list_extension.dart';
import 'getAdv.dart';

/// 广告九宫格 / 横排
///
/// 数据来源（按优先级）：
/// 1. 显式传入的 [adsArr] 列表，优先使用；
/// 2. 通过 [adsType] 由组件内部调用 [getAdsByType] 自动获取。
///
/// 至少需要提供其中之一。
///
/// 大样式（[isBigStyle] = `true`）排版规则：
/// * 总数 ≤ 5 → 仅第一排，有几个排几个；
/// * 5 < 总数 < 10 → 第一排 5 个，第二排静态展示剩余（左对齐）；
/// * 总数 ≥ 10 → 第一排 5 个，**第二排无缝跑马灯**（自动向左滚动，
///   末尾与开头之间的间隔与 item 间距一致）。
class AdsGridViewWidget extends StatefulWidget {
  /// true: 10宫格大样式；false: 单行横向滚动小样式
  final bool? isBigStyle;
  final EdgeInsetsGeometry? padding;
  final List<AdsInfoList>? adsArr;
  final AdsType? adsType;

  const AdsGridViewWidget({
    super.key,
    this.isBigStyle = false,
    this.padding,
    this.adsArr,
    this.adsType,
  }) : assert(adsArr != null || adsType != null, 'adsArr 与 adsType 至少需要提供一个');

  @override
  State<StatefulWidget> createState() => _AdsGridViewWidgetState();
}

class _AdsGridViewWidgetState extends State<AdsGridViewWidget> {
  /// 大样式每排最多 cell 数；同时也是「第二排是否进入跑马灯」的阈值。
  static const int _columnsPerRow = 5;

  /// cell 宽高比（来自原 GridView childAspectRatio 60/84）。
  static const double _cellAspect = 60 / 84;

  @override
  Widget build(BuildContext context) {
    if (widget.adsArr != null) {
      return _buildGrid(widget.adsArr!);
    }
    return GetBuilder<ConfigStore>(
      builder: (_) => _buildGrid(getAdsByType(widget.adsType!)),
    );
  }

  Widget _buildGrid(List<AdsInfoList> ads) {
    if (ads.isEmpty) return const SizedBox();
    if (widget.isBigStyle == true) {
      return _buildBigStyle(ads);
    }
    return _buildSmallStyle(ads);
  }

  /// 大样式：两排布局 + 第二排可选跑马灯
  Widget _buildBigStyle(List<AdsInfoList> ads) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double colSpacing = 10.w;
          final double rowSpacing = 10.w;
          final double cellWidth =
              (constraints.maxWidth - colSpacing * (_columnsPerRow - 1)) /
                  _columnsPerRow;
          final double cellHeight = cellWidth / _cellAspect;

          final List<AdsInfoList> firstRow =
              ads.take(_columnsPerRow).toList(growable: false);
          final List<AdsInfoList> rest = ads.length > _columnsPerRow
              ? ads.sublist(_columnsPerRow)
              : const <AdsInfoList>[];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStaticRow(
                items: firstRow,
                cellWidth: cellWidth,
                cellHeight: cellHeight,
                colSpacing: colSpacing,
              ),
              if (rest.isNotEmpty) ...[
                SizedBox(height: rowSpacing),
                rest.length < _columnsPerRow
                    ? _buildStaticRow(
                        items: rest,
                        cellWidth: cellWidth,
                        cellHeight: cellHeight,
                        colSpacing: colSpacing,
                      )
                    : _MarqueeAdsRow(
                        items: rest,
                        cellWidth: cellWidth,
                        cellHeight: cellHeight,
                        colSpacing: colSpacing,
                        itemBuilder: _buildAdItem,
                      ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// 小样式：单行横向滚动（保持旧逻辑）
  Widget _buildSmallStyle(List<AdsInfoList> ads) {
    return Container(
      margin: widget.padding,
      height: 84.h,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            padding: EdgeInsets.zero,
            itemCount: ads.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return SizedBox(
                width: (constraints.maxWidth - 40) / 5.0,
                height: 84.h,
                child: _buildAdItem(ads[index]),
              );
            },
          );
        },
      ),
    );
  }

  /// 静态一行（左对齐，cell 等宽，不足 5 个时右侧留空）
  Widget _buildStaticRow({
    required List<AdsInfoList> items,
    required double cellWidth,
    required double cellHeight,
    required double colSpacing,
  }) {
    return SizedBox(
      height: cellHeight,
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: colSpacing),
            SizedBox(
              width: cellWidth,
              height: cellHeight,
              child: _buildAdItem(items[i]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdItem(AdsInfoList model) {
    return InkWell(
      onTap: () =>
          model.jumpAdvByType(widget.adsType ?? AdsType.dbLineHead),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImage(
                url: model.resourceUrl,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          const Spacer(),
          FittedBox(
            child: Text(
              (model.title ?? "").ellipsis(5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// 第二排无缝跑马灯：自动向左匀速滚动，**末尾与首位之间的间隔与 item 间距完全一致**。
///
/// **真·无限列表实现**：
/// * `ListView.builder` **不传 `itemCount`**（默认 null），即 [SliverList] 视
///   itemBuilder 永远会返回非 null，列表逻辑上不存在「尾部」；
/// * 每个 `index` 通过 `index % items.length` 取模映射到真实 item，因此 cell
///   是真实 items 不断接续，业务里"跑完"的概念不存在；
/// * 配合 `itemExtent` 让底层走 `RenderSliverFixedExtentList` 的高效布局路径，
///   **每帧只构造视口内可见的几个 cell（≈ 7 个 widget）**，跟列表「无限」无关。
///   即使用户停留几个小时，内存里也只挂这几个 cell；
/// * 禁用手势（[NeverScrollableScrollPhysics]），纯粹装饰性自动滚动，跟原
///   `GridView`（NeverScrollable）一致；
/// * `ScrollController.offset` 在 [Ticker] 推动下单调递增。`double` 精度
///   下，10⁹ 像素之前都不会丢精度，按 30 px/s 跑也得 1 年以上 —— 业务里不会触达。
class _MarqueeAdsRow extends StatefulWidget {
  const _MarqueeAdsRow({
    required this.items,
    required this.cellWidth,
    required this.cellHeight,
    required this.colSpacing,
    required this.itemBuilder,
  });

  final List<AdsInfoList> items;
  final double cellWidth;
  final double cellHeight;
  final double colSpacing;
  final Widget Function(AdsInfoList) itemBuilder;

  /// 滚动速度（逻辑像素 / 秒）。值越大越快，30 ≈ 每 3.3s 走过一个 60px 宽度的格子。
  final double pxPerSecond = 30;

  @override
  State<_MarqueeAdsRow> createState() => _MarqueeAdsRowState();
}

class _MarqueeAdsRowState extends State<_MarqueeAdsRow>
    with SingleTickerProviderStateMixin {
  late final ScrollController _controller;
  late final Ticker _ticker;
  Duration _lastTickElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !_controller.hasClients) {
      _lastTickElapsed = elapsed;
      return;
    }
    final double dt = (elapsed - _lastTickElapsed).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastTickElapsed = elapsed;
    if (dt <= 0) return;

    // 帧切回 / 后台恢复时 dt 可能突然很大，截一下避免位移跳一大段。
    final double safeDt = dt > 0.1 ? 0.1 : dt;
    _controller.jumpTo(_controller.offset + widget.pxPerSecond * safeDt);
  }

  @override
  Widget build(BuildContext context) {
    final int realLen = widget.items.length;
    final double slotWidth = widget.cellWidth + widget.colSpacing;

    return SizedBox(
      height: widget.cellHeight,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        // 关键：不传 itemCount → 真·无限列表；itemBuilder 永远返回非 null。
        // 每个 cell 自带「右侧 spacing」，所以 cell 之间、以及「items 末项 →
        // 下一轮首项」之间的间距完全一致。
        itemExtent: slotWidth,
        itemBuilder: (context, index) {
          final AdsInfoList model = widget.items[index % realLen];
          return Padding(
            padding: EdgeInsets.only(right: widget.colSpacing),
            child: SizedBox(
              width: widget.cellWidth,
              height: widget.cellHeight,
              child: widget.itemBuilder(model),
            ),
          );
        },
      ),
    );
  }
}
