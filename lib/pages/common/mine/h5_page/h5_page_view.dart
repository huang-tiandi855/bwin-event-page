import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webviewx/webviewx.dart';

import '../../../../common/utils/toast_util.dart';
import 'h5_page_logic.dart';

class H5PagePage extends StatefulWidget {
  const H5PagePage({Key? key}) : super(key: key);

  @override
  H5PagePageState createState() => H5PagePageState();
}

class H5PagePageState extends State<H5PagePage> {
  final logic = Get.find<H5PageLogic>();
  final state = Get.find<H5PageLogic>().state;
  late WebViewXController webViewController;

  @override
  Widget build(BuildContext context) {
    if (state.isWeb) {
      return Scaffold(
        appBar: state.showAppBar
            ? state.title == null
                ? null
                : commonAppBar(state.title ?? "")
            : null,
        body: WebViewX(
          key: const ValueKey('H5PagePage'),
          initialSourceType: SourceType.url,
          height: 1.sh,
          width: 1.sw,
          onWebViewCreated: (controller) {
            webViewController = controller;
            webViewController.loadContent(
              state.url ?? "",
              SourceType.url,
            );
          },
          onPageStarted: (src) =>
              debugPrint('A new page has started loading: $src\n'),
          onPageFinished: (src) =>
              debugPrint('The page has finished loading: $src\n'),
          dartCallBacks: {
            DartCallback(
              name: 'TestDartCallback',
              callBack: (msg) {
                showToast(msg: msg);
              },
            )
          },
          webSpecificParams: const WebSpecificParams(
            printDebugInfo: true,
          ),
          mobileSpecificParams: const MobileSpecificParams(
            androidEnableHybridComposition: true,
          ),
          navigationDelegate: (navigation) {
            debugPrint(navigation.content.sourceType.toString());
            return NavigationDecision.navigate;
          },
        ),
      );
    }
    return Scaffold(
      appBar: state.showAppBar
          ? state.title == null
              ? null
              : commonAppBar(state.title ?? "")
          : null,
      body: SafeArea(
        child: Obx(() {
          return Stack(
            children: [
              Offstage(
                offstage: !state.isLoading.value,
                child: const LoadingWidget(),
              ),
              Opacity(
                opacity: state.isLoading.value ? 0.0 : 1.0,
                child: InAppWebView(
                    initialUrlRequest:
                        URLRequest(url: Uri.parse(state.url ?? '')),
                    onLoadStop: (InAppWebViewController controller, Uri? url) {
                      state.isLoading.value = false;
                    }),
              ),
              if (state.showBack) ...[
                Positioned(
                  bottom: 70,
                  right: 10,
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        '退出',
                        style: textStyle(14, Colors.white, FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ]
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<H5PageLogic>();
    super.dispose();
  }
}
