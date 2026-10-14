import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CErrorWidget extends StatefulWidget {
  final String errorMsg;
  final String? errorMsg2;
  final VoidCallback? retryOnTap;
  const CErrorWidget(this.errorMsg, {super.key, this.errorMsg2, this.retryOnTap});

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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*Image(
              image: AssetImage(AssetsImages.IC_NO_DATA_NEARBY),
              width: 216.w,
              height: 210.w,
            ),*/

            SizedBox(height: 25.w,),

            Text(widget.errorMsg, style: const TextStyle(color: Color.fromRGBO(111, 122, 145, 1))),
            (widget.errorMsg2 != null
                ? Text(widget.errorMsg2!, style: const TextStyle(color: Colors.white))
                : Container()),
            Visibility(
              visible: widget.retryOnTap != null,
              child: InkWell(
                onTap: widget.retryOnTap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    "点击重试",
                    style: TextStyle(color: AppColor.bluishPurple),
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
