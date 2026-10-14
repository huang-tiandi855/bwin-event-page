/// 钱包余额（`/wallet/get` 的 `result` 字段）
///
/// 后端把各类「资源型余额」聚合到同一个对象里返回，全部为数值类型；为兼容
/// 后端可能返回整数 / 小数 / 字符串，统一使用 `double` 并做兜底解析。
class WalletBalanceModel {
  WalletBalanceModel({
    this.id,
    this.uid,
    this.points = 0,
    this.coins = 0,
    this.normalVipDays = 0,
    this.aiFaceSwapTimes = 0,
    this.aiUndressTimes = 0,
    this.movieTickets = 0,
    this.posting = 0,
    this.invitation = 0,
    this.video = 0,
    this.upload = 0,
    this.postingSum = 0,
    this.game = 0,
    this.app = 0,
  });

  /// 钱包 id
  int? id;

  /// 用户 id
  int? uid;

  /// 积分
  double points;

  /// 金币
  double coins;

  /// 普通会员剩余天数
  double normalVipDays;

  /// AI 换脸次数
  double aiFaceSwapTimes;

  /// AI 脱衣次数
  double aiUndressTimes;

  /// 电影票
  double movieTickets;

  /// 帖子创作收益余额
  double posting;

  /// 邀请相关余额
  double invitation;

  /// 视频相关余额
  double video;

  /// 上传相关余额
  double upload;

  /// 帖子创作累计收益
  double postingSum;

  /// 游戏余额
  double game;

  /// 应用余额
  double app;

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      id: _parseInt(json['id']),
      uid: _parseInt(json['uid']),
      points: _parseDouble(json['points']),
      coins: _parseDouble(json['coins']),
      normalVipDays: _parseDouble(json['normalVipDays']),
      aiFaceSwapTimes: _parseDouble(json['aiFaceSwapTimes']),
      aiUndressTimes: _parseDouble(json['aiUndressTimes']),
      movieTickets: _parseDouble(json['movieTickets']),
      posting: _parseDouble(json['posting']),
      invitation: _parseDouble(json['invitation']),
      video: _parseDouble(json['video']),
      upload: _parseDouble(json['upload']),
      postingSum: _parseDouble(json['postingSum']),
      game: _parseDouble(json['game']),
      app: _parseDouble(json['app']),
    );
  }

  /// 接口失败 / 无数据时使用的空对象，避免上层频繁判空。
  factory WalletBalanceModel.empty() => WalletBalanceModel();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'uid': uid,
        'points': points,
        'coins': coins,
        'normalVipDays': normalVipDays,
        'aiFaceSwapTimes': aiFaceSwapTimes,
        'aiUndressTimes': aiUndressTimes,
        'movieTickets': movieTickets,
        'posting': posting,
        'invitation': invitation,
        'video': video,
        'upload': upload,
        'postingSum': postingSum,
        'game': game,
        'app': app,
      };
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}
