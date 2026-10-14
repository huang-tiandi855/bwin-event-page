import 'package:comics_app/common/entities/circle/game_data_model.dart';
import 'package:comics_app/common/entities/circle/post_card_data.dart';
import 'package:comics_app/common/widgets/game_card/game_outlined_tag.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 游戏详情「相关推荐」四宫格卡片（设计稿约 166×200）。
class GameDetailCard extends StatelessWidget {
  const GameDetailCard({super.key, required this.game});

  final GameDataModel game;

  /// 封面宽高比（设计稿 166×110）。
  static const double coverAspectRatio = 166 / 110;

  @override
  Widget build(BuildContext context) {
    final String cover = _coverUrl(game);
    final String platforms = game.platform ?? '';

    List<GameTagShowItem> gameTags = [];
    if (game.categories.isNotEmpty) {
      gameTags.add(GameTagShowItem(
          name: game.categories.first.name, color: GameOutlinedTag.colorAt(0)));
    }
    // if (game.platform?.isNotEmpty ?? false) {
    //   gameTags.add(GameTagShowItem(
    //       name: game.platform!, color: GameOutlinedTag.colorAt(1)));
    // }
    if (game.languageName?.isNotEmpty ?? false) {
      gameTags.add(GameTagShowItem(
          name: game.languageName!, color: GameOutlinedTag.colorAt(2)));
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: coverAspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _cover(cover),
                Positioned(
                  left: 9.w,
                  bottom: 8.w,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AssetsGen.images.circle.postEye
                          .image(width: 12.w, height: 12.w),
                      SizedBox(width: 2.w),
                      Text(
                        game.displayViews,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(10.r)),
                border: Border(
                    left: BorderSide(color: Colors.white.withOpacity(0.15)),
                    right: BorderSide(color: Colors.white.withOpacity(0.15)),
                    bottom: BorderSide(color: Colors.white.withOpacity(0.15))),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(6.w, 5.w, 6.w, 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        height: 17 / 12,
                      ),
                    ),
                    if (gameTags.isNotEmpty) ...[
                      SizedBox(height: 6.w),
                      SizedBox(
                        height: 22.w,
                        child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 10.w),
                            itemCount: gameTags.length,
                            itemBuilder: (context, index) => GameOutlinedTag(
                                  model: gameTags[index],
                                )),
                      ),
                    ],
                    const Spacer(),
                    if (platforms.isNotEmpty)
                      Text(
                        platforms,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cover(String url) {
    return CustomImage(
      url: url,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
    );
  }

  static String _coverUrl(GameDataModel game) {
    if (game.coverUrls.isNotEmpty) return game.coverUrls.first;
    for (final PostSourceItem s in game.sources) {
      if (s.type == PostSourceType.video && (s.screen?.isNotEmpty ?? false)) {
        return s.screen!;
      }
    }
    return '';
  }
}
