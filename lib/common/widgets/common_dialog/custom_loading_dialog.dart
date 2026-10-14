import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {

  LoadingWidgetState? loadingWidgetState;
  String? title;
  bool? canCancel;

  LoadingWidget({super.key, this.title, this.canCancel = false});

  void show(context) {
    showDialog(
        context: context,
        builder: (context) {
          return this;
        });
  }

  void cancel() {
    if (loadingWidgetState != null) {
      loadingWidgetState!.cancel();
      loadingWidgetState = null;
    }
  }

  @override
  State<StatefulWidget> createState() {
    loadingWidgetState = LoadingWidgetState();
    return loadingWidgetState!;
  }
}

class LoadingWidgetState extends State<LoadingWidget> {
  void cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    SizedBox sizedBox = SizedBox(
      width: 36,
      height: 36,
      child: CircularProgressIndicator(
        backgroundColor: Colors.grey[500],
        valueColor: const AlwaysStoppedAnimation(Colors.white70),
        strokeWidth: 2,
//              value: .5,
      ),
    );

    Column column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        sizedBox,
        Container(
          margin: const EdgeInsets.only(top: 10),
          alignment: Alignment.center,
          child: Text(widget.title == null ? "加载中..." : widget.title!,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none)),
        )
      ],
    );

    PopScope willPopScope = PopScope(
      canPop: widget.canCancel ?? false,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.black45,
            width: 100,
            height: 100,
            alignment: Alignment.center,
            child: column,
          ),
        ),
      ),
    );

    return willPopScope;
  }
}
