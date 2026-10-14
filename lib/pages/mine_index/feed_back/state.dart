import 'package:comics_app/common/values/enum.dart';
import 'package:flutter/material.dart';

class FeedBackState {
  late TextEditingController feedbackController;

  /// 选中的问题分类下标，-1 表示未选
  int selectedCategoryIndex = -1;

  /// 反馈配图本地路径（插入图片）
  final List<String> imagePaths = <String>[];

  /// 反馈配图最多张数
  static const int maxImageCount = 9;

  /// 是否正在提交（图片上传 + 接口请求中），避免重复点击
  bool submitting = false;

  static const List<FeedBackModel> categories = [
    FeedBackModel(
      title: '账号问题',
      feedbackType: FeedBackTypeEnum.account,
    ),
    FeedBackModel(
      title: '用户反馈',
      feedbackType: FeedBackTypeEnum.user,
    ),
    FeedBackModel(
      title: 'APP体验',
      feedbackType: FeedBackTypeEnum.app,
    ),
    FeedBackModel(
      title: '影视资源',
      feedbackType: FeedBackTypeEnum.video,
    ),
    FeedBackModel(
      title: '播放卡顿',
      feedbackType: FeedBackTypeEnum.play,
    ),
    FeedBackModel(
      title: '分类错误',
      feedbackType: FeedBackTypeEnum.group,
    ),
    FeedBackModel(
      title: '充值问题',
      feedbackType: FeedBackTypeEnum.recharge,
    ),
    FeedBackModel(
      title: '其他问题',
      feedbackType: FeedBackTypeEnum.other,
    ),
  ];

  static const int maxFeedbackLength = 300;
}

class FeedBackModel {
  final String? title;
  final FeedBackTypeEnum? feedbackType;
  const FeedBackModel({
    this.title,
    this.feedbackType,
  });
}
