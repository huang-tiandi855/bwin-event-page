import 'package:flutter/material.dart';
import 'package:chewie/src/helpers/utils.dart';

class VideoSeekTextView extends StatelessWidget {
  const VideoSeekTextView({
    super.key,
    required this.duration,
    this.totalDuration,
  });
  final Duration duration;
  final Duration? totalDuration;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            formatDuration(duration),
            style: const TextStyle(
              color: Color(0xFF246BFD),
              fontSize: 18,
            ),
          ),
          if (totalDuration != null)
            Text(
              ' / ${formatDuration(totalDuration!)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }
}
