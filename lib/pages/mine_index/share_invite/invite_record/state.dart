import 'package:comics_app/common/entities/mine/invite_record_model.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

/// 邀请记录页状态
class InviteRecordState {
  /// 每页条数
  static const int pageSize = 20;

  /// 下拉刷新 + 上拉加载控制器
  final PullRefreshController pullRefreshController = PullRefreshController();

  /// 当前请求的页码（从 1 开始）
  int page = 1;

  /// 累计加载到的邀请用户列表
  List<InviteUserModel> records = <InviteUserModel>[];

  /// 后端返回的总数（用于「已邀请X人」之类的统计）
  int total = 0;
}
