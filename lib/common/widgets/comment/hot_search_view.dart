import 'package:flutter/material.dart';

import '../../entities/comment_entity.dart';
import '../../utils/utils.dart';
import 'package:comics_app/common/widgets/marquee_widget/marquee_widget.dart';

class HotSearchWidget extends StatelessWidget {
  final CommentQuickSearchList model;
  const HotSearchWidget(this.model, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: linkJumpToEvent,
      child: Row(
        children: [
          const Text(
            "大家都在搜: ",
            style: TextStyle(
                color: Color(0xff333333),
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: HomeMarqueeTile(
              widgets: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      model.title ?? "",
                      style: const TextStyle(
                        color: Color(0xffF92B6C),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    // Container(
                    //   alignment: Alignment.topLeft,
                    //   width: 10,
                    //   child: Image.asset(
                    //     Assets.pngHomeSearchIcon,
                    //     width: 10,
                    //     height: 10,
                    //   ),
                    // )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void linkJumpToEvent() {
    if (model.link?.isNotEmpty == true) {
      AppNavigator.to.jumpUrl(
        url: model.link ?? "",
        moduleType: 1,
        linkType: model.linkType ?? 1,
        id: model.id,
        title: model.title,
      );
    } else {
      if (model.searchKeyword?.isNotEmpty == true) {
        // Map<String, dynamic> map = {"keywords": model.searchKeyword};
        // Get.to(() => const DomesticsSearchResultPage(), arguments: map);
      }
    }
  }
}
