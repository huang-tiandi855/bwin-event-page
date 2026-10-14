import 'package:comics_app/common/utils/const.dart';
import 'package:comics_app/common/widgets/acg_section/acg_media_grid_layout_view.dart';
import 'package:comics_app/common/widgets/emptyWidget.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/pages/common/search_page/hot_ranking/cartoon/cartoon_logic.dart';
import 'package:comics_app/pages/common/mine/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CartoonRankingPage extends StatelessWidget {
  final int kind;
  const CartoonRankingPage({required this.kind, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartoonHotRankingLogic>(
        init: CartoonHotRankingLogic(kind),
        tag: key?.toString(),
        builder: (logic) {
          final state = logic.state;
          return state.ranking == null
              ? const LoadingWidget()
              : Container(
                  margin: EdgeInsets.only(left: 12.w, right: 12.w),
                  child: state.ranking?.mediaList == null
                      ? Empty()
                      : PullRefreshView(
                          onRefresh: () {
                            state.pageNumber = 1;
                            logic.getMediaInfo();
                          },
                          onLoading: () {
                            state.pageNumber = state.pageNumber! + 1;
                            logic.getMediaInfo();
                          },
                          controller: state.pullRefreshController,
                          child: kind == KindConst.CARTTONKIND ||
                                  kind == KindConst.PORTRAYKIND
                              ? staggeredAllMediaList(
                                  state.ranking?.mediaList ?? [], true)
                              : MediaGridLayoutView(
                                  showType: kind == 3 ? 5 : 2,
                                  medias: state.ranking?.mediaList ?? [],
                                  hotRank: true,
                                ),
                        ),
                );
        });
  }
}
