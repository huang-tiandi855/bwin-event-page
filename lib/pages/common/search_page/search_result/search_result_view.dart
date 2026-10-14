import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/keep_alive_widget.dart';
import 'package:comics_app/common/widgets/tab_widgets/tab_gradient_indicator_widget.dart';
import 'package:comics_app/pages/common/search_page/widgets/search_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'film_search_result/film_search_result_view.dart';
import 'post_search_result/post_search_result_view.dart';
import 'search_result_logic.dart';

class SearchResultPage extends StatelessWidget {
  const SearchResultPage({Key? key})
      : _embedded = false,
        _initialKeyword = null,
        _textEditingController = null,
        super(key: key);

  const SearchResultPage.embedded({
    Key? key,
    required String initialKeyword,
    required TextEditingController textEditingController,
  })  : _embedded = true,
        _initialKeyword = initialKeyword,
        _textEditingController = textEditingController,
        super(key: key);

  final bool _embedded;
  final String? _initialKeyword;
  final TextEditingController? _textEditingController;

  @override
  Widget build(BuildContext context) {
    final child = _embedded
        ? GetBuilder<SearchResultLogic>(
            init: SearchResultLogic(
              initialKeyword: _initialKeyword,
              textEditingController: _textEditingController,
            ),
            builder: _buildContent,
          )
        : GetBuilder<SearchResultLogic>(builder: _buildContent);
    return KeyboardDismissOnTap(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: child,
      ),
    );
  }

  Widget _buildContent(SearchResultLogic logic) {
    final state = logic.state;
    return getBgColorsView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: SearchInputBar(
              controller: state.textEditingController,
              onSearch: logic.onSearch,
            ),
          ),
          SizedBox(
            height: 40.w,
            child: TabGradientIndicatorTabBar(
              controller: state.tabController,
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              tabAlignment: TabAlignment.fill,
              tabs: [for (final tab in state.tabs) Tab(text: tab)],
              onTap: logic.selectKind,
            ),
          ),
          Expanded(
            child: TabBarView(controller: state.tabController, children: [
              keepAliveWrapper(FilmSearchResultPage(keyWord: state.keyWord)),
              keepAliveWrapper(
                  FilmSearchResultPage(videoType: 1, keyWord: state.keyWord)),
              keepAliveWrapper(PostSearchResultPage(keyWord: state.keyWord)),
            ]),
          ),
        ],
      ),
    );
  }
}
