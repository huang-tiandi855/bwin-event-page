import 'dart:math';

import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class StackPageView extends StatefulWidget {
  final List<String> imgUrls;
  Function(int index) indexOnchanged;
  final double verticalInset;
  final double aspectRatio;
  StackPageView(this.imgUrls, {super.key, required this.indexOnchanged,this.verticalInset = 5.0,this.aspectRatio = 304/170});

  @override
  State<StackPageView> createState() => _StackPageViewState();
}

class _StackPageViewState extends State<StackPageView> {
  double currentPage = 0.0;
  late PageController controller;

  @override
  void initState() {
    currentPage = widget.imgUrls.length - 1;
    controller = PageController(initialPage: currentPage.toInt());
    controller.addListener(() {
      setState(() {
        currentPage = controller.page ?? 0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      // 两者堆叠在一起。通过PageView滑动的Controller来控制当前显示的page
      CardScrollWidget(
        currentPage,
        widget.imgUrls,
        verticalInset: widget.verticalInset,
        aspectRatio: widget.aspectRatio,
      ),
      Positioned.fill(
          child: PageView.builder(
            itemCount: widget.imgUrls.length,
            controller: controller,
            reverse: true,
            onPageChanged: (index) => widget.indexOnchanged(index),
            itemBuilder: (context, index) {
              return Container(

              );
            },
          )),
    ]);
  }
}

class CardScrollWidget extends StatelessWidget {
  final double currentPage;
  final padding = 0.5;
  final double verticalInset;
  final List<String> urls;
  final double aspectRatio;
  const CardScrollWidget(this.currentPage, this.urls, {this.verticalInset = 5.0,this.aspectRatio = 302 / 170, super.key});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio * 1.2,
      child: LayoutBuilder(
        builder: (context, contraints) {
          var width = contraints.maxWidth;
          var height = contraints.maxHeight;
          var safeWidth = width - 2 * padding;
          var safeHeight = height - 2 * padding;
          var heightOfPrimaryCard = safeHeight;
          var widthOfPrimaryCard = heightOfPrimaryCard * aspectRatio;
          var primaryCardLeft = safeWidth - widthOfPrimaryCard;
          var horizontalInset = primaryCardLeft / 2;
          List<Widget> cardList = [];
          for (var i = 0; i < urls.length; i++) {
            var leftPage = i - currentPage;
            bool isOnRight = leftPage > 0;
            var start = padding + max(primaryCardLeft - horizontalInset * -leftPage * (isOnRight ? 50 : 1), 0);
            var cardItem = Positioned.directional(
              top: padding + verticalInset * max(-leftPage, 0.0),
              bottom: padding + verticalInset * max(-leftPage, 0.0),
              start: start,
              textDirection: TextDirection.rtl,
              child: ClipRRect(
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Stack(alignment: Alignment.center, children: [
                    CustomImage(url: urls[i], width: safeWidth),
                    SvgPicture.asset(
                      'assets/images/nut/post_play.svg',
                      width: 30,
                      height: 30,
                    ),
                  ]),
                ),
              ),
            );
            cardList.add(cardItem);
          }
          return Stack(
            children: cardList,
          );
        },
      ),
    );
  }
}
