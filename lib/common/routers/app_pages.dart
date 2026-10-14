import 'package:comics_app/pages/application/application_binding.dart';
import 'package:comics_app/pages/application/application_view.dart';
import 'package:comics_app/pages/circle/community/post_details/post_details_view.dart';
import 'package:comics_app/pages/circle/games/game_details/game_details_view.dart';
import 'package:comics_app/pages/common/user_center/binding.dart';
import 'package:comics_app/pages/common/user_center/view.dart';
import 'package:comics_app/pages/home/portray_detail/portray_detail_binding.dart';
import 'package:comics_app/pages/home/portray_detail/portray_detail_view.dart';
import 'package:comics_app/pages/home/tag_detail/tag_detail_binding.dart';
import 'package:comics_app/pages/home/tag_detail/tag_sub/tag_sub_page.dart';
import 'package:comics_app/pages/home/topic/topic_binding.dart';
import 'package:comics_app/pages/home/topic/topic_view.dart';
import 'package:comics_app/pages/home/video_topic/video_topic_view.dart';
import 'package:comics_app/pages/mine_index/account_credentials/account_credentials_binding.dart';
import 'package:comics_app/pages/mine_index/account_credentials/account_credentials_view.dart';
import 'package:comics_app/pages/mine_index/common_problem/view.dart';
import 'package:comics_app/pages/mine_index/message_center/view.dart';
import 'package:comics_app/pages/mine_index/exchange_code/exchange_code_binding.dart';
import 'package:comics_app/pages/mine_index/exchange_code/exchange_code_view.dart';
import 'package:comics_app/pages/mine_index/lock_screen_pattern/view.dart';
import 'package:comics_app/pages/mine_index/setting_center/binding.dart';
import 'package:comics_app/pages/mine_index/setting_center/setting_center_avatar/binding.dart';
import 'package:comics_app/pages/mine_index/setting_center/setting_center_avatar/view.dart';
import 'package:comics_app/pages/mine_index/setting_center/setting_center_gender/binding.dart';
import 'package:comics_app/pages/mine_index/setting_center/setting_center_gender/view.dart';
import 'package:comics_app/pages/mine_index/setting_center/setting_center_invite/binding.dart';
import 'package:comics_app/pages/mine_index/setting_center/setting_center_invite/view.dart';
import 'package:comics_app/pages/mine_index/setting_center/setting_center_nickname/binding.dart';
import 'package:comics_app/pages/mine_index/setting_center/setting_center_nickname/view.dart';
import 'package:comics_app/pages/mine_index/setting_center/setting_center_phone/binding.dart';
import 'package:comics_app/pages/mine_index/setting_center/setting_center_phone/view.dart';
import 'package:comics_app/pages/mine_index/setting_center/view.dart';
import 'package:comics_app/pages/common/mine/h5_page/h5_page_binding.dart';
import 'package:comics_app/pages/common/mine/h5_page/h5_page_view.dart';
import 'package:comics_app/pages/original/original_topic/topic_binding.dart';
import 'package:comics_app/pages/original/original_topic/topic_view.dart';
import 'package:comics_app/pages/short_video_main/main/short_video_main_binding.dart';
import 'package:comics_app/pages/short_video_main/main/short_video_main_view.dart';
import 'package:comics_app/pages/common/splash/splash_binding.dart';
import 'package:comics_app/pages/common/splash/splash_view.dart';
import 'package:comics_app/pages/video_page/video_page_binding.dart';
import 'package:comics_app/pages/video_page/video_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/ai_index/ai_advanced_undress/binding.dart';
import '../../pages/ai_index/ai_advanced_undress/view.dart';
import '../../pages/ai_index/ai_custom/binding.dart';
import '../../pages/ai_index/ai_custom/view.dart';
import '../../pages/ai_index/ai_image_expand/binding.dart';
import '../../pages/ai_index/ai_image_expand/view.dart';
import '../../pages/ai_index/ai_image_to_video/binding.dart';
import '../../pages/ai_index/ai_image_to_video/view.dart';
import '../../pages/ai_index/ai_record/binding.dart';
import '../../pages/ai_index/ai_record/view.dart';
import '../../pages/ai_index/ai_task_progress/ai_task_progress_page.dart';
import '../../pages/ai_index/ai_text_to_image/binding.dart';
import '../../pages/ai_index/ai_text_to_image/view.dart';
import '../../pages/ai_index/ai_text_to_video/binding.dart';
import '../../pages/ai_index/ai_text_to_video/view.dart';
import '../../pages/bookshelf/comic_reading/comic_reading_binding.dart';
import '../../pages/bookshelf/comic_reading/comic_reading_view.dart';
import '../../pages/bookshelf/novel_details/novel_details_binding.dart';
import '../../pages/bookshelf/novel_details/novel_details_view.dart';
import '../../pages/bookshelf/reader/reader_binding.dart';
import '../../pages/bookshelf/reader/reader_view.dart';
import '../../pages/circle/dating/dating_details/dating_details_view.dart';
import '../../pages/circle/publish/publish_binding.dart';
import '../../pages/circle/publish/publish_view.dart';
import '../../pages/common/chat/binding.dart';
import '../../pages/common/chat/view.dart';
import '../../pages/common/simple_player/binding.dart';
import '../../pages/common/simple_player/view.dart';
import '../../pages/home/categories/categories_binding.dart';
import '../../pages/home/categories/categories_view.dart';
import '../../pages/home/channel/channel_binding.dart';
import '../../pages/home/channel/channel_view.dart';
import '../../pages/common/search_page/hot_ranking/hot_ranking_binding.dart';
import '../../pages/common/search_page/hot_ranking/hot_ranking_view.dart';
import '../../pages/common/search_page/search_page_binding.dart';
import '../../pages/common/search_page/search_page_view.dart';
import '../../pages/common/search_page/search_result/search_result_binding.dart';
import '../../pages/common/search_page/search_result/search_result_view.dart';

import '../../pages/common/rank_detail/rank_detail_binding.dart';
import '../../pages/common/rank_detail/rank_detail_view.dart';
import '../../pages/common/signin_welfare/agent_promotion/income_detail/income_detail_binding.dart';
import '../../pages/common/signin_welfare/agent_promotion/income_detail/income_detail_view.dart';
import '../../pages/common/signin_welfare/agent_promotion/promotion_data/promotion_data_binding.dart';
import '../../pages/common/signin_welfare/agent_promotion/promotion_data/promotion_data_view.dart';
import '../../pages/common/signin_welfare/signin/exchange_record/exchange_record_binding.dart';
import '../../pages/common/signin_welfare/signin/exchange_record/exchange_record_view.dart';
import '../../pages/common/signin_welfare/signin/sign_record/sign_record_binding.dart';
import '../../pages/common/signin_welfare/signin/sign_record/sign_record_view.dart';
import '../../pages/common/signin_welfare/signin_welfare_binding.dart';
import '../../pages/common/signin_welfare/view.dart';
import '../../pages/home_index/topic_more_detail/topic_more_detail_binding.dart';
import '../../pages/home_index/topic_more_detail/topic_more_detail_view.dart';

import '../../pages/home/video_topic/video_topic_binding.dart';
import '../../pages/mine_index/history_record/binding.dart';
import '../../pages/mine_index/history_record/view.dart';
import '../../pages/mine_index/my_collection/binding.dart';
import '../../pages/mine_index/my_collection/view.dart';
import '../../pages/mine_index/my_follow/binding.dart';
import '../../pages/mine_index/my_follow/view.dart';
import '../../pages/mine_index/my_likes/binding.dart';
import '../../pages/mine_index/my_likes/view.dart';
import '../../pages/mine_index/my_purchase/binding.dart';
import '../../pages/mine_index/my_purchase/view.dart';
import '../../pages/mine_index/share_invite/share_binding.dart';
import '../../pages/mine_index/share_invite/view.dart';
import '../../pages/mine_index/share_invite/invite_record/binding.dart';
import '../../pages/mine_index/share_invite/invite_record/view.dart';
import '../../pages/mine_index/account_safe/phone_recovery/phone_recovery_binding.dart';
import '../../pages/mine_index/account_safe/phone_recovery/phone_recovery_view.dart';
import '../../pages/mine_index/account_safe/scan_voucher/scan_voucher_binding.dart';
import '../../pages/mine_index/account_safe/scan_voucher/scan_voucher_view.dart';
import '../../pages/mine_index/account_safe/view.dart';
import '../../pages/mine_index/vip_center/view.dart';
import '../../pages/mine_index/create_center/view.dart';
import '../../pages/mine_index/with_drawal/view.dart';
import '../../pages/mine_index/feed_back/view.dart';
import '../../pages/mine_index/groups/view.dart';
import '../../pages/mine_index/wallet/view.dart';
import '../../pages/welfare/welfare_details/welfare_details_binding.dart';
import '../../pages/welfare/welfare_details/welfare_details_view.dart';
import '../components/picture_preview/picture_preview_binding.dart';
import '../components/picture_preview/picture_preview_view.dart';
import 'app_routes.dart';

class SplashMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // final isLockPassword = SpUtil.getBool(VariableConfig.lockScreen, defValue: false);
    // if (isLockPassword == true) return const RouteSettings(name: AppRoutes.SPLASH_LOCK_SCREEN);
    return null;
  }
}

class AppPages {
  static final routes = [
    GetPage(
        name: AppRoutes.SPLASH,
        page: () => SplashPage(),
        binding: SplashBinding(),
        transition: Transition.fadeIn,
        middlewares: [SplashMiddleware()]),
    GetPage(
      name: AppRoutes.APPLICATION_PAGE,
      page: () => ApplicationPage(),
      binding: ApplicationBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.TOPIC_PAGE,
      page: () => TopicPage(),
      binding: TopicBinding(),
      transition: Transition.rightToLeftWithFade,
    ),

    GetPage(
      name: AppRoutes.ORIGINAL_TOPIC_PAGE,
      page: () => OriginalTopicPage(),
      binding: OriginalTopicBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.CHANNEL_PAGE,
      page: () => ChannelPage(),
      binding: ChannelBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.SEARCH_PAGE,
      page: () => const SearchPagePage(),
      binding: SearchPageBinding(),
      transition: Transition.rightToLeftWithFade,
    ),

    GetPage(
      name: AppRoutes.SEARCH_RESULT_PAGE,
      page: () => const SearchResultPage(),
      binding: SearchResultBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.HOT_RANKING_PAGE,
      page: () => HotRankingPage(),
      binding: HotRankingBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.CATEGORIES_PAGE,
      page: () => const CategoriesPage(),
      binding: CategoriesBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.VIDEOTOPIC_PAGE,
      page: () => VideoTopicPage(),
      binding: VideoTopicBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.USER_CENTER,
      page: () => const UserCenterPage(),
      binding: UserCenterBinding(),
    ),
    GetPage(
      name: AppRoutes.POST_DETAILS,
      page: () => PostDetailsPage(),
    ),
    GetPage(
      name: AppRoutes.GAME_DETAILS,
      page: () => GameDetailsPage(),
    ),
    GetPage(
      name: AppRoutes.DATING_DETAILS,
      page: () => DatingDetailsPage(),
    ),
    GetPage(
      name: AppRoutes.CREATE_CENTER,
      page: () => CreateCenterPage(),
    ),
    GetPage(
      name: AppRoutes.WITH_DRAWAL,
      page: () => const WithDrawalPage(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.WELFARE_DETAILS,
      page: () => WelfareDetailsPage(),
      binding: WelfareDetailsBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.COMMENT_DETAILS,
    //   page: () => CommentDetailsPage(),
    //   binding: CommentDetailsBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.COMMENT_DETAILS,
    //   page: () => CommentDetailsPage(),
    //   binding: CommentDetailsBinding(),
    // ),
    GetPage(
      name: AppRoutes.PUBLISH,
      page: () => PublishPage(),
      binding: PublishBinding(),
    ),

    GetPage(
      name: AppRoutes.PICTURE_PREVIEW,
      page: () => PicturePreviewPage(),
      binding: PicturePreviewBinding(),
    ),

    ///书架
    GetPage(
      name: AppRoutes.NOVEL_DETAILS_PAGE,
      page: () => const NovelDetailsPage(),
      binding: NovelDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.READER,
      page: () => ReaderPage(),
      binding: ReaderBinding(),
    ),
    GetPage(
      name: AppRoutes.COMIC_READER,
      page: () => const ComicReadingPage(),
      binding: ComicReadingBinding(),
    ),

    ///我的
    GetPage(
      name: AppRoutes.LOCK_SCREEN_PATTERN,
      page: () => const PasswordPage(),
    ),
    GetPage(
      name: AppRoutes.VIDEO_PAGE,
      page: () => const VideoPagePage(),
      binding: VideoPageBinding(),
    ),

    ///网页
    GetPage(
      name: AppRoutes.H5_PAGE,
      page: () => const H5PagePage(),
      binding: H5PageBinding(),
    ),
    GetPage(
      name: AppRoutes.PORTRAY,
      page: () => PortrayDetailPage(),
      binding: PortrayDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.MINE_MY_COLLECTION,
      page: () => const MyCollectionPage(),
      binding: MyCollectionBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.MINE_MY_PURCHASE,
      page: () => const MyPurchasePage(),
      binding: MyPurchaseBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.MINE_MY_LIKES,
      page: () => const MyLikesPage(),
      binding: MyLikesBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.MINE_MY_FOLLOW,
      page: () => const MyFollowPage(),
      binding: MyFollowBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.MINE_INDEX_HISTORY,
      page: () => const MineHistoryRecordPage(),
      binding: MineHistoryRecordBinding(),
      transition: Transition.rightToLeftWithFade,
    ),

    GetPage(
      name: AppRoutes.ACCOUNT_CREDENTIALS,
      page: () => AccountCredentialsPage(),
      binding: AccountCredentialsBinding(),
    ),
    GetPage(
      name: AppRoutes.SHARE_INVITE,
      page: () => const ShareInvitePage(),
      binding: ShareInviteBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.MINE_INVITE_RECORD,
      page: () => const InviteRecordPage(),
      binding: InviteRecordBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.EXCHANGE_CODE,
      page: () => const ExchangeCodePage(),
      binding: ExchangeCodeBinding(),
    ),
    GetPage(
      name: AppRoutes.TAGS_DETAIL,
      page: () => TagSubDetailPage(),
      binding: TagDetailBinding(tagName: "TAGS_DETAIL"),
    ),
    GetPage(
      name: AppRoutes.TAGS_SPECIAL_DETAIL,
      page: () => TagSubDetailPage(),
      binding: TagDetailBinding(tagName: "TAGS_SPECIAL_DETAIL"),
    ),

    GetPage(
      name: AppRoutes.SHORT_VIDEO_MAIN,
      page: () => const ShortVideoMainPage(),
      binding: ShortVideoMainBinding(),
    ),
    GetPage(
      name: AppRoutes.TOPIC_MORE_DETAIL,
      page: () => const TopicMoreDetailPage(),
      binding: TopicMoreDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.RANK_DETAIL,
      page: () => const RankDetailPage(),
      binding: RankDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.SIGNIN_WELFARE,
      page: () => const SigninWelfarePage(),
      binding: SigninWelfareBinding(),
    ),
    GetPage(
      name: AppRoutes.SIGNIN_RECORDS,
      page: () => const SignRecordPage(),
      binding: SignRecordBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.SIGNIN_EXCHANGE_RECORDS,
      page: () => const ExchangeRecordPage(),
      binding: ExchangeRecordBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.AGENT_PROMOTION_DATA,
      page: () => const PromotionDataPage(),
      binding: PromotionDataBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.AGENT_INCOME_DETAIL,
      page: () => const IncomeDetailPage(),
      binding: IncomeDetailBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.FEEDBACK,
      page: () => const FeedBackPage(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.GROUPS,
      page: () => GroupsPage(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.WALLET,
      page: () => const WalletPage(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.MEMBER_CENTER,
      page: () => const VipCenterPage(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.ACCOUNT_SAFE,
      page: () => const AccountSafePage(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.ACCOUNT_SAFE_PHONE_RECOVERY,
      page: () => const PhoneRecoveryPage(),
      binding: PhoneRecoveryBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.ACCOUNT_SAFE_SCAN_VOUCHER,
      page: () => const ScanVoucherPage(),
      binding: ScanVoucherBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.SETTING_CENTER,
      page: () => const SettingCenterPage(),
      binding: SettingCenterPageBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.SETTING_CENTER_SELECT_AVATAR,
      page: () => const SettingCenterAvatarPage(),
      binding: SettingCenterAvatarBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.SETTING_CENTER_EDIT_NICKNAME,
      page: () => const SettingCenterNicknamePage(),
      binding: SettingCenterNicknameBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.SETTING_CENTER_EDIT_GENDER,
      page: () => const SettingCenterGenderPage(),
      binding: SettingCenterGenderBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.SETTING_CENTER_BIND_PHONE,
      page: () => const SettingCenterPhonePage(),
      binding: SettingCenterPhoneBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.SETTING_CENTER_BIND_INVITE,
      page: () => const SettingCenterInvitePage(),
      binding: SettingCenterInviteBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.MINE_COMMON_PROBLEM,
      page: () => CommonProblemPage(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.MESSAGE_CENTER,
      page: () => MessageCenterPage(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.SIMPLE_PLAYER,
      page: () => SimplePlayerPage(),
      binding: SimplePlayerBinding(),
    ),
    GetPage(
      name: AppRoutes.CHAT,
      page: () => const ChatPage(),
      binding: ChatBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.AI_ADVANCED_UNDRESS,
      page: () => const AiAdvancedUndressPage(),
      binding: AiAdvancedUndressBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.AI_TEXT_TO_IMAGE,
      page: () => const AiTextToImagePage(),
      binding: AiTextToImageBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.AI_TEXT_TO_VIDEO,
      page: () => const AiTextToVideoPage(),
      binding: AiTextToVideoBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.AI_IMAGE_EXPAND,
      page: () => const AiImageExpandPage(),
      binding: AiImageExpandBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.AI_IMAGE_TO_VIDEO,
      page: () => const AiImageToVideoPage(),
      binding: AiImageToVideoBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.AI_CUSTOM,
      page: () => const AiCustomPage(),
      binding: AiCustomBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.AI_RECORD,
      page: () => const AIRecordPage(),
      binding: AiRecordBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.AI_TASK_PROGRESS,
      page: () => const AiTaskProgressPage(),
      binding: AiTaskProgressBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
