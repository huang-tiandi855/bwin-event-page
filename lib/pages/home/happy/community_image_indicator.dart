import 'package:flutter/material.dart';

class CommunityImageIndicator extends StatefulWidget {

  final TabController? controller;
  final List<String>? titleArr;
  //final CommunityData? localData;
  const CommunityImageIndicator({super.key, @required this.controller, @required this.titleArr, /*this.localData,*/});

  @override
  State<StatefulWidget> createState() {
    return _CommunityImageIndicatorState();
  }
}

class _CommunityImageIndicatorState extends State<CommunityImageIndicator> {


  int? get currentPage {
    int? index = widget.controller?.index;
    return index;
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_listen);
  }

  void _listen() {
    if(mounted){
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_listen);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> widgetArr = [];
    for(int i = 0; i < widget.titleArr!.length; i++){
      widgetArr.add(_buildMenuButton(widget.titleArr![i], currentPage == i, i));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widgetArr,
      ),
    );
  }

  Widget _buildMenuButton(String text, bool isSelected, int index) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
       widget.controller?.index = index;
      // widget.localData?.setTabIndex(index);
       setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: isSelected ? 20 : 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ?  const Color.fromRGBO(51, 51, 51, 1) : const Color.fromRGBO(51, 51, 51, 1),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: 22,
              height: 4,
              child: isSelected ? Image.asset("assets/images/png/tab_indicator.png") : null,
            ),
          ],
        ),
      ),
    );
  }
}