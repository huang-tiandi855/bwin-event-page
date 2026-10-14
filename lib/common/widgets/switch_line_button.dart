import 'dart:math';

import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/debug_log.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/common/widgets/popup_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwitchLineButton extends StatelessWidget {
  const SwitchLineButton({
    super.key,
    this.buttonBuilder,
    this.callback,
    this.useH5PlayLines = false,
    this.offset = Offset.zero,
    this.useBottomSheet = false,
  });

  final WidgetBuilder? buttonBuilder;

  final Function(String?)? callback;

  final bool useH5PlayLines;

  final Offset offset;

  final bool useBottomSheet;

  @override
  Widget build(BuildContext context) {
    final int lineCount = _lineCount();
    if (useBottomSheet) {
      return InkWell(
        onTap: () => _showBottomSheet(context, lineCount),
        child: buttonBuilder?.call(context),
      );
    }

    return PopupWindowButton(
      offset: offset,
      buttonBuilder: buttonBuilder,
      windowBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 100.w,
                      height: min(90.w, 30.w * max(lineCount, 1)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: lineCount == 0
                            ? Center(
                                child: Text(
                                  '暂无线路',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xff333333),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: lineCount,
                                itemBuilder: (context, index) {
                                  final String lineName = _lineNameAt(index);
                                  return GestureDetector(
                                    onTap: () async {
                                      _applyLineAt(index);
                                      callback?.call(_selectedLineValue());
                                      // setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                    child: SizedBox(
                                      height: 30.w,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 6.w),
                                              child: Text(
                                                lineName,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color:
                                                      const Color(0xff333333),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 12.w),
                                            height: 1,
                                            color:
                                                Colors.black.withOpacity(0.01),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                )),
          ),
        );
      },
      onWindowShow: () {
        debugLog('PopupWindowButton window show');
      },
      onWindowDismiss: () {
        debugLog('PopupWindowButton window dismiss');
        /* if (widget.callback != null) {
                        widget.callback(selectedType, selectedSort);
                      }*/
      },
    );
  }

  void _showBottomSheet(BuildContext context, int lineCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (context) {
        return Container(
          width: 1.sw,
          padding: EdgeInsets.only(top: 12.w, bottom: 28.w),
          decoration: BoxDecoration(
            color: const Color(0xFF061C1B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.w)),
          ),
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
              18.w.verticalSpace,
              if (lineCount == 0)
                SizedBox(
                  height: 48.w,
                  child: Center(
                    child: Text(
                      '暂无可用线路',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(lineCount, (index) {
                  final String lineName = _lineNameAt(index);
                  final String? selectedLine = _selectedLineValue();
                  final String? currentLine = _lineValueAt(index);
                  final bool isSelected =
                      selectedLine != null && selectedLine == currentLine;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _applyLineAt(index);
                      callback?.call(_selectedLineValue());
                      Navigator.of(context).pop();
                    },
                    child: SizedBox(
                      height: 48.w,
                      child: Center(
                        child: Text(
                          lineName,
                          style: TextStyle(
                            color: isSelected
                                ? AppColor.primaryButtonColor
                                : Colors.white,
                            fontSize: 16.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
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

  int _lineCount() {
    if (useH5PlayLines) return Address.h5PlayLines?.length ?? 0;
    return Address.cdnAddressLists.length;
  }

  String _lineNameAt(int index) {
    if (useH5PlayLines) {
      return Address.h5PlayLines?[index].name ?? '线路${index + 1}';
    }
    return Address.cdnAddressLists[index].desc.toString();
  }

  String? _lineValueAt(int index) {
    if (useH5PlayLines) {
      return Address.h5PlayLines?[index].line?.trim();
    }
    return Address.cdnAddressLists[index].url;
  }

  String? _selectedLineValue() {
    return Address.h5PlayLine?.trim();
  }

  void _applyLineAt(int index) {
    Address.h5PlayLine = _lineValueAt(index);
  }
}
