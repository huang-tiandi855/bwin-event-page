import 'dart:async';

import 'package:comics_app/common/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///手机验证码倒计时
class TimerCountDownWidget extends StatefulWidget {
  final Function onTimerFinish;
  final Function onTimerStart;
  final bool startTimer;

  const TimerCountDownWidget(
      {Key? key,
      required this.startTimer,
      required this.onTimerStart,
      required this.onTimerFinish})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TimerCountDownWidgetState();
}

class TimerCountDownWidgetState extends State<TimerCountDownWidget> {
  Timer? _timer;
  int _countdownTime = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_countdownTime == 0) {
          widget.onTimerStart();
          setState(() {
            _countdownTime = 60;
          });
          //开始倒计时
          startCountdownTimer();
        }
      },
      child: Text(
        _getTimeText(),
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: AppColor.primaryColor,
        ),
      ),
    );
  }

  ///获取倒计时时间
  String _getTimeText() {
    if (widget.startTimer) {
      return _countdownTime > 0 ? '$_countdownTime秒后重新获取' : '获取验证码';
    } else {
      _countdownTime = 0;
      if (_timer != null) {
        _timer?.cancel();
      }
      setState(() {});
      return '获取验证码';
    }
  }

  void startCountdownTimer() {
    _timer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) => setState(() {
                if (_countdownTime < 1) {
                  widget.onTimerFinish();
                  _timer?.cancel();
                } else {
                  _countdownTime = _countdownTime - 1;
                }
              })
            );
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer?.cancel();
    }
  }
}
