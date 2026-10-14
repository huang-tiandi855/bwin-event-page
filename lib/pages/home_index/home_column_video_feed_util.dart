/// 首页栏目视频二级 Tab 与 `cms/vod/search-json` 的 `sortType` 映射。

const List<int> kHomeTabVideoSortTypes = <int>[1, 2, 4, 8];

int homeTabVideoSortTypeFromIndex(int index) {
  if (index < 0 || index >= kHomeTabVideoSortTypes.length) {
    return 1;
  }
  return kHomeTabVideoSortTypes[index];
}
