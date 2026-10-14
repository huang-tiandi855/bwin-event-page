import 'dart:async';

import 'package:event_bus/event_bus.dart';

typedef EventCallback<T> = void Function(T event);

class EventBusUtil {
  //保存单例
  static final EventBusUtil _instance = EventBusUtil._internal();

  //工厂构造函数
  factory EventBusUtil() => _instance;

  //初始化eventBus
  late EventBus _eventBus;

  EventBusUtil._internal() {
    // 初始化
    _eventBus = EventBus();
  }

  /// 订阅stream列表
  // List<StreamSubscription> subscriptionList;

  /// 开启eventbus订阅 并
  StreamSubscription on<T>(EventCallback<T> callback) {
    StreamSubscription stream = _eventBus.on<T>().listen((event) {
      callback(event);
    });
    // subscriptionList.add(stream);
    return stream;
  }

  /// 发送消息
  void emit(event) {
    _eventBus.fire(event);
  }

  /// 移除steam
  void off(StreamSubscription steam) {
    steam.cancel();
  }
}

var eventBus = EventBusUtil._instance;

class CollectStatusModel {
  String? id;
  bool? isCollected;
  String? type;
  CollectStatusModel({this.id, this.isCollected, this.type});
}

class InnerModel {
  String? routeName;
  String? id;
  String? type;
  InnerModel({this.routeName, this.id, this.type});
}

enum JumpModuleType {
  home,
  douyin,
  dark,
  community,
  mine,
  ai,
}

abstract class AbsJumpModuleEvent {
  final JumpModuleType? type;
  final String? id;
  AbsJumpModuleEvent({this.type, this.id});
}

class HomeJumpModuleEvent extends AbsJumpModuleEvent {
  final int? subModuleType;
  HomeJumpModuleEvent({
    required String id,
    required this.subModuleType,
  }) : super(type: JumpModuleType.home, id: id);
}

class DouYinJumpModuleEvent extends AbsJumpModuleEvent {
  DouYinJumpModuleEvent({required String id})
      : super(type: JumpModuleType.douyin, id: id);
}

class DarkJumpModuleEvent extends AbsJumpModuleEvent {
  DarkJumpModuleEvent({required String id})
      : super(type: JumpModuleType.dark, id: id);
}

class CommunityJumpModuleEvent extends AbsJumpModuleEvent {
  CommunityJumpModuleEvent({required String id})
      : super(type: JumpModuleType.community, id: id);
}

class MineJumpModuleEvent extends AbsJumpModuleEvent {
  MineJumpModuleEvent({required String id})
      : super(type: JumpModuleType.mine, id: id);
}

class CirclePhotoJumpModuleEvent extends AbsJumpModuleEvent {
  CirclePhotoJumpModuleEvent({required String id})
      : super(type: JumpModuleType.community, id: id);
}

class AiJumpModuleEvent extends AbsJumpModuleEvent {
  AiJumpModuleEvent({required String id})
      : super(type: JumpModuleType.ai, id: id);
}