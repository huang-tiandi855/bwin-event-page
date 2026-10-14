import 'package:card_swiper/card_swiper.dart';
import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/utils/ads_manage/ads_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Adv.dart';
import 'ShuApp.dart';

class HappyCustomView extends StatefulWidget {
  final List<Adv> advList;
  final List<ShuApp>? gameApp;
  const HappyCustomView(this.advList, {this.gameApp, super.key});

  @override
  State<StatefulWidget> createState() {
    return _HappyCustomViewState();
  }
}

class _HappyCustomViewState extends State<HappyCustomView> {
  List<Adv> get advList => widget.advList;
  List<ShuApp>? get gameApp => widget.gameApp;

  @override
  Widget build(BuildContext context) {
    List<AdsInfoBean> adsList = [];

    for (var element in advList) {
      adsList.add(AdsInfoBean(
          id: element.id,
          cover: element.image,
          href: element.url,
          title: element.name));
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        if (adsList.isNotEmpty == true)
          Container(
            height: 143.w,
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: Swiper(
              onIndexChanged: (index) {
                //state.selectIndex = index;
              },
              itemBuilder: (BuildContext context, int index) {
                return ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: GestureDetector(
                    onTap: () {
                      var ad = adsList[index];

                      UserApi.recreationList(ad.id ?? "", "adv");

                      AppNavigator.to.jumpAdv(
                        id: ad.id.toString(),
                        title: ad.title.toString(),
                        url: ad.href.toString(),
                      planId: '', slotCode: '');
                    },
                    child: CustomImage(
                      url: adsList[index].cover,
                      //height: 262.w,
                      aspectRatio: 2.39,
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              },
              autoplayDelay: 5000,
              itemCount: adsList.length,
              autoplay: true,
              loop: true,
              pagination: adsList.length > 1
                  ? const SwiperPagination(
                      alignment: Alignment.bottomRight,
                      builder: DotSwiperPaginationBuilder(
                        activeColor: Color.fromRGBO(148, 214, 218, 1),
                        space: 6,
                        size: 6,
                        activeSize: 9,
                        color: Color.fromRGBO(48, 214, 218, 0.5),
                      ),
                    )
                  : null,
            ),
          ),
        SizedBox(
          height: 28.w,
          child: Row(
            children: [
              Container(
                height: 22,
                width: 4,
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(148, 214, 231, 1),
                    borderRadius: BorderRadius.circular(22)),
              ),
              const SizedBox(width: 12),
              const Text(
                "热门推荐",
                style: TextStyle(
                  color: Color.fromRGBO(51, 51, 51, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            itemCount: gameApp?.length ?? 0,
            itemBuilder: (context, index) {
              return _buildCustomAdImageItem(gameApp![index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAdImageItem(ShuApp model) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: InkWell(
        onTap: () {
          UserApi.recreationList(model.id ?? "", "app");

          AppNavigator.to.jumpAdv(
            id: model.id.toString(),
            title: model.name.toString(),
            url: model.url.toString(),
          planId: '', slotCode: '');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CustomImage(
                url: model.icon,
                width: 720,
                height: 100,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              model.name.toString(),
              style: const TextStyle(
                  color: Color.fromRGBO(51, 51, 51, 1), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
