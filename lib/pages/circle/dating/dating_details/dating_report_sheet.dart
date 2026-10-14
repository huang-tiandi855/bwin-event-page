import 'package:comics_app/common/entities/circle/dating_models.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DatingReportSheetResult {
  const DatingReportSheetResult({
    required this.type,
    this.content,
  });

  final int type;
  final String? content;
}

class _ReportOptionUi {
  const _ReportOptionUi({
    required this.subtitle,
    this.asset,
  });

  final String subtitle;
  final AssetGenImage? asset;
}

_ReportOptionUi _reportUiFor(DatingDictItem item) {
  switch (item.value) {
    case 0:
      return _ReportOptionUi(
        asset: AssetsGen.images.dating.datingIconDes,
        subtitle: '发布不实信息，存在虚假内容',
      );
    case 1:
      return _ReportOptionUi(
        asset: AssetsGen.images.dating.datingIconImg,
        subtitle: '照片疑似盗用或与本人不符',
      );
    case 2:
      return _ReportOptionUi(
        asset: AssetsGen.images.dating.datingIconLie,
        subtitle: '疑似诈骗、诱导交易等风险行为',
      );
    case 3:
      return _ReportOptionUi(
        asset: AssetsGen.images.dating.datingIconPolice,
        subtitle: '包含违法、违规或不良内容',
      );
    case 4:
      return _ReportOptionUi(
        asset: AssetsGen.images.dating.datingIconMore,
        subtitle: '其他原因',
      );
    default:
      return const _ReportOptionUi(subtitle: '');
  }
}

Future<DatingReportSheetResult?> showDatingReportSheet(
  BuildContext context, {
  required List<DatingDictItem> types,
}) {
  return showModalBottomSheet<DatingReportSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0xB2181818),
    builder: (ctx) => _DatingReportSheet(types: types),
  );
}

class _DatingReportSheet extends StatefulWidget {
  const _DatingReportSheet({required this.types});

  final List<DatingDictItem> types;

  @override
  State<_DatingReportSheet> createState() => _DatingReportSheetState();
}

class _DatingReportSheetState extends State<_DatingReportSheet> {
  int? _selectedType;
  final TextEditingController _contentController = TextEditingController();

  static const _selectedBorder = Color(0xFFFF3B30);
  static const _selectedFill = Color(0x1AFF3B30);

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColor.scaffoldBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom > 0 ? 0 : 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40.w,
                child: Center(
                  child: Container(
                    width: 34.w,
                    height: 5.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.w, 16.w, 40.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '举报原因',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4.w),
                          Text(
                            '请选择最符合的举报类型',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.w),
                    ...widget.types.map(_optionTile),
                    if (_selectedType == DatingReportType.other.value) ...[
                      SizedBox(height: 8.w),
                      TextField(
                        controller: _contentController,
                        maxLines: 3,
                        maxLength: 200,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: '请补充说明（选填）',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 12.sp,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(
                              color: _selectedBorder,
                            ),
                          ),
                          counterStyle: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 16.w),
                    SizedBox(
                      height: 40.w,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColor.primaryButtonColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColor.primaryButtonColor.withOpacity(0.4),
                          disabledForegroundColor:
                              Colors.white.withOpacity(0.6),
                          padding: EdgeInsets.zero,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: _selectedType == null ? null : _submit,
                        child: Text(
                          '提交举报',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.w),
                    SizedBox(
                      height: 40.w,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionTile(DatingDictItem item) {
    final selected = _selectedType == item.value;
    final ui = _reportUiFor(item);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedType = item.value),
          borderRadius: BorderRadius.circular(8.r),
          child: Ink(
            decoration: BoxDecoration(
              color: selected ? _selectedFill : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color:
                    selected ? _selectedBorder : Colors.white.withOpacity(0.3),
                width: selected ? 1 : 0.5,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
            child: Row(
              children: [
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: _leadingIcon(ui, selected),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (ui.subtitle.isNotEmpty) ...[
                        SizedBox(height: 4.w),
                        Text(
                          ui.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                _radio(selected),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _leadingIcon(_ReportOptionUi ui, bool selected) {
    final color = selected ? _selectedBorder : Colors.white.withOpacity(0.85);
    if (ui.asset != null) {
      return ui.asset!.image(width: 24.w, height: 24.w, color: color);
    }

    return const SizedBox.shrink();
  }

  Widget _radio(bool selected) {
    if (selected) {
      return Icon(
        Icons.radio_button_checked,
        size: 18.w,
        color: _selectedBorder,
      );
    }
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
    );
  }

  void _submit() {
    final type = _selectedType;
    if (type == null) return;
    final content = _contentController.text.trim();
    Navigator.of(context).pop(
      DatingReportSheetResult(
        type: type,
        content: content.isEmpty ? null : content,
      ),
    );
  }
}
