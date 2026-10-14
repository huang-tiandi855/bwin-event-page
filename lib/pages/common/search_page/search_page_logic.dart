import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/entities/MediaListInfo.dart';
import 'package:comics_app/common/utils/const.dart';
import 'package:comics_app/common/services/storage.dart';
import 'package:comics_app/common/values/storage.dart';
import 'package:get/get.dart';

import '../../../common/apis/user.dart';
import '../../../common/utils/toast_util.dart';
import 'search_page_state.dart';

class SearchPageLogic extends GetxController {
  final SearchPageState state = SearchPageState();

  @override
  void onInit() {
    super.onInit();
    hotSearch();
    state.textEditingController.addListener(() {
      final text = state.textEditingController.value.text.trim();
      if (text.isNotEmpty) {
        state.isHideClear = false;
        update();
      } else {
        state.isHideClear = true;
        if (state.hasSearched) {
          resetSearchResult();
          return;
        }
        update();
      }
    });
  }

  void refreshSearchRecord() {
    update();
  }

  void expandSearchRecord() {
    state.isNeedExpand = true;

    update();
  }

  void deleteSelectSearchRecord() {
    state.searchList.clear();
    StorageService.to.remove(Storage.searchList);
    update();
  }

  //热门搜索
  void hotSearch() async {
    final groups = await HomeApis.getHotSearchList();
    state.hotSearchKeywords = groups
        .expand((group) => group.tagList)
        .map((item) => item.tag?.trim())
        .whereType<String>()
        .where((tag) => tag.isNotEmpty)
        .take(10)
        .toList();

    // 兼容老用户升级：构造时已经读过一次，这里再读一次以防热门接口返回前
    // 用户跨页又写过新的关键字。
    state.reloadSearchHistory();

    update();
  }

  void clear() {
    state.textEditingController.clear();

    state.searchList.clear();

    StorageService.to.white(Storage.searchList, state.searchList);

    update();
  }

  Future<void> changeSearchKind(int index) async {
    if (state.searchKindIndex == index) return;
    state.searchKindIndex = index;
    if (state.hasSearched) {
      await searchResultInPage(state.searchKeyword);
    } else {
      update();
    }
  }

  void changeSearchSort(int index) {
    if (state.searchSortIndex == index) return;
    state.searchSortIndex = index;
    _sortSearchResults();
    update();
  }

  void resetSearchResult() {
    state.hasSearched = false;
    state.searchKeyword = '';
    state.searchResultList.clear();
    update();
  }

  Future<void> searchResultInPage(String? keyWord) async {
    final text = keyWord?.trim() ?? '';
    if (text.isEmpty) {
      showToast(msg: "请输入要搜索的内容");
      return;
    }

    state.saveKeywords(text);
    state.searchKeyword = text;
    state.textEditingController.text = text;
    state.hasSearched = true;
    state.isSearching = true;
    update();

    final data = {
      'page': 1,
      'pageSize': 30,
      'kind': _searchKind,
      'keyword': text,
    };
    final entityInfo = await UserApi.searchKeyWord(data);
    final result = MediaListInfo.fromJson(entityInfo);
    state.searchResultList = result.data?.mediaList ?? [];
    _sortSearchResults();
    state.isSearching = false;
    update();
  }

  int get _searchKind {
    switch (state.searchKindIndex) {
      case 1:
        return KindConst.CARTTONKIND;
      case 2:
        return KindConst.COMMICKIND;
      case 3:
        return KindConst.QUANZI;
      case 4:
        return KindConst.PORTRAYKIND;
      case 0:
      default:
        return KindConst.CARTTONKIND;
    }
  }

  void _sortSearchResults() {
    if (state.searchResultList.isEmpty) return;
    if (state.searchSortIndex == 0) {
      state.searchResultList.sort(
        (a, b) => (b.countCollect ?? 0).compareTo(a.countCollect ?? 0),
      );
    } else if (state.searchSortIndex == 1) {
      state.searchResultList.sort(
        (a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''),
      );
    } else {
      state.searchResultList.sort(
        (a, b) => (b.countBrowse ?? 0).compareTo(a.countBrowse ?? 0),
      );
    }
  }

  Future<void> onSearch(bool showTags, [String? text]) async {
    text ??= state.textEditingController.text;
    if (text.isEmpty) {
      showToast(msg: "请输入要搜索的内容");
    } else {
      await searchResultInPage(text);
    }
  }
}
