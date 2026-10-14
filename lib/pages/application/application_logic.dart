import 'package:comics_app/common/entities/modules_config/module_model_extension.dart';
import 'package:comics_app/common/services/module_config_service.dart';
import 'package:comics_app/common/services/scroll_metrics_manager.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/event_bus/event_bus_util.dart';
import 'package:comics_app/common/websocket/websocket.dart';
import 'package:comics_app/common/websocket/ws_listen.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:get/get.dart';

import '../mine_index/logic.dart';
import '../short_video_main/play/short_video_play_logic.dart';
import 'application_state.dart';

class ApplicationLogic extends GetxController {
  final ApplicationState state = ApplicationState();

  @override
  void onInit() {
    super.onInit();
    FBroadcast.instance().register("entertainment_page", (value, callback) {
      Get.until((routes) {
        if (routes is GetPageRoute) {
          GetPageRoute getRoute = routes;
          if (getRoute.settings.name == "/applicationPage") {
            return true;
          }
        }
        return false;
      });
      handleNavBarTap(value ?? 3);
    });
    eventBus.on<InnerModel>(eventBusCallback);
    connectChat();
    refreshUserInfo();
  }

  void connectChat() {
    final url = ConfigStore.to.configBean.chatDomain ?? '';
    if (url.isEmpty) return;
    WSService.instance.connect(url);
    WSListen.instance.listen();
  }

  ///查一遍数据，以防token没过期，没走登录接口，导致用户信息没更新
  void refreshUserInfo() {
    UserStore.to.refreshUser();
  }

  void eventBusCallback(InnerModel model) {
    String host = model.routeName ?? "";

    if (host == 'module') {
      final module =
          ModuleConfigService.sharedInstance.fusion.firstWhereOrNull((element) {
        return element.id?.toString() == model.id;
      });
      AbsJumpModuleEvent? jumpEvent = module?.generateJumpEvent(model.id!);

      if (jumpEvent != null) {
        // 跳转tab再分发事件
        if (jumpEvent is HomeJumpModuleEvent) {
          state.homeJumpModuleEvent = jumpEvent;
          update(['home']);
          handleNavBarTap(0);
        } else if (jumpEvent is DouYinJumpModuleEvent) {
          state.douYinJumpModuleEvent = jumpEvent;
          update(['douyin']);
          handleNavBarTap(1);
        } else if (jumpEvent is AiJumpModuleEvent) {
          state.aiJumpModuleEvent = jumpEvent;
          update(['ai']);
          handleNavBarTap(2);
        } else if (jumpEvent is DarkJumpModuleEvent) {
          state.darkJumpModuleEvent = jumpEvent;
          update(['dark']);
          handleNavBarTap(3);
        } else if (jumpEvent is CommunityJumpModuleEvent) {
          state.communityJumpModuleEvent = jumpEvent;
          update(['community']);
          handleNavBarTap(4);
        } else if (jumpEvent is MineJumpModuleEvent) {
          state.mineJumpModuleEvent = jumpEvent;
          update(['mine']);
          handleNavBarTap(5);
        }
        // 事件分发到每个模块
        eventBus.emit(jumpEvent);
      }
    }
  }

  // tab栏动画
  void handleNavBarTap(int index) {
    final previousIndex = state.curTabIndex.value;
    if (state.curTabIndex.value == index) {
      // 必须与 application_state 里每一项的 listenerGroup 一致，不能用底栏 index
      // 直接塞进 ScrollMetricsGroup.fromValue（例如社区现为 index==4，应对 circle，
      // 但 fromValue('4') 会对不上，导致返回顶部无效）。
      ScrollMetricsGroup? group;
      for (final tab in state.tabs) {
        if (tab.index == index) {
          group = tab.listenerGroup;
          break;
        }
      }
      if (group != null) {
        final offset =
            ScrollMetricsManager.sharedInstance.getScrollOffset(group);
        if (offset > 0) {
          ScrollMetricsManager.sharedInstance.scrollToTop(group);
          return;
        }
      }
    }
    if (previousIndex == 1 && index != 1) {
      // 离开「抖音」一级 tab：除了暂停现有实例外，还要把全局抑制位置上，
      // 覆盖「leave 时 ShortVideoPlayLogic 还没注册（首屏 HTTP 还在飞）」
      // 的赛跑 —— 否则 logic 注册起来 [onInit] 触发 `_initVideo`，控制器
      // 初始化完成那一刻就把音频带出来。
      ShortVideoPlayLogic.pauseAndSuppressAll();
    } else if (previousIndex != 1 && index == 1) {
      // 回到「抖音」一级 tab：与 [pauseAndSuppressAll] 对称恢复。
      ShortVideoPlayLogic.resumeAndAllowAll();
    }
    state.curTabIndex.value = index;
    state.pageController.jumpToPage(index);

    switch (index) {
      case 0:
        Map map = {};

        map["链路"] = "首页";

        ConfigStore.to.trackData('首页浏览', map);

        setBottomBarColor(false);
        break;

      case 1:
        Map map = {};

        map["链路"] = "圈子";

        ConfigStore.to.trackData('圈子浏览', map);
        setBottomBarColor(false);
        break;

      case 2:
        Map map = {};

        map["链路"] = "AI";
        ConfigStore.to.trackData('AI浏览', map);
        setBottomBarColor(false);
        break;

      case 3:
        Map map = {};

        map["链路"] = "娱乐";

        ConfigStore.to.trackData('娱乐浏览', map);

        setBottomBarColor(true);

        break;

      case 4:
        Map map = {};

        map["链路"] = "书架";

        ConfigStore.to.trackData('书架浏览', map);
        setBottomBarColor(false);
        break;

      case 5:
        Map map = {};

        map["链路"] = "我的";
        // 切到「我的」时静默刷一次用户资料：拿最新 VIP / 金币 / AI 次数等，
        // 避免在其它页面消费完后回到我的还看到旧数据。
        //
        // 走 [silentRefreshUserInfo] 而不是 [refreshUserInfo]：后者会把
        // [PullRefreshController] 的内部状态一起重置，相当于在用户没下拉
        // 的情况下「假装」走了一次 SmartRefresher 流程；静默版只拉接口、
        // 不碰 controller，行为更干净。
        Get.find<MineIndexLogic>().silentRefreshUserInfo();
        ConfigStore.to.trackData('我的浏览', map);
        setBottomBarColor(false);
        break;
    }
  }

  void setBottomBarColor(bool isSelectOriginal) {
    ApplicationLogic logic = Get.find<ApplicationLogic>();

    logic.update();
  }
}
