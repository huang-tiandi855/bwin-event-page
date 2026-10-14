import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/res/r.dart';

class BatteryView extends StatefulWidget {
  final Color bottomOverlayerColor;

  const BatteryView({Key? key, required this.bottomOverlayerColor})
      : super(key: key);

  @override
  State<BatteryView> createState() => _BatteryViewState();
}

class _BatteryViewState extends State<BatteryView> {
  int batteryLevel = 0;

  @override
  void initState() {
    super.initState();
    getBatteryLevel();
  }

  getBatteryLevel() async {
    int level = await Battery().batteryLevel;
    setState(() {
      batteryLevel = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(R.battery,
            width: 24.w, color: widget.bottomOverlayerColor),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 0.5.w),
          child: Text("$batteryLevel",
              style: TextStyle(
                  color: widget.bottomOverlayerColor, fontSize: 10.sp)),
        )
      ],
    );
  }
}
