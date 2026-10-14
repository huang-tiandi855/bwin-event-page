/// 基本任务状态
abstract class TaskState {
  // 更新进度
  void onUpdate(double progress, {dynamic msg, bool isSuccess});
  // // 完成
  // void onDone(dynamic done);
  // 错误
  void onError(Object error);
  // 取消
  bool isTaskCanceled();
  // bool isRunning();
}
