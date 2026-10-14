import 'package:comics_app/common/entities/mine/question_tree_model.dart';

/// 常见问题（官方客服）页面状态
class CommonProblemState {
  /// 当前选中的分类下标
  int currentTab = 0;

  /// 是否正在拉取分类/问答数据
  bool loading = false;

  /// 分类列表（顶层节点：`answer` 当作分类标题，`child` 为该分类下的问答），
  /// 由 `chat/question/tree` 接口直接填充。
  List<QuestionTreeModel> categories = <QuestionTreeModel>[];

  /// 聊天消息列表（按时间顺序：用户气泡、客服气泡交替）
  final List<CommonProblemChatItem> messages = <CommonProblemChatItem>[];
}

/// 聊天气泡
class CommonProblemChatItem {
  final bool isUser;

  /// 用户气泡的文本（客服气泡为空）
  final String text;

  /// 客服气泡对应的问答节点（用户气泡为 null）
  final QuestionTreeModel? qa;

  const CommonProblemChatItem.user(this.text)
      : isUser = true,
        qa = null;

  const CommonProblemChatItem.bot(QuestionTreeModel this.qa)
      : isUser = false,
        text = '';
}
