import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/widgets/common_ui/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum PULL_REQUEST_CODE {
  REQUESTING, //请求中
  REQUEST_SUCCESS, //请求成功
  REQUEST_FAIL, //请求失败
  REQUEST_DATA_EMPTY, //数据为空
}

class PullRefreshView extends StatefulWidget {
  final PullRefreshController controller;
  final Widget child;
  final VoidCallback? retryOnTap; //请求失败重试事件
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final bool enablePullUp;
  final bool enablePullDown;
  final String noDataText;
  final String emptyText;

  final Widget? emptyWidget;

  const PullRefreshView({
    Key? key,
    required this.controller,
    required this.child,
    this.retryOnTap,
    this.onRefresh,
    this.onLoading,
    this.enablePullUp = true,
    this.enablePullDown = true,
    this.noDataText = "已经到底啦！",
    this.emptyText = "这里空空如也～",
    this.emptyWidget,
  }) : super(key: key);

  @override
  State<PullRefreshView> createState() => _PullRefreshViewState();
}

class _PullRefreshViewState extends State<PullRefreshView> {
  late VoidCallback listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    widget.controller.code.addListener(listener);
  }

  @override
  void dispose() {
    widget.controller.code.removeListener(listener);
    super.dispose();
  }

  @override
  void initState() {
    listener = () {
      setState(() {});
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isFirstPage = widget.controller.isFirstPage;
    return Stack(
      children: <Widget>[
        Visibility(
          visible: widget.controller.requestCode == PULL_REQUEST_CODE.REQUEST_SUCCESS,
          child: SmartRefresher(
              enablePullDown: widget.enablePullDown,
              enablePullUp: widget.enablePullUp,
              header: WaterDropHeader(
                refresh: LoadingAnimationWidget.flickr(
                  leftDotColor: AppColor.leftDotColor,
                  rightDotColor: AppColor.rightDotColor,
                  size: 26,
                ),
                complete: Text(
                  "刷新成功",
                  style: TextStyle(color: const Color(0xff827f9d), fontSize: 14.sp),
                ),
              ),
              footer: ClassicFooter(
                  loadingIcon: LoadingAnimationWidget.flickr(
                    leftDotColor: AppColor.leftDotColor,
                    rightDotColor: AppColor.rightDotColor,
                    size: 26,
                  ),
                  loadingText: "加载中...",
                  canLoadingText: "松开加载更多",
                  noDataText: widget.noDataText,
                  idleText: "上拉加载更多",
                  textStyle: TextStyle(
                      color: const Color(0xff827f9d),
                      fontSize: 12.sp,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal)),
              controller: widget.controller.refreshController,
              onRefresh: () {
                vibrate();
                widget.onRefresh!();
              },
              onLoading: () {
                vibrate();
                widget.onLoading!();
              },
              child: widget.child), //widget.child,
        ),
        //请求中
        Visibility(
          visible: widget.controller.requestCode == PULL_REQUEST_CODE.REQUESTING,
          child: const Center(
              child: YJFlickr(
            leftDotColor: AppColor.leftDotColor,
            rightDotColor: AppColor.rightDotColor,
            size: 26,
          )),
        ),

        ///无数据
        Visibility(
          visible: isFirstPage && widget.controller.requestCode == PULL_REQUEST_CODE.REQUEST_DATA_EMPTY,
          child: widget.emptyWidget ??
              Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      Text(
                        widget.emptyText,
                        style: TextStyle(fontSize: 18.sp, color: AppColor.c44415b),
                      ),
                    ],
                  ),
                ),
              ),
        ),

        ///请求失败
        Visibility(
          visible: isFirstPage && widget.controller.requestCode == PULL_REQUEST_CODE.REQUEST_FAIL,
          child: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  // Text(
                  //   "加载出错啦!",
                  //   style: TextStyle(fontSize: 15.sp, color: AppColor.c44415b),
                  // ),
                  Visibility(
                    visible: widget.retryOnTap != null,
                    child: InkWell(
                      onTap: () {
                        if (widget.retryOnTap != null) {
                          widget.controller.requesting();
                          widget.retryOnTap?.call();
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
        )
      ],
    );
  }
}

class PullRefreshController {
  late ValueNotifier<PULL_REQUEST_CODE> code;
  bool isFirstPage = false;
  late RefreshController refreshController;

  PullRefreshController({bool isRequest = true}) {
    refreshController = RefreshController();
    if (isRequest) {
      code = ValueNotifier(PULL_REQUEST_CODE.REQUESTING);
    } else {
      code = ValueNotifier(PULL_REQUEST_CODE.REQUEST_SUCCESS);
    }
  }

  PULL_REQUEST_CODE get requestCode => code.value;

  //请求失败
  requestFail({required bool isFirstPageNum}) {
    isFirstPage = isFirstPageNum;
    code.value = isFirstPage ? PULL_REQUEST_CODE.REQUEST_FAIL : PULL_REQUEST_CODE.REQUEST_SUCCESS;
    if (refreshController.isRefresh) {
      refreshController.refreshFailed();
    }
    if (refreshController.isLoading) {
      refreshController.loadFailed();
    }
  }

  //请求成功
  requestSuccess({
    required bool isFirstPageNum,
    bool hasMore = true,
    bool isEmpty = false,
  }) {
    isFirstPage = isFirstPageNum;
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted(resetFooterState: true);
    }
    if (isFirstPage && isEmpty) {
      code.value = PULL_REQUEST_CODE.REQUEST_DATA_EMPTY;
    } else {
      code.value = PULL_REQUEST_CODE.REQUEST_SUCCESS;
      if (hasMore) {
        refreshController.loadComplete();
      } else {
        refreshController.loadNoData();
      }
    }
  }

  //请求中
  requesting() {
    code.value = PULL_REQUEST_CODE.REQUESTING;
  }

  /// 释放底层资源。`RefreshController` 一旦未释放会在 `SmartRefresher.initState`
  /// 时触发 `Don't use one refreshController to multiple SmartRefresher` 断言，
  /// 因此持有者（页面 logic）需在 `onClose` 中调用本方法。
  void dispose() {
    refreshController.dispose();
    code.dispose();
  }
}

Future<void> vibrate() async {
  return await HapticFeedback.lightImpact();
}
