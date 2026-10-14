import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 时间分隔标签：图示样式 `04/20 03:04:30`，#FFFFFF80 12px / 400
class ChatDateDivider extends StatelessWidget {
  const ChatDateDivider({super.key, required this.timestamp});

  final int timestamp;

  /// 是否需要在两条消息之间插入时间分隔（间隔超过 [gap] 时返回 true）
  static bool shouldInsert(int prev, int curr,
      {Duration gap = const Duration(minutes: 5)}) {
    return (curr - prev).abs() >= gap.inMilliseconds;
  }

  /// 把毫秒时间戳格式化为 `MM/dd HH:mm:ss`
  static String format(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.month)}/${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.w),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
          decoration: BoxDecoration(
            color: const Color(0x80FFFFFF),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            format(timestamp),
            style: TextStyle(
              color: const Color(0x80FFFFFF),
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

/// 仅显示「刚刚」的小标签（用于刚发出的消息）
class ChatJustNowDivider extends StatelessWidget {
  const ChatJustNowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.w),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '刚刚',
            style: TextStyle(
              color: const Color(0x80FFFFFF),
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
