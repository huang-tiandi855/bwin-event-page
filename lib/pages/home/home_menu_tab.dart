import 'package:flutter/material.dart';

import '../../generated/assets.dart';

class HomeMenuTab extends StatefulWidget {
  final TabController tabController;

  const HomeMenuTab({super.key, required this.tabController});

  @override
  State<StatefulWidget> createState() {
    return _HomeMenuTabState();
  }
}

class _HomeMenuTabState extends State<HomeMenuTab> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 198,
      height: 32,
      padding: const EdgeInsets.all(2),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
                onTap: () async {
                  widget.tabController.index = 0;
                  setState(() {});
                },
                child: Image.asset(
                  widget.tabController.index == 0 ? Assets.acgHomeMhSelected : Assets.acgHomeMhNormal,
                  fit: BoxFit.fitHeight,
                  height: widget.tabController.index == 0 ? 28 : 20,
                )),
          ),
          Expanded(
            child: InkWell(
                onTap: () async {
                  widget.tabController.index = 1;
                  setState(() {});
                },
                child: Image.asset(
                  widget.tabController.index == 1 ? Assets.acgHomeDmSelected : Assets.acgHomeDmNormal,
                  fit: BoxFit.fitHeight,
                  height: widget.tabController.index == 1 ? 28 : 20,
                )),
          ),
          Expanded(
            child: InkWell(
                onTap: () async {
                  widget.tabController.index = 2;
                  setState(() {});
                },
                child: Image.asset(
                  widget.tabController.index == 2 ? Assets.acgHomeXsSelected : Assets.acgHomeXsNormal,
                  fit: BoxFit.fitHeight,
                  height: widget.tabController.index == 2 ? 28 : 20,
                )),
          ),
        ],
      ),
    );
  }
}
