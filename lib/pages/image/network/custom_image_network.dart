import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:comics_app/common/http/http_detect_line_dio.dart';
import 'package:comics_app/common/values/config.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'decrypt_image.dart';
import 'image_cache_manager.dart';
import 'network_image_urls.dart';

/// 带解密的统一网络图（CDN 相对路径拼接 + 与 Web 一致的 XOR / 旧协议解码）。
///
/// - **Web**：Dio 拉字节 → [decryptImage] → [Image.memory]
/// - **iOS/Android**：[CachedNetworkImage] + [ImgCacheMgr] 在下载管线中调用同一 [decryptImage]
class CustomImage extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? loadingAndErrorWidget;
  final BorderRadius? borderRadius;
  final bool widthAndHeightAdaptive;
  final bool? isCache;
  final Color? colorFliter;
  final List<BoxShadow>? boxShadow;
  final double? aspectRatio;

  const CustomImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.loadingAndErrorWidget,
    this.borderRadius,
    this.fit,
    this.isCache,
    this.colorFliter,
    this.aspectRatio,
    this.boxShadow,
    this.widthAndHeightAdaptive = false,
  }) : super(key: key);

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage>
    with AutomaticKeepAliveClientMixin {
  static const bool kIsWeb = identical(0, 0.0);

  Uint8List? _webDecoded;
  bool _webError = false;

  @override
  bool get wantKeepAlive => kIsWeb && (widget.isCache ?? false);

  @override
  void initState() {
    super.initState();
    FBroadcast.instance()
        .register(Config.SWITCH_PICTURE_LINE, _onPictureLineSwitched);
    if (kIsWeb) {
      _loadWebImage();
    }
  }

  @override
  void didUpdateWidget(CustomImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kIsWeb && oldWidget.url != widget.url) {
      _loadWebImage();
    }
  }

  @override
  void dispose() {
    FBroadcast.instance()
        .remove(_onPictureLineSwitched, key: Config.SWITCH_PICTURE_LINE);
    super.dispose();
  }

  void _onPictureLineSwitched(dynamic context, dynamic value) {
    if (!mounted) return;
    if (kIsWeb) {
      _loadWebImage();
    } else {
      setState(() {});
    }
  }

  Future<void> _loadWebImage() async {
    setState(() {
      _webError = false;
      _webDecoded = null;
    });
    final String? raw = widget.url;
    if (raw == null || raw.isEmpty) {
      setState(() => _webError = true);
      return;
    }
    final String url = resolveCdnImageUrl(raw);
    if (url.isEmpty) {
      setState(() => _webError = true);
      return;
    }
    try {
      final Dio dio = createDio(
        options: BaseOptions(
          connectTimeout: 15000,
          receiveTimeout: 15000,
          sendTimeout: 15000,
        ),
      );
      final resp = await dio.request(
        url,
        options: Options(responseType: ResponseType.bytes, method: 'GET'),
      );
      final Uint8List decoded = decryptImage(resp.data as Uint8List);
      if (mounted) {
        setState(() {
          _webDecoded = decoded;
          _webError = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _webError = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.url == null || widget.url!.isEmpty) {
      return defaultLoadingAndError(
          widget.width, widget.height, widget.borderRadius);
    }

    if (kIsWeb) {
      if (_webDecoded != null) {
        return ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: Image.memory(
            _webDecoded!,
            width: widget.widthAndHeightAdaptive ? null : widget.width,
            height: widget.widthAndHeightAdaptive ? null : widget.height,
            fit: widget.fit ?? BoxFit.fitWidth,
          ),
        );
      }
      if (_webError) {
        return widget.loadingAndErrorWidget ??
            defaultLoadingAndError(
                widget.width, widget.height, widget.borderRadius);
      }
      return widget.loadingAndErrorWidget ??
          defaultLoadingAndError(
              widget.width, widget.height, widget.borderRadius);
    }

    return widget.aspectRatio != null
        ? AspectRatio(
            aspectRatio: widget.aspectRatio!,
            child: CustomImageNetwork(
              imageUrl: widget.url,
              placeholder: widget.loadingAndErrorWidget,
              borderRadius: widget.borderRadius,
              fit: widget.fit ?? BoxFit.fill,
              colorFliter: widget.colorFliter,
              boxShadow: widget.boxShadow,
              widthAndHeightAdaptive: widget.widthAndHeightAdaptive,
            ),
          )
        : CustomImageNetwork(
            imageUrl: widget.url,
            width: widget.width ?? double.infinity,
            height: widget.height ?? double.infinity,
            placeholder: widget.loadingAndErrorWidget,
            borderRadius: widget.borderRadius,
            fit: widget.fit,
            boxShadow: widget.boxShadow,
            colorFliter: widget.colorFliter,
            widthAndHeightAdaptive: widget.widthAndHeightAdaptive,
          );
  }
}

class CustomImageNetwork extends CachedNetworkImage {
  CustomImageNetwork({
    Key? key,
    required String? imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    BorderRadius? borderRadius,
    Color? colorFliter,
    List<BoxShadow>? boxShadow,
    required bool widthAndHeightAdaptive,
  }) : super(
          key: key,
          cacheManager: ImgCacheMgr(),
          imageUrl: resolveCdnImageUrl(imageUrl ?? ''),
          fit: fit ?? BoxFit.cover,
          imageBuilder: widthAndHeightAdaptive
              ? null
              : (context, imageProvider) => Container(
                    width: width ?? double.infinity,
                    height: height ?? double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      image: colorFliter == null
                          ? DecorationImage(
                              image: imageProvider,
                              fit: fit ?? BoxFit.cover,
                            )
                          : DecorationImage(
                              image: imageProvider,
                              fit: fit ?? BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                colorFliter,
                                BlendMode.srcOver,
                              ),
                            ),
                      boxShadow: boxShadow,
                    ),
                  ),
          placeholder: (context, url) =>
              placeholder ??
              defaultLoadingAndError(width, height, borderRadius),
          errorWidget: (context, url, error) =>
              placeholder ??
              defaultLoadingAndError(width, height, borderRadius),
        );
}

Widget defaultLoadingAndError(
    double? width, double? height, BorderRadius? borderRadius) {
  return ClipRRect(
    borderRadius: borderRadius ?? BorderRadius.zero,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double resolvedWidth =
            (width != null && width.isFinite) ? width : constraints.maxWidth;
        final double resolvedHeight = (height != null && height.isFinite)
            ? height
            : constraints.hasBoundedHeight
                ? constraints.maxHeight
                : resolvedWidth.isFinite
                    ? resolvedWidth * 9 / 16
                    : 200;
        return SizedBox(
          width: resolvedWidth.isFinite ? resolvedWidth : null,
          height: resolvedHeight.isFinite ? resolvedHeight : null,
          child: AssetsGen.images.app.placeHolderImage.image(fit: BoxFit.cover),
        );
      },
    ),
  );
}

/// 与 [resolveCdnImageUrl] 相同，保留旧调用处导入路径兼容。
String getPath(dynamic url) => resolveCdnImageUrl(url?.toString());
