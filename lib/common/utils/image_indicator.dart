

import 'dart:math';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class ImageIndicator extends StatefulWidget {

  final PageController controller;
  final List<String> titleArr;
  const ImageIndicator({super.key, required this.controller, required this.titleArr,});

  @override
  State<StatefulWidget> createState() {
    return _ImageIndicatorState();
  }
}

class _ImageIndicatorState extends State<ImageIndicator> {


  int get currentPage {
    int index = 1;
    if (widget.controller.hasClients == true) {
      index = (widget.controller.offset + 100) ~/ ScreenUtil().screenWidth;
    }
    index = min(index, widget.titleArr.length);
    return index;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listen);
  }

  void _listen() {
    if(mounted){
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> widgetArr = [];
    for(int i = 0; i < widget.titleArr.length; i++){
      widgetArr.add(_buildMenuButton(widget.titleArr[i], currentPage == i, i));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 6, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widgetArr,
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, bool isSelected, int index) {
    return InkWell(
      onTap: () {
       widget.controller.jumpToPage(index);
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 3),
        margin: const EdgeInsets.fromLTRB(4, 0, 4, 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff262626) : null,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xff999999),
          ),
        ),
      ),
    );
  }
}