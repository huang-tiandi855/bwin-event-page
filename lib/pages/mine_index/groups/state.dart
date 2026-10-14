import '../../../common/entities/group_model.dart';
import '../../../common/store/config.dart';

/// 加群开车 — 单个分组区块（接口返回后可整体替换 [GroupsState.sections]）

class GroupsState {
  List<GroupModel> officialCommunity = [];
  List<GroupModel> businessCooperation = [];

  GroupsState() {
    officialCommunity = ConfigStore.to.configBean.officialCommunity ?? [];
    businessCooperation = ConfigStore.to.configBean.businessCooperation ?? [];
  }
}
