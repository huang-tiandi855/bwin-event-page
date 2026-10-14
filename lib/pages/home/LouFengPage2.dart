import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webviewx/webviewx.dart';
import '../../../common/utils/toast_util.dart';

class H5PageLouFengPage2 extends StatefulWidget {
  const H5PageLouFengPage2({Key? key}) : super(key: key);

  @override
  H5PagePageLouFengState2 createState() => H5PagePageLouFengState2();
}

class H5PagePageLouFengState2 extends State<H5PageLouFengPage2> {

  late WebViewXController webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar("楼凤",),
      body: WebViewX(
        key: const ValueKey('H5PagePageLoufeng'),
        initialSourceType: SourceType.url,
        height: 1.sh,
        width: 1.sw,
        onWebViewCreated: (controller) {
          webViewController = controller;
          webViewController.loadContent(
            ConfigStore.to.configBean.louFengH5,
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

  @override
  void dispose() {
    super.dispose();
  }
}
