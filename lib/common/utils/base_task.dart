import 'dart:async';
import 'package:comics_app/common/utils/task_state.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';


///进度回传函数
///[value] 进度，
///[msg]其他负载消息
///  isSuccess 是否可以删除掉？？ 按照onError原则应该是可以及时返回的，过程中间给success是否有其他考虑？？
///
////// 规定helper从不主动调用onDone
/// task才有调用onDone()的权利
typedef ProgressChanged = void Function(double progress,
    {dynamic msg, bool? isSuccess});

/// 基础任务,给一些默认的属性和变量赋值
/// [B] 返回类型
abstract class BaseTask<B> extends TaskState {
  bool _cancel = false;
  bool running = false;
  ProgressChanged? updateListener;
  DateTime startTime = DateTime.now();
  final String _taskId;
  Completer<B>? completer;
  // 当前任务进度
  double _nowProgress = .0;
  // 获取当前的任务进度度
  double get getNowProgress => _nowProgress;
  // 任务进度控制器
  final StreamController<double> _progressController = StreamController.broadcast();
  // 获取任务进度的流
  Stream<double> get onProgressUpdate => _progressController.stream;

  BaseTask({String? taskId, this.updateListener}) : _taskId = taskId ?? const Uuid().v1();

  Future<B> execute() {
    completer = Completer();
    sonDoExecute();
    return getFuture;
  }

  /// 儿子干事情
  void sonDoExecute();

  String get getTaskId => _taskId;

  @override
  void onUpdate(double progress, {dynamic msg, bool? isSuccess}) {
    _nowProgress = progress;
    _progressController.add(_nowProgress);
    updateListener?.call(progress, msg: msg ?? "", isSuccess: isSuccess ?? false);
  }

  ///配置回调
  Future<B> configUpdateCallback(ProgressChanged updateListener) {
    this.updateListener = updateListener;
    return getFuture;
  }

  void onDone(B done) {
    Logger().i("taskmanager", "call onDone()...$done completer?:${null == completer}");
    _progressController.close();
    completer?.complete(done);
    completer = null;
  }

  @override
  void onError(Object error) {
    Logger().i("taskmanager", "call onError()...$error completer?:${null == completer}");
    completer?.completeError(error);
    completer = null;
  }

  cancelTask() {
    _cancel = true;
    completer?.completeError('cancelTask');
    completer = null;
  }

  @override
  bool isTaskCanceled() => _cancel;

  bool isRunning() => running;

  Future<B> get getFuture => completer!.future;
}
