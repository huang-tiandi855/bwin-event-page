import 'package:chewie/chewie.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../gen/assets.gen.dart';
import '../../image/network/custom_image_network.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

class SimplePlayerPage extends StatelessWidget {
  final SimplePlayerLogic logic = Get.put(SimplePlayerLogic());
  final SimplePlayerState state = Get.find<SimplePlayerLogic>().state;

  SimplePlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: commonAppBar(""),
      body: Center(
        child: GetBuilder<SimplePlayerLogic>(
          builder: (_) {
            if (state.chewie != null) {
              return Chewie(controller: state.chewie!);
            }
            return AspectRatio(
              aspectRatio: state.aspectRatio ?? 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    color: Colors.black,
                    child: state.coverUrl.isNotEmpty
                        ? CustomImage(url: state.coverUrl, fit: BoxFit.cover)
                        : null,
                  ),
                  Center(
                    child: state.initializing
                        ? const LoadingWidget()
                        : AssetsGen.images.circle.postPaly
                            .image(width: 44.w, height: 44.w),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
