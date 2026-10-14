import 'package:flutter/material.dart';

class VideoSkipView extends StatelessWidget {
  const VideoSkipView({
    super.key,
    this.isFullScreen = false,
    this.value = 0,
  });

  final int value;
  final bool isFullScreen;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: value == 1 ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.horizontal(
            left: value == -1
                ? const Radius.circular(0)
                : Radius.circular(isFullScreen ? 18 : 8),
            right: value == -1
                ? Radius.circular(isFullScreen ? 18 : 8)
                : const Radius.circular(0),
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: isFullScreen ? 60 : 20,
          horizontal: isFullScreen ? 30 : 15,
        ).copyWith(
          left: value == -1 && isFullScreen ? 100 : null,
          right: value == 1 && isFullScreen ? 100 : null,
        ),
        child: Text(
          value == 1 ? "连续点击快进15秒" : "连续点击快退15秒",
          style: TextStyle(
            color: Colors.white,
            fontSize: isFullScreen ? 16 : 14,
          ),
        ),
      ),
    );
  }
}
