
import 'package:flutter/material.dart';

/// 3×3 图案锁：白/红连线与节点，支持「跨点自动补中间点」
class PatternLock extends StatefulWidget {
  const PatternLock({
    super.key,
    required this.size,
    this.normalColor = Colors.white,
    this.errorColor = const Color(0xFFFE0002),
    this.errorVisual = false,
    this.minCount = 4,
    this.onStart,
    this.onTooShort,
    this.onComplete,
  });

  final double size;
  final Color normalColor;
  final Color errorColor;
  final bool errorVisual;
  final int minCount;
  final VoidCallback? onStart;
  final void Function(int count)? onTooShort;
  final void Function(List<int> path)? onComplete;

  @override
  State<PatternLock> createState() => _PatternLockState();
}

class _PatternLockState extends State<PatternLock> {
  final List<int> _path = [];
  Offset? _finger;

  static Offset _center(int index, double cell, double pad) {
    final row = index ~/ 3;
    final col = index % 3;
    return Offset(pad + col * cell, pad + row * cell);
  }

  static int? _middleBetween(int a, int b) {
    final i = a < b ? a : b;
    final j = a < b ? b : a;
    if (i == 0 && j == 2) return 1;
    if (i == 0 && j == 6) return 3;
    if (i == 0 && j == 8) return 4;
    if (i == 1 && j == 7) return 4;
    if (i == 2 && j == 8) return 5;
    if (i == 2 && j == 6) return 4;
    if (i == 3 && j == 5) return 4;
    if (i == 6 && j == 8) return 7;
    return null;
  }

  void _appendWithMiddle(int next) {
    if (_path.isEmpty) {
      _path.add(next);
      return;
    }
    final last = _path.last;
    if (last == next) return;
    final mid = _middleBetween(last, next);
    if (mid != null && !_path.contains(mid)) {
      _path.add(mid);
    }
    if (!_path.contains(next)) {
      _path.add(next);
    }
  }

  void _hitTest(Offset local) {
    final s = widget.size;
    final pad = s * 0.12;
    final cell = (s - pad * 2) / 2;
    final hitR = s * 0.12;
    for (var i = 0; i < 9; i++) {
      final c = _center(i, cell, pad);
      if ((local - c).distance <= hitR) {
        if (!_path.contains(i)) {
          setState(() {
            _appendWithMiddle(i);
          });
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.errorVisual ? widget.errorColor : widget.normalColor;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) {
          widget.onStart?.call();
          setState(() {
            _path.clear();
            _finger = d.localPosition;
            _hitTest(d.localPosition);
          });
        },
        onPanUpdate: (d) {
          setState(() {
            _finger = d.localPosition;
            _hitTest(d.localPosition);
          });
        },
        onPanEnd: (_) {
          final copy = List<int>.from(_path);
          setState(() {
            _finger = null;
            _path.clear();
          });
          if (copy.isEmpty) return;
          if (copy.length < widget.minCount) {
            widget.onTooShort?.call(copy.length);
            return;
          }
          widget.onComplete?.call(copy);
        },
        onPanCancel: () {
          setState(() {
            _finger = null;
            _path.clear();
          });
        },
        child: CustomPaint(
          painter: _PatternPainter(
            path: List<int>.from(_path),
            finger: _finger,
            lineColor: active,
            dotColor: active,
          ),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter({
    required this.path,
    required this.finger,
    required this.lineColor,
    required this.dotColor,
  });

  final List<int> path;
  final Offset? finger;
  final Color lineColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final pad = s * 0.12;
    final cell = (s - pad * 2) / 2;
    final nodeR = s * 0.09;
    const strokeW = 2.0;

    Offset c(int i) {
      final row = i ~/ 3;
      final col = i % 3;
      return Offset(pad + col * cell, pad + row * cell);
    }

    Paint lineStroke() => Paint()
      ..color = lineColor
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Paint lineFill() => Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final idleRing = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 9; i++) {
      if (!path.contains(i)) {
        canvas.drawCircle(c(i), nodeR, idleRing);
      }
    }

    if (path.isNotEmpty) {
      final pl = <Offset>[];
      for (final i in path) {
        pl.add(c(i));
      }
      if (finger != null) {
        pl.add(finger!);
      }
      final lp = lineStroke();
      for (var i = 0; i < pl.length - 1; i++) {
        canvas.drawLine(pl[i], pl[i + 1], lp);
      }
    }

    for (final i in path) {
      final p = c(i);
      canvas.drawCircle(p, nodeR, lineStroke());
      canvas.drawCircle(p, nodeR * 0.50, lineFill());
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.finger != finger ||
        oldDelegate.lineColor != lineColor;
  }
}
