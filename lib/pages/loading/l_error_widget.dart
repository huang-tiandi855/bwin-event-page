import 'package:flutter/material.dart';

class CErrorWidget extends StatefulWidget {
  final String? errorMsg;
  final String? errorMsg2;
  final VoidCallback? retryOnTap;

  const CErrorWidget(
      {super.key, this.errorMsg = "暂无数据", this.errorMsg2, this.retryOnTap});

  @override
  State<StatefulWidget> createState() {
    return CErrorWidgetState();
  }
}

class CErrorWidgetState extends State<CErrorWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  const Image(
                    image:
                        AssetImage("assets/images/png/ic_no_data_nearby.png"),
                    width: 100,
                    height: 100,
                  ),
                  Positioned(
                    bottom: 6,
                    child: Text(widget.errorMsg ?? "",
                        style: TextStyle(
                            color: const Color(0xff333333).withOpacity(0.5))),
                  )
                ],
              ),
            ),
            (widget.errorMsg2 != null
                ? Text(widget.errorMsg2 ?? "",
                    style: TextStyle(color: const Color(0xff333333).withOpacity(0.5)))
                : Container()),
            Visibility(
              visible: widget.retryOnTap != null,
              child: InkWell(
                onTap: widget.retryOnTap,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                  child: Text(
                    "点击重试",
                    style: TextStyle(
                        color: Colors.blue.withOpacity(0.35), fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
