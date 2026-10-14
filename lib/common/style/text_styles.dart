import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


mixin AppTextStyles {
  //** BottomNavigationBar  TextStyle */
  static final kBottomNavigationBarSelectedTextStyle = TextStyle(
    fontSize: 15.sp,
    color: AppColor.kBotttomNavigationSelectedTextColour,
  );
  static final kBottomNavigationBarUnSelectedTextStyle = TextStyle(
    fontSize: 15.sp,
    color: AppColor.kBotttomNavigationUnselectedTextColour,
  );
  static final kUserProfileTextStyle = TextStyle(
    fontSize: 15.sp,
    color: AppColor.c333333,
    fontWeight: FontWeight.w600,
  );

  static final kUserBigTextStyle = TextStyle(
    fontSize: 18.sp,
    color: Colors.black,
  );
  static final kValidateTextStyle = TextStyle(
    fontSize: 12.sp,
    color: Colors.white,
  );

  static final kMobilePinTextStyle =
  TextStyle(fontSize: 12.sp, color: AppColor.kFindMobilePinColour);

  static final kXLUserProfileTextStyle = TextStyle(
    fontSize: 24.sp,
    color: Colors.white,
  );
  static final kXLUserProfileBlackTextStyle = TextStyle(
    fontSize: 24.sp,
    color: Colors.black,
  );
  static final kXLUserBigTextStyle = TextStyle(
    fontSize: 30.sp,
    color: Colors.white,
  );
  static final kXLUserBigBlackTextStyle = TextStyle(
    fontSize: 30.sp,
    color: AppColor.c333333,
    fontWeight: FontWeight.w500,

  );
  static final kUserProfileSmallTextStyle = TextStyle(
      fontSize: 12.sp,
      color:AppColor.warmGrey,
      fontWeight: FontWeight.w500
  );

  static final kUserProfileSmallTextHighlightStyle = TextStyle(
    fontSize: 12.sp,
    color: const Color(0xff45E7DE),
  );

  static final kUserProfileSmallStyle = TextStyle(
    fontSize: 12.sp,
    color: const Color(0xffFFFFFF),
  );
  static final textcolor999Style = TextStyle(
    fontSize: 14.sp,
    color: const Color(0xff999999),
  );

  static final kUserProfileBigTextHighlightStyle = TextStyle(
    fontSize: 15.sp,
    color: const Color(0xff45E7DE),
  );

  static final kUserProfileBigTextHighlight2Style = TextStyle(
    fontSize: 15.sp,
    color: const Color(0xff7145E7),
  );

  static final kFailVideoTextStyle = TextStyle(
    fontSize: 15.sp,
    color: const Color(0xffE52E52),
  );

  static final kUserProfileBlackTextStyle = TextStyle(
    fontSize: 12.sp,
    color: Colors.black,
  );

  static final kUserProfileSubmitTextStyle = TextStyle(
    fontSize: 18.sp,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  static final kUserProfileWhiteTextStyle = TextStyle(
    fontSize: 18.sp,
    color: const Color(0xffffffff),
    fontWeight: FontWeight.w600,
  );
  static final kMyFollowerButtonTextStyle = TextStyle(
    fontSize: 12.sp,
    color: const Color(0xffA3A0B5),
  );

  static final kCreatorButtonTextStyle = TextStyle(
    fontSize: 12.sp,
    color: const Color(0xff9F9FAF),
  );

  static final kBigUserProfileTextStyle = TextStyle(
    fontSize: 18.sp,
    color: Colors.black,
  );

  static final kWhiteProfileTextStyle = TextStyle(
    fontSize: 15.sp,
    color: Colors.white,
  );

  static final kWhiteProfileBlackTextStyle = TextStyle(
    fontSize: 15.sp,
    color: Colors.black,
  );

  static final kLightProfileTextStyle =
  TextStyle(fontSize: 15.sp, color: AppColor.kUserProfileLightColour);
  static final kLightProfileBlackTextStyle =
  TextStyle(fontSize: 15.sp, color: Colors.black);

  static final kLightXProfileTextStyle =
  TextStyle(fontSize: 13.sp, color: AppColor.kUserProfileLightColour);

  static final kSignatureTextStyle =
  TextStyle(fontSize: 15.sp, color: AppColor.kSignatureColour);

  static final kSignatureBlackTextStyle =
  TextStyle(fontSize: 15.sp, color: AppColor.black);

  static final kUserProfileMemberTextStyle =
  TextStyle(fontSize: 12.sp, color: AppColor.kUserProfileBannerColour);
  static final kUserProfileMemberWhiteTextStyle =
  TextStyle(fontSize: 12.sp, color: AppColor.white);
  static final kUserProfileMemberVipTextStyle =
  TextStyle(fontSize: 12.sp, color: const Color.fromRGBO(104, 104, 104, 117));

  static final kHintTextStyle =
  TextStyle(fontSize: 12.sp, color: AppColor.kHintTextColour);
  static final kHintBigTextStyle =
  TextStyle(fontSize: 12.sp, color: AppColor.kHintBigTextColour);

  static final kHintSubTextStyle =
  TextStyle(fontSize: 12.sp, color: AppColor.kHintTextColour);

  static final kCommonQuestionStyle =
  TextStyle(fontSize: 15.sp, color: AppColor.kCommonQuestionColour);
  static final kCommonQuestionBlackStyle =
  TextStyle(fontSize: 15.sp, color: AppColor.black);

  static final kFindMobileStyle =
  TextStyle(fontSize: 12.sp, color: AppColor.kFindMobileColour);
  static final kSmallFindMobileStyle =
  TextStyle(fontSize: 10.sp, color: AppColor.kFindMobileColour);
  static final kSmallFindCodeStyle =
  TextStyle(fontSize: 14.sp, color: AppColor.kFindMobileColour);
  static final k16AndW400C666 =
  TextStyle(fontSize: 16.sp,fontWeight: FontWeight.w400, color: AppColor.c666666);

  static final kPromoteTextStyle =
  TextStyle(fontSize: 22.sp, color: const Color(0xff37E7D2));

  static final kBigPromoteTextStyle =
  TextStyle(fontSize: 36.sp, color: const Color(0xff37E7D2));

  static final kUserProfileTextVerifyCodeStyle = TextStyle(
    fontSize: 15.sp,
    color: const Color(0xFF716f86),
  );

  static final blackRegular10 = TextStyle(
    fontSize: 12.sp,
    color: AppColor.black,
  );
}
