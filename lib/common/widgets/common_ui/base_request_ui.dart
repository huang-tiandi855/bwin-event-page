import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'loading_animation.dart';

///网络请求状态UI
class NetRequestStateUI extends StatefulWidget {
  final RequestController requestController;
  final Widget child;
  final VoidCallback? retryTap;

  const NetRequestStateUI(
      {Key? key,
      required this.requestController,
      required this.child,
      this.retryTap})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RequestState();
}

class _RequestState extends State<NetRequestStateUI> {
  VoidCallback? _listener;

  @override
  void initState() {
    _listener = () {
      setState(() {});
    };
    super.initState();
  }

  @override
  void dispose() {
    if (_listener != null) {
      widget.requestController.code?.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_listener != null) {
      widget.requestController.code?.addListener(_listener!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ///success UI
        _buildSuccessUI(),

        ///empty data
        _buildEmptyDataUI(),

        ///request fail
        _buildRequestFailUI(),

        ///requesting
        _buildRequestingUI(),
      ],
    );
  }

  ///success UI
  Visibility _buildSuccessUI() => Visibility(
      visible: widget.requestController.requestCode ==
          BaseRequestCode.requestSuccess,
      child: widget.child);

  ///empty data
  Visibility _buildEmptyDataUI() => Visibility(
        visible: widget.requestController.requestCode ==
            BaseRequestCode.requestDataEmpty,
        child: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: <Widget>[
                Text(
                  "这里空空如也～",
                  style: TextStyle(fontSize: 18.sp, color: AppColor.c44415b),
                ),
                Visibility(
                  visible: widget.retryTap != null,
                  child: InkWell(
                    onTap: () {
                      if (widget.retryTap != null) {
                        widget.requestController.requesting();
                        widget.retryTap?.call();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      child: const Text(
                        "点击重新加载~",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );

  ///request fail
  Visibility _buildRequestFailUI() => Visibility(
        visible:
            widget.requestController.requestCode == BaseRequestCode.requestFail,
        child: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: <Widget>[
                Text(
                  "加载失败~",
                  style: TextStyle(fontSize: 18.sp, color: AppColor.c44415b),
                ),
                Visibility(
                  visible: widget.retryTap != null,
                  child: InkWell(
                    onTap: () {
                      if (widget.retryTap != null) {
                        widget.requestController.requesting();
                        widget.retryTap?.call();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      child: const Text(
                        "点击重新加载~",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      );


  Widget buildEmptyUI(VoidCallback? retryTap) => Container(
    alignment: Alignment.center,
    child: SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: <Widget>[
          Text(
            "没有数据~",
            style: TextStyle(fontSize: 18.sp, color: AppColor.c44415b),
          ),
          Visibility(
            visible: retryTap != null,
            child: InkWell(
              onTap: () {
                if (retryTap != null) {
                  retryTap.call();
                }
              },
              child: Container(
                padding: EdgeInsets.all(10.w),
                child: const Text(
                  "点击重新加载~",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );

  ///requesting
  Visibility _buildRequestingUI() => Visibility(
        visible:
            widget.requestController.requestCode == BaseRequestCode.requesting,
        child:  Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(top: 80),
          child: const YJFlickr(
            leftDotColor: AppColor.leftDotColor,
            rightDotColor: AppColor.rightDotColor,
            size: 24,
          ),
        ),
      );
}

enum BaseRequestCode {
  requesting,

  ///请求中
  requestSuccess,

  ///请求成功
  requestFail,

  ///请求失败
  requestDataEmpty,

  ///数据为空
}

class RequestController {
  ValueNotifier<BaseRequestCode>? code =
      ValueNotifier(BaseRequestCode.requesting);

  RequestController({bool isRequest = true}) {
    if (isRequest) {
      code = ValueNotifier(BaseRequestCode.requesting);
    } else {
      code = ValueNotifier(BaseRequestCode.requestSuccess);
    }
  }

  BaseRequestCode? get requestCode => code?.value;

  ///请求失败
  requestFail() {
    code?.value = BaseRequestCode.requestFail;
  }

  ///数据为空
  requestDataEmpty() {
    code?.value = BaseRequestCode.requestDataEmpty;
  }

  ///请求成功
  requestSuccess() {
    code?.value = BaseRequestCode.requestSuccess;
  }

  ///请求中
  requesting() {
    code?.value = BaseRequestCode.requesting;
  }
}
