import 'package:get/get.dart';

class UserCenterBinding extends Bindings {
  @override
  void dependencies() {
    // `UserCenterLogic` 由 `_UserCenterPageState` 在 initState 中以路由实例
    // 唯一 tag 注册，并在 dispose 时强制释放，这里不再额外 lazyPut，避免遗留
    // 一个永远没人 find 的孤儿实例。
  }
}
