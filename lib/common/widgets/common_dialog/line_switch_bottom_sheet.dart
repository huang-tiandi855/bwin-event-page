import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 底部线路切换单项：展示名 + 线路地址/域名（用于选中比对与回调）。
class LineSwitchItem {
  const LineSwitchItem({
    required this.name,
    required this.line,
  });

  final String name;

  /// 线路值（域名或 URL），与 [selectedLine] 比对以展示选中态。
  final String line;
}

/// 将配置下发的 [PlayLineConfig] 转为 [LineSwitchItem] 列表。
List<LineSwitchItem> lineSwitchItemsFromPlayLines(List<PlayLineConfig> lines) {
  return List.generate(lines.length, (index) {
    final item = lines[index];
    final name = item.name?.trim();
    return LineSwitchItem(
      name: name != null && name.isNotEmpty ? name : '线路${index + 1}',
      line: item.line?.trim() ?? '',
    );
  });
}

/// 将 [Domain] CDN 列表转为 [LineSwitchItem]（如短剧播放页选线）。
List<LineSwitchItem> lineSwitchItemsFromCdnDomains(List<Domain> domains) {
  return List.generate(domains.length, (index) {
    final item = domains[index];
    final name = item.desc?.trim();
    return LineSwitchItem(
      name: name != null && name.isNotEmpty ? name : '线路${index + 1}',
      line: item.url?.trim() ?? '',
    );
  });
}

/// 单个线路分组（用于 [showCombinedLineSwitchBottomSheet]）。
class LineSwitchSection {
  const LineSwitchSection({
    required this.title,
    required this.lines,
    required this.onSelected,
    this.selectedLine,
    this.emptyText = '暂无可用线路',
  });

  final String title;
  final List<LineSwitchItem> lines;
  final String? selectedLine;
  final void Function(LineSwitchItem item, int index) onSelected;
  final String emptyText;
}

/// 多分组线路切换弹窗（如「图片线路 + 视频线路」合并面板）。
///
/// 与 [showLineSwitchBottomSheet] 不同，这里采用两列卡片栅格、分组标题居中、
/// 分组之间用细分隔线断开。选中后默认关闭弹窗（[autoPop]）。
Future<void> showCombinedLineSwitchBottomSheet({
  required BuildContext context,
  required List<LineSwitchSection> sections,
  bool autoPop = true,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF061C1B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.w)),
          ),
          padding: EdgeInsets.only(top: 12.w, bottom: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              for (int i = 0; i < sections.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.w,
                    ),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                _CombinedLineSection(
                  section: sections[i],
                  onItemTap: (item, index) {
                    sections[i].onSelected(item, index);
                    if (autoPop) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class _CombinedLineSection extends StatelessWidget {
  const _CombinedLineSection({
    required this.section,
    required this.onItemTap,
  });

  final LineSwitchSection section;
  final void Function(LineSwitchItem item, int index) onItemTap;

  @override
  Widget build(BuildContext context) {
    final String? current = section.selectedLine?.trim();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.w),
            child: Text(
              section.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          if (section.lines.isEmpty)
            SizedBox(
              height: 48.w,
              child: Center(
                child: Text(
                  section.emptyText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            )
          else
            _buildItemGrid(current),
        ],
      ),
    );
  }

  Widget _buildItemGrid(String? current) {
    const int columns = 2;
    final List<Widget> rows = [];
    for (int i = 0; i < section.lines.length; i += columns) {
      final List<Widget> rowChildren = [];
      for (int c = 0; c < columns; c++) {
        final int idx = i + c;
        if (idx < section.lines.length) {
          final item = section.lines[idx];
          final bool selected = current != null && current.isNotEmpty
              ? item.line == current
              : idx == 0;
          rowChildren.add(Expanded(
            child: _LineCard(
              item: item,
              selected: selected,
              onTap: () => onItemTap(item, idx),
            ),
          ));
        } else {
          rowChildren.add(const Expanded(child: SizedBox.shrink()));
        }
        if (c < columns - 1) {
          rowChildren.add(SizedBox(width: 12.w));
        }
      }
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: 10.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: rowChildren,
        ),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final LineSwitchItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF142B2A),
          borderRadius: BorderRadius.circular(12.w),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppColor.primaryButtonColor : Colors.white,
            fontSize: 15.sp,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// 展示底部线路切换弹窗（样式与长视频播放器选线一致）。
///
/// [lines] 可选线路；[selectedLine] 当前使用线路，为空时默认高亮第一条。
/// 选中后通过 [onSelected] 回调，默认自动关闭弹窗。
Future<void> showLineSwitchBottomSheet({
  required BuildContext context,
  required List<LineSwitchItem> lines,
  String? title,
  String? selectedLine,
  required void Function(LineSwitchItem item, int index) onSelected,
  bool autoPop = true,
  String emptyText = '暂无可用线路',
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (sheetContext) {
      final String? current = selectedLine?.trim();
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF061C1B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.w)),
        ),
        padding: EdgeInsets.only(top: 12.w, bottom: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            if (title?.isNotEmpty ?? false) ...[
              10.h.verticalSpace,
              Text(
                title ?? '',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(.5),
                ),
              ),
            ],
            SizedBox(height: 16.w),
            if (lines.isEmpty)
              SizedBox(
                height: 48.w,
                child: Center(
                  child: Text(
                    emptyText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(lines.length, (index) {
                final item = lines[index];
                final bool selected = current != null && current.isNotEmpty
                    ? item.line == current
                    : index == 0;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    onSelected(item, index);
                    if (autoPop) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  child: SizedBox(
                    height: 48.w,
                    child: Center(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          color: selected
                              ? AppColor.primaryButtonColor
                              : Colors.white,
                          fontSize: 16.sp,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    },
  );
}
