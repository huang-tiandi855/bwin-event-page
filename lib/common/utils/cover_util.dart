class CoverUtil {
  // 1：顶部轮播样式
  // 2：六宫格竖屏样式
  // 3: 六宫格横屏样式
  // 4: 四宫格竖屏样式
  // 5：四宫格横屏样式
  // 6: 四宫格竖屏列表样式
  // 7: 企业影片样式
  // 8: 三横屏列表样式
  // 9: 八竖屏划动样式
  // 10: 十六竖屏划动样式
  // 11: 十二横屏划动样式
  // 12: 片源推荐样式
  // 13：情色电影样式
  // 14: 一大四小样式
  // 15：短剧顶部轮播样式
  // 16：短剧三竖屏滑动样式
  // 17：短剧六宫格竖屏样式
  // 18：ACG模块-居左顶部轮播样式*
  // 19：ACG模块-居中顶部轮播样式*
  // 20：ACG模块-六宫格竖屏样式
  // 21：ACG模块-四宫格竖屏样式
  // 22：ACG模块-九宫格竖屏样式
  // 23：ACG模块-二竖屏左右滑动样式
  // 24：ACG模块-二横屏左右滑动样式
  // 25: ACG模块-一大四小样式
  // 26：ACG模块-四宫格竖屏滑动样式
  // 27：ACG模块-排行榜样式*
  // 28：ACG模块-随便看看样式*
  static bool isVerticalCover(int? showType) {
    return showType == 2 ||
        showType == 4 ||
        showType == 6 ||
        showType == 9 ||
        showType == 10 ||
        showType == 13 ||
        showType == 16 ||
        showType == 17 ||
        showType == 18 ||
        showType == 19 ||
        showType == 20 ||
        showType == 21 ||
        showType == 22 ||
        showType == 23 ||
        showType == 26 ||
        showType == 28;
  }
}
