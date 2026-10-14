import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:flutter/material.dart';

import '../../../../common/entities/wallet_balance_model.dart';

class AgentPromotionState {
  final GlobalKey boundaryKey = GlobalKey();
  static const String avatarPlaceholder =
      'https://i.pinimg.com/originals/0b/75/7c/0b757c02ace9a69e1959f1ce6273b74b.jpg';

  String userName = '';
  String? userPortrait;

  /// 可提现余额
  double withdrawableReward = 0.0;

  WalletBalanceModel? walletBalanceModel;

  /// 邀请码链接
  String shareLink = (Address.shareUrlLink ?? '') +
      (UserStore.to.getUserInfoModel?.invitationCode ?? '');

  /// 累计邀请人数
  int inviteCount = 0;

  /// 邀请码
  String inviteCode = 'EERRETTYY';
}
