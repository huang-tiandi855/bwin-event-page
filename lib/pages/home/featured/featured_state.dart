import 'package:card_swiper/card_swiper.dart';
import 'package:comics_app/common/entities/config.dart';

import '../../../common/entities/feature_info.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';

class FeaturedState {
  late List<AdsInfoList> banner = [];

  FeatureEntity? featureEntity;

  late PullRefreshController pullRefreshFeatureController =
      PullRefreshController();

  int? pageNum = 1;

  SwiperController swiperController = SwiperController();

  int selectIndex = 0;

  List<Map> quickList = [
    {
      "image": "assets/images/png/quick_topic.png",
      "title": "专题",
    },
    {
      "image": "assets/images/png/quick_welfare.png",
      "title": "福利",
    },
    {
      "image": "assets/images/png/quick_hot.png",
      "title": "热榜",
    },
    {
      "image": "assets/images/png/quick_member.png",
      "title": "会员",
    },
  ];


  FeaturedState() {
    ///Initialize variables
    //banner = ["assets/images/jpg/1.jpg","assets/images/jpg/2.jpg","assets/images/jpg/3.jpg","assets/images/jpg/4.jpg"];
  }
}
