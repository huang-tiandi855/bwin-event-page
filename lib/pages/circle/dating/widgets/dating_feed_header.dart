import 'package:comics_app/common/entities/circle/dating_models.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DatingTypeSelector extends StatelessWidget {
  const DatingTypeSelector({
    super.key,
    required this.types,
    required this.selectedType,
    required this.onChanged,
  });

  final List<DatingDictItem> types;
  final int? selectedType;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (types.length < 2) return const SizedBox.shrink();
    final left = types[0];
    final right = types.length > 1 ? types[1] : types[0];
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color(0xFF2C224A),
          Color(0xFF22233B),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(8.r),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(child: _typeCard(left, selectedType == left.value)),
          Expanded(child: _typeCard(right, selectedType == right.value)),
        ],
      ),
    );
  }

  Widget _typeCard(DatingDictItem item, bool selected) {
    final isLoufeng = item.value == DatingCardType.loufeng.value;
    final icon = isLoufeng
        ? selected
            ? AssetsGen.images.dating.datingTypeLoufengSel
            : AssetsGen.images.dating.datingTypeLoufeng
        : selected
            ? AssetsGen.images.dating.datingTypeWaiweiSel
            : AssetsGen.images.dating.datingTypeWaiwei;
    final subtitle = isLoufeng ? '真实认证 · 品质保障' : '高端资源 · 品质体验';
    return GestureDetector(
      onTap: () => onChanged(item.value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40.w,
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFAF4BFB),
                    Color(0xFF900BF5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: selected
              ? [
                  const BoxShadow(
                    color: Color(0xFFCB85FF),
                    blurRadius: 2.9,
                    offset: Offset(-1, -1),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon.image(width: 15.w, height: 15.w, fit: BoxFit.contain),
                SizedBox(width: 8.w),
                Text(
                  item.label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFFCFD5DD),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.w),
            Text(
              subtitle,
              style: TextStyle(
                color: selected
                    ? Colors.white.withOpacity(.6)
                    : const Color(0xFFA7ABB5),
                fontSize: 8.sp,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 省 / 市筛选：横向省份 + 可展开的城市面板（Figma 261:29992 / 261:30011）。
class DatingRegionFilter extends StatelessWidget {
  const DatingRegionFilter({
    super.key,
    required this.regions,
    required this.selectedProvinceId,
    required this.selectedCityId,
    // required this.provinceListExpanded,
    required this.cityPanelOpen,
    required this.panelProvinceId,
    // required this.onToggleProvinceList,
    required this.onSelectAll,
    required this.onSelectProvince,
    required this.onSelectCityInPanel,
    required this.onSelectAllCitiesInPanel,
    required this.onCollapseCityPanel,
  });

  final List<DatingRegionNode> regions;
  final int? selectedProvinceId;
  final int? selectedCityId;

  /// 省份横向列表是否展示全部（否则仅前 6 个 + 展开入口）
  // final bool provinceListExpanded;

  /// 城市面板是否展开；收起时不渲染面板
  final bool cityPanelOpen;

  /// 当前绑定城市面板的省 id（用于箭头态，可与 [selectedProvinceId] 并存）
  final int? panelProvinceId;
  // final VoidCallback onToggleProvinceList;
  final VoidCallback onSelectAll;
  final ValueChanged<DatingRegionNode> onSelectProvince;
  final ValueChanged<DatingRegionNode> onSelectCityInPanel;
  final VoidCallback onSelectAllCitiesInPanel;
  final VoidCallback onCollapseCityPanel;

  static const Color _themeRed = AppColor.primaryButtonColor;

  @override
  Widget build(BuildContext context) {
    final visibleProvinces = regions;

    DatingRegionNode? panelProvince;
    if (panelProvinceId != null) {
      for (final r in regions) {
        if (r.id == panelProvinceId) {
          panelProvince = r;
          break;
        }
      }
    }

    final showCityPanel = cityPanelOpen &&
        panelProvince != null &&
        panelProvince.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 28.w,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16.w),
            itemCount: visibleProvinces.length + 1,
            separatorBuilder: (_, __) => SizedBox(width: 6.w),
            itemBuilder: (context, index) {
              if (index == 0) {
                final selected =
                    selectedProvinceId == null && selectedCityId == null;
                return _provinceChip(
                  label: '全部',
                  selected: selected,
                  onTap: onSelectAll,
                );
              }
              final node = visibleProvinces[index - 1];
              final hasCities = node.children.isNotEmpty;
              final isPanelTarget = panelProvinceId == node.id;
              final arrowUp = isPanelTarget && cityPanelOpen;
              final showArrow = hasCities && isPanelTarget;
              final selected =
                  selectedProvinceId == node.id && selectedCityId == null;
              return _provinceChip(
                label: node.name,
                selected: selected,
                showArrow: showArrow,
                arrowPointsUp: arrowUp,
                onTap: () => onSelectProvince(node),
              );
            },
          ),
        ),
        if (showCityPanel) ...[
          SizedBox(height: 8.w),
          _CityDistrictPanel(
            province: panelProvince,
            selectedCityId: selectedCityId,
            onSelectAllCities: onSelectAllCitiesInPanel,
            onSelectCity: onSelectCityInPanel,
            onCollapse: onCollapseCityPanel,
          ),
        ],
        // if (regions.length > 6 && !showCityPanel)
        //   Align(
        //     alignment: Alignment.centerRight,
        //     child: Padding(
        //       padding: EdgeInsets.only(right: 16.w, top: 4.w),
        //       child: GestureDetector(
        //         onTap: onToggleProvinceList,
        //         child: Text(
        //           provinceListExpanded ? '收起' : '展开',
        //           style: TextStyle(
        //             color: Colors.white.withOpacity(0.5),
        //             fontSize: 12.sp,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _provinceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool showArrow = false,
    bool arrowPointsUp = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
        decoration: BoxDecoration(
          color: selected ? _themeRed : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12.sp,
                height: 1,
                letterSpacing: 0.72,
              ),
            ),
            if (showArrow) ...[
              SizedBox(width: 2.w),
              Transform.rotate(
                angle: arrowPointsUp ? 3.1415926535 : 0,
                child: AssetsGen.images.dating.datingRegionArrow.image(
                  width: 10.w,
                  height: 10.w,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CityDistrictPanel extends StatelessWidget {
  const _CityDistrictPanel({
    required this.province,
    required this.selectedCityId,
    required this.onSelectAllCities,
    required this.onSelectCity,
    required this.onCollapse,
  });

  final DatingRegionNode province;
  final int? selectedCityId;
  final VoidCallback onSelectAllCities;
  final ValueChanged<DatingRegionNode> onSelectCity;
  final VoidCallback onCollapse;

  static const Color _themeRed = AppColor.primaryButtonColor;

  @override
  Widget build(BuildContext context) {
    final cities = province.children;
    final allCitiesSelected = selectedCityId == null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AssetsGen.images.dating.datingIconLocationRed.image(
                  width: 14.w,
                  height: 14.w,
                ),
                SizedBox(width: 6.w),
                Text(
                  province.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  '选择区域，发现更多优质资源',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.w),
            _cityGrid(
              cities: cities,
              allSelected: allCitiesSelected,
              onSelectAllCities: onSelectAllCities,
              onSelectCity: onSelectCity,
            ),
            SizedBox(height: 12.w),
            GestureDetector(
              onTap: onCollapse,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: 3.1415926535,
                    child: AssetsGen.images.dating.datingRegionArrow.image(
                      width: 10.w,
                      height: 10.w,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '收起',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12.sp,
                      letterSpacing: 0.72,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cityGrid({
    required List<DatingRegionNode> cities,
    required bool allSelected,
    required VoidCallback onSelectAllCities,
    required ValueChanged<DatingRegionNode> onSelectCity,
  }) {
    const crossAxisCount = 3;
    const gap = 4.0;
    final cells = <Widget>[
      _cityCell(label: '全部', selected: allSelected, onTap: onSelectAllCities),
      ...cities.map(
        (c) => _cityCell(
          label: c.name,
          selected: selectedCityId == c.id,
          onTap: () => onSelectCity(c),
        ),
      ),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += crossAxisCount) {
      final chunk = cells.sublist(
        i,
        i + crossAxisCount > cells.length ? cells.length : i + crossAxisCount,
      );
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: gap.w),
          child: Row(
            children: [
              for (var j = 0; j < chunk.length; j++) ...[
                if (j > 0) SizedBox(width: gap.w),
                Expanded(child: chunk[j]),
              ],
              for (var j = chunk.length; j < crossAxisCount; j++) ...[
                SizedBox(width: gap.w),
                const Expanded(child: SizedBox.shrink()),
              ],
            ],
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _cityCell({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? _themeRed.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(7.r),
          border: selected ? Border.all(color: _themeRed, width: 1) : null,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected
                ? AppColor.primaryButtonColor
                : Colors.white.withOpacity(0.8),
            fontSize: 12.sp,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class DatingSortTabs extends StatelessWidget {
  const DatingSortTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final DatingSortType selected;
  final ValueChanged<DatingSortType> onChanged;

  static const List<({DatingSortType type, String label})> _options = [
    (type: DatingSortType.latest, label: '最新发布'),
    (type: DatingSortType.weekHot, label: '本周热门'),
    (type: DatingSortType.monthHot, label: '本月热门'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: _options.map((e) {
          final sel = e.type == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.type),
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: sel
                    ? BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [
                              Color(0x00F5850B),
                              Color(0x1CF5850B),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.circular(8.r),
                      )
                    : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e.label,
                      style: TextStyle(
                        color: sel
                            ? AppColor.primaryButtonColor
                            : const Color(0xFFE8E8E9),
                        fontSize: 14.sp,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 6.w),
                    Container(
                      width: 24.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColor.primaryButtonColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
