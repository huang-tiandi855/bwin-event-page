import 'package:comics_app/common/entities/mine/question_tree_model.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

class CommonProblemPage extends StatelessWidget {
  CommonProblemPage({Key? key}) : super(key: key);

  final CommonProblemLogic logic = Get.put(CommonProblemLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar('官方客服'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _HelpHeader(onTap: logic.goCustomerService),
            SizedBox(height: 16.w),
            Expanded(
              child: GetBuilder<CommonProblemLogic>(
                builder: (_) => _Body(logic: logic),
              ),
            ),
            _BottomServiceButton(onTap: logic.goCustomerService),
          ],
        ),
      ),
    );
  }
}

/// 顶部：💡 需要人工帮助? 召唤人工客服
class _HelpHeader extends StatelessWidget {
  const _HelpHeader({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(.05),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 14)),
          SizedBox(width: 4.w),
          Text(
            '需要人工帮助?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 13.w),
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              '召唤人工客服',
              style: TextStyle(
                color: AppColor.primaryButtonColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 中间内容：分类卡片 + 聊天消息
class _Body extends StatelessWidget {
  const _Body({required this.logic});

  final CommonProblemLogic logic;

  @override
  Widget build(BuildContext context) {
    final state = logic.state;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
      children: [
        _CategoryCard(logic: logic),
        if (state.messages.isNotEmpty) SizedBox(height: 12.w),
        for (final msg in state.messages) ...[
          _ChatBubble(
              message: msg, onCallCustomerService: logic.goCustomerService),
          SizedBox(height: 12.w),
        ],
      ],
    );
  }
}

/// 分类卡片（4 个 tab + 问答列表 + "没有更多了"）
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.logic});

  final CommonProblemLogic logic;

  @override
  Widget build(BuildContext context) {
    final state = logic.state;
    final category = logic.currentCategory;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: category == null
          ? _CategoryPlaceholder(loading: state.loading)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TabBar(
                  categories: state.categories,
                  currentIndex: state.currentTab,
                  onTap: logic.switchTab,
                ),
                SizedBox(height: 14.w),
                for (int i = 0; i < category.child.length; i++)
                  _QuestionRow(
                    order: i + 1,
                    qa: category.child[i],
                    onTap: () => logic.onQuestionTap(category.child[i]),
                  ),
                SizedBox(height: 6.w),
                Center(
                  child: Text(
                    '没有更多了',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.4),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// 分类未加载完成或为空时的占位
class _CategoryPlaceholder extends StatelessWidget {
  const _CategoryPlaceholder({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.w),
      child: Center(
        child: loading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                '暂无常见问题',
                style: TextStyle(
                  color: Colors.white.withOpacity(.4),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }
}

/// 顶部分类 tab 行（带红色下划线指示器）
class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.categories,
    required this.currentIndex,
    required this.onTap,
  });

  final List<QuestionTreeModel> categories;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < categories.length; i++) ...[
          _TabItem(
            title: categories[i].answer ?? '',
            selected: i == currentIndex,
            onTap: () => onTap(i),
          ),
          if (i != categories.length - 1) SizedBox(width: 16.w),
        ],
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white.withOpacity(.5),
              fontSize: 14.sp,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.w),
          Container(
            height: 2.w,
            width: 20.w,
            decoration: BoxDecoration(
              color:
                  selected ? AppColor.primaryButtonColor : Colors.transparent,
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.order,
    required this.qa,
    required this.onTap,
  });

  final int order;
  final QuestionTreeModel qa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.w),
        child: Text(
          '$order.${qa.question ?? ''}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// 聊天气泡（用户问 / 客服答）
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.onCallCustomerService,
  });

  final CommonProblemChatItem message;
  final VoidCallback onCallCustomerService;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: 0.7.sw),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
          decoration: BoxDecoration(
            color: AppColor.primaryButtonColor,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final qa = message.qa!;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: qa.answer ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.06),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '需要人工帮助?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: onCallCustomerService,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      '召唤人工客服',
                      style: TextStyle(
                        color: AppColor.primaryButtonColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 底部：人工客服 按钮
class _BottomServiceButton extends StatelessWidget {
  const _BottomServiceButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w, 16.w),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 48.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.primaryButtonColor,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Text(
            '人工客服',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
