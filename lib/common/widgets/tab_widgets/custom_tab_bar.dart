import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

typedef OnTapCallback = void Function(int index);

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({
    Key? key,
    required this.tabs,
    required this.controller,
    this.imagePath,
    this.isScrollable,
    this.labelColor,
    this.labelStyle,
    this.tabAlignment,
    this.unselectedLabelColor,
    this.unselectedLabelStyle,
    this.callback,
    this.labelPadding,
    this.indicatorPadding,
  }) : super(key: key);

  final List<Widget> tabs;
  final TabController controller;
  final String? imagePath;
  final bool? isScrollable;
  final Color? labelColor;
  final TextStyle? labelStyle;
  final Color? unselectedLabelColor;
  final TextStyle? unselectedLabelStyle;
  final OnTapCallback? callback;
  final EdgeInsets? labelPadding;
  final TabAlignment? tabAlignment;
  final EdgeInsets? indicatorPadding;
  @override
  State<StatefulWidget> createState() {
    return _CustomTabBarState();
  }
}

class _CustomTabBarState extends State<CustomTabBar> {
  ui.Image? _image;

  Future<ui.Image> loadImage(String path) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePath?.isNotEmpty == true) {
      loadImage(widget.imagePath!).then(
        (value) {
          if (mounted) {
            setState(
              () {
                _image = value;
              },
            );
          }
        },
      );
    }
    return TabBar(
      tabs: widget.tabs,
      isScrollable: widget.isScrollable ?? true,
      controller: widget.controller,
      tabAlignment: widget.tabAlignment,
      indicator: _image == null
          ? const BoxDecoration()
          : ImageTabIndicator(image: _image),
      labelColor: widget.labelColor,
      labelStyle: widget.labelStyle,
      indicatorColor: Colors.transparent,
      indicatorPadding:
          widget.indicatorPadding ?? const EdgeInsets.only(top: 8),
      indicatorWeight: 8,
      unselectedLabelColor: widget.unselectedLabelColor,
      unselectedLabelStyle: widget.unselectedLabelStyle,
      labelPadding: widget.labelPadding,
      onTap: (index) {
        widget.callback?.call(index);
      },
    );
  }
}

class ImageTabIndicator extends Decoration {
  final BoxPainter _painter;

  ImageTabIndicator({double radius = 10, ui.Image? image})
      : _painter = _ImagePainter(radius, image);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _ImagePainter extends BoxPainter {
  final double radius;
  final ui.Image? image;

  _ImagePainter(this.radius, this.image);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    if (image != null) {
      final Offset imageOffset = offset +
          Offset((cfg.size?.width ?? 0) / 2,
              (cfg.size?.height ?? 0) / 2 + (image?.height ?? 0) + 2);
      paintImage(
          canvas: canvas,
          rect: Rect.fromCircle(center: imageOffset, radius: radius),
          image: image!,
          fit: BoxFit.fitWidth);
    }
  }
}
