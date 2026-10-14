import 'package:comics_app/common/entities/circle/game_data_model.dart';
import 'package:comics_app/common/extension/int_extension.dart';
import 'package:comics_app/common/widgets/game_card/game_outlined_tag.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 黄游信息流纵向卡片：标题 / 更新时间 / 简介 / 三图 / 色标签 / 互动数据。
class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game});

  final GameDataModel game;

  static const Color _placeholder = Color(0xFF2C2C2C);

  @override
  Widget build(BuildContext context) {
    final String desc = game.introText;
    final List<String> images = game.coverUrls;

    List<GameTagShowItem> gameTags = [];
    if (game.categories.isNotEmpty) {
      gameTags.add(GameTagShowItem(
          name: game.categories.first.name, color: GameOutlinedTag.colorAt(0)));
    }
    if (game.platform?.isNotEmpty ?? false) {
      gameTags.add(GameTagShowItem(
          name: game.platform!, color: GameOutlinedTag.colorAt(1)));
    }
    if (game.languageName?.isNotEmpty ?? false) {
      gameTags.add(GameTagShowItem(
          name: game.languageName!, color: GameOutlinedTag.colorAt(2)));
    }

    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 16.w, 10.w, 16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            game.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 18 / 14,
            ),
          ),
          SizedBox(height: 10.w),
          Text(
            '更新时间:${_formatDate(game.auditTime ?? 0)}',
            style: TextStyle(
              color: const Color(0xFF808080),
              fontSize: 12.sp,
              height: 1,
            ),
          ),
          if (desc.isNotEmpty) ...[
            SizedBox(height: 10.w),
            Text(
              desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                height: 16 / 12,
              ),
            ),
          ],
          if (images.isNotEmpty) ...[
            SizedBox(height: 10.w),
            _buildImageRow(images),
          ],
          if (gameTags.isNotEmpty) ...[
            SizedBox(height: 10.w),
            SizedBox(
              height: 22.w,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(width: 10.w),
                  itemCount: gameTags.length,
                  itemBuilder: (context, index) => GameOutlinedTag(
                        model: gameTags[index],
                      )),
            ),
          ],
          SizedBox(height: 12.w),
          _metricsRow(),
        ],
      ),
    );
  }

  Widget _buildImageRow(List<String> images) {
    final List<String> shown = images.take(3).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final double gap = 9.w;
        final double itemW =
            (constraints.maxWidth - gap * (shown.length - 1)) / shown.length;
        return Row(
          children: [
            for (int i = 0; i < shown.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: SizedBox(
                  width: itemW,
                  height: 100.w,
                  child: _cover(shown[i]),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _cover(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover);
    }
    if (url.isEmpty) {
      return const ColoredBox(color: _placeholder);
    }
    return CustomImage(url: url, fit: BoxFit.cover);
  }

  Widget _metricsRow() {
    Widget cell(AssetGenImage asset, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            asset.image(width: 20.w, height: 20.w),
            SizedBox(width: 4.w),
            Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12.sp,
              ),
            ),
          ],
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        cell(AssetsGen.images.circle.postEye, game.watch.humanizeFormat),
        cell(AssetsGen.images.circle.postHeart, game.perfect.humanizeFormat),
        cell(AssetsGen.images.game.gemeCollection,
            game.collectNum.humanizeFormat),
        cell(AssetsGen.images.game.gameCart, game.unlockCount.humanizeFormat),
      ],
    );
  }

  static String _formatDate(int ms) {
    if (ms <= 0) return '';
    final DateTime t = DateTime.fromMillisecondsSinceEpoch(ms);
    final String mm = t.month.toString().padLeft(2, '0');
    final String dd = t.day.toString().padLeft(2, '0');
    return '${t.year}-$mm-$dd';
  }
}
