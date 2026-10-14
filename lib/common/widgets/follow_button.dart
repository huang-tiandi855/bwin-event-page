import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class FollowButton extends StatelessWidget {
  final bool? isFollow;
  final bool? isLoading;
  final bool? isCollectStyle;
  final Color? bgColor;
  const FollowButton({
    super.key,
    this.isFollow,
    this.isLoading,
    this.isCollectStyle,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isFollow == true) {


    return  SizedBox(
        width: 63,
        height: 26,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 63,
                height: 26,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: const Color.fromRGBO(245, 245, 245, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isCollectStyle == true ? "已收藏": "已关注",
                  style: const TextStyle(
                    color: Color.fromRGBO(153, 153, 153, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

     /* return Container(
        width: 63.w,
        height: 26.w,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
            color: const Color(0x30F5F5F5),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: Colors.white.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(10),
            )),
        child: (isLoading == true)
            ? _loadingWidget()
            :  Text(isCollectStyle == true ? "已收藏": "已关注",
                style: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12,
                  fontFamily: 'Dream',
                  fontWeight: FontWeight.w900,
                ),
              ),
      );*/
    }
    if(bgColor != null){
      return _buildHasBgColorStyle();
    }
    return _buildNormalStyle();
  }

  Widget _buildHasBgColorStyle() {
    return Container(
      width: 63,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
      ),
      child: (isLoading == true)
          ? _loadingWidget()
          : Container(
              decoration: ShapeDecoration(
                color: Colors.white,
                shadows: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isCollectStyle == true ? "收藏" : "关注",
                style: const TextStyle(
                  color: Color(0xFFB09FD9),
                  fontSize: 12,
                  fontFamily: 'Dream',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
    );
  }

  Widget _buildNormalStyle() {
    return Container(
      width: 63.w,
      height: 26.w,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: Colors.white,
        shadows: [
          BoxShadow(
            color: const Color(0xff000000).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        isCollectStyle == true ? "收藏" : "关注",
        style: const TextStyle(
          color: Color(0xFFB09FD9),
          fontSize: 12,
          fontFamily: 'Dream',
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _loadingWidget() {
    return const CupertinoActivityIndicator(
      color: Colors.white,
      radius: 8,
    );
  }
}
