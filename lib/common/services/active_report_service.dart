import 'dart:async';

import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/utils/logger.dart';

/// 用户活跃上报：登录成功后启动，
///
/// 立即上报一次，之后每 30 秒上报；[start] 幂等，重复调用不会叠加多个定时器。
class ActiveReportService {
  ActiveReportService._();
  static final ActiveReportService instance = ActiveReportService._();

  static const String _TAG = 'ActiveReportService';
  static const Duration _interval = Duration(seconds: 30);

  Timer? _timer;
  bool _started = false;

  /// 启动活跃上报（进程级，Splash 销毁后仍继续）。
  void start() {
    if (_started) return;
    _started = true;
    unawaited(_report());
    _timer = Timer.periodic(_interval, (_) => unawaited(_report()));
    l.d('started', tag: _TAG);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _started = false;
  }

  Future<void> _report() async {
    try {
      await UserApi.activeReport();
    } catch (e) {
      l.d('active report failed: $e', tag: _TAG);
    }
  }
}
