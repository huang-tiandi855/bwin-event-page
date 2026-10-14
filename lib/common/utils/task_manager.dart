
import 'package:comics_app/common/utils/text_util.dart';
import 'package:logger/logger.dart';
import 'base_task.dart';

final taskManager = TaskManager();

/// 任务管理器，支持多文件同时上传下载
class TaskManager {
  //文件上传和下载队列，这个map是上传下载的状态管理，并不会做去除重复的操作
  final Map<String, BaseTask> _tasks = {};
  final Map<String, BaseTask> _failedTasks = {};

  /// 添加一个新的任务
  Future<B> addTaskToQueue<B>(BaseTask<B> task, [ProgressChanged? onUpdate]) {
    if (null != onUpdate && task.updateListener != onUpdate) {
      task.updateListener = onUpdate;
    }
    var taskId = task.getTaskId;
    _tasks[taskId] = task;
    task.execute().then((v) {
      Logger().i("taskmanager",
          "task done...remove taskId:$taskId ret:${v.toString()}");
      _tasks.remove(taskId);
    }).catchError((e) {
      _tasks.remove(taskId);
      Logger().i("taskmanager",
          "task error...add to failTaskList taskId:$taskId error:$e");
      _failedTasks[taskId] = task;
    }); // 异步处理
    return task.getFuture;
  }

  /// 等待任务完成
  Future waitTask(String taskId) async {
    if (TextUtil.isEmpty(taskId)) return null;
    // Future.delayed(Duration())
    Logger().i("taskmanager", "waitTask()...:$taskId existTask:${existTask(taskId)}");
    return _tasks[taskId]?.getFuture;
  }

  ///重试
  void retry(String taskId) {
    if (_tasks.containsKey(taskId)) {
      Logger().i("taskmanager", "retry()...success taskId:$taskId");
      _tasks[taskId]?.execute();
    } else if (_failedTasks.containsKey(taskId)) {
      Logger().i("taskmanager", "retry()...success in failtaskList taskId:$taskId");
      var task = _failedTasks[taskId];
      _tasks[taskId] = task!;
      _tasks[taskId]?.execute();
    } else {
      Logger().i("taskmanager", "retry()...not found task:$taskId");
    }
  }

  ///监听上传进度
  Future<dynamic> configUpdateCallback(
      String taskId, ProgressChanged updateListener) {
    if (_tasks.containsKey(taskId)) {
      return _tasks[taskId]!.configUpdateCallback(updateListener);
    }
    return Future.value(false);
  }

  /// 从队列中移除一个任务
  void removeTask(String taskId) {
    if (!_tasks.containsKey(taskId)) return;

    Future.microtask(() {
      _tasks.remove(taskId);
    });
    }

  /// 取消单次任务
  void cancelTask(String taskId) {
    _tasks.remove(taskId)?.cancelTask();
    _failedTasks.remove(taskId)?.cancelTask();
  }

  ///取消所有上传下载任务
  void clearAllTasks() {
    _tasks.forEach((_, task) => task.cancelTask());
    _tasks.clear();
    _failedTasks.forEach((_, task) => task.cancelTask());
    _failedTasks.clear();
  }

  bool existTask(String taskId) {
    if (TextUtil.isEmpty(taskId)) return false;
    return null != _tasks[taskId];
  }

  // 获取当前的任务进度度
  double getNowProgress(String taskId) {
    if (TextUtil.isEmpty(taskId)) return -1.0;
    return _tasks[taskId]?.getNowProgress ?? -1.0;
  }

  // 获取任务进度的流
  Stream<double>? onProgressUpdate(String taskId) {
    if (TextUtil.isEmpty(taskId)) return null;
    return _tasks[taskId]?.onProgressUpdate;
  }
}
