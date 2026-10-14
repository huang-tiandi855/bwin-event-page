import 'dart:async';

import 'package:flutter/material.dart';

class HomeMarqueeTile extends StatefulWidget {
  final List<Widget>? widgets;

  const HomeMarqueeTile({
    Key? key,
    this.widgets,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MarqueeTileState();
  }
}

class _MarqueeTileState extends State<HomeMarqueeTile>
    with SingleTickerProviderStateMixin {
  final GlobalKey _scrollkey = GlobalKey();
  final GlobalKey _contextKey = GlobalKey();

  AnimationController? _controller;
  Animation<Offset>? _animation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(HomeMarqueeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _startAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
      double contentWidth = _contextKey.currentContext?.size?.width ?? 0;
      double scrollWidth = _scrollkey.currentContext?.size?.width ?? 0;
      _calculateAnimation(contentWidth, scrollWidth);
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _stopAnimation() {
    _controller?.stop();
    _timer?.cancel();
  }

  void _calculateAnimation(double contentWidth, double scrollWidth) {
    if (contentWidth <= scrollWidth) {
      _stopAnimation();
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        _timer?.cancel();
      });
      return; // 内容如果一屏内不开启滚动动画
    }
    double rates = 15000; // 动画速率，一屏幕宽度12秒
    double animMilliseconds =
        ((contentWidth - scrollWidth + 50) / scrollWidth) * rates;
    int seconds = animMilliseconds ~/ 1000; // 动画时长
    double endOffset = -(contentWidth - scrollWidth + 50) / contentWidth;
    if (_controller != null) {
      // 更新动画
      _controller?.reset();
      _controller?.forward();
    } else {
      // 创建动画
      _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: seconds),
        animationBehavior: AnimationBehavior.preserve,
      );
      _animation?.removeListener(_animationListen);
      _animation?.removeStatusListener(_animationStatusListen);
      _animation = Tween<Offset>(
        begin: const Offset(0.02, 0.0),
        end: Offset(endOffset, 0.0),
      ).animate(_controller!);
      _animation?.addListener(_animationListen);
      _animation?.addStatusListener(_animationStatusListen);
      _controller?.forward();
    }
  }

  void _animationListen() {
    setState(() {});
  }

  void _animationStatusListen(value) {
    if (value == AnimationStatus.completed) {
      _controller?.reset();
      _controller?.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: _scrollkey,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Center(
        child: FractionalTranslation(
          translation: _animation?.value ?? const Offset(0, 0),
          child: Container(
            key: _contextKey,
            child: Row(
              children: widget.widgets ?? [],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animation?.removeListener(_animationListen);
    _animation?.removeStatusListener(_animationStatusListen);
    _controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
