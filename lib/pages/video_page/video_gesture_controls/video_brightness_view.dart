import 'package:comics_app/common/res/r.dart';
import 'package:flutter/material.dart';

class VideoBrightnessView extends StatelessWidget {
  const VideoBrightnessView({
    super.key,
    this.brightness = 0,
  });

  final double brightness;

  IconData get icon {
    if (brightness > 0.7) {
      return Icons.brightness_high_rounded;
    } else if (brightness > 0.3) {
      return Icons.brightness_medium_rounded;
    } else {
      return Icons.brightness_low_rounded;
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
              R.brightness,
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
                    value: brightness,
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
