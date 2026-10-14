import 'package:comics_app/common/res/r.dart';
import 'package:flutter/material.dart';

class VideoVolumeView extends StatelessWidget {
  const VideoVolumeView({
    super.key,
    this.volume = 0,
  });

  final double volume;

  IconData get icon {
    if (volume > 0.7) {
      return Icons.volume_up_rounded;
    } else if (volume > 0) {
      return Icons.volume_down_rounded;
    } else {
      return Icons.volume_off_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 206,
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.black.withOpacity(0.3),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Image.asset(
              R.volume,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(1),
                child: SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    value: volume,
                    backgroundColor: Colors.white.withOpacity(0.4),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
