import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/entities/chat/user_chat_record_dto.dart';
import '../../../common/utils/date_util.dart';
import '../../../common/widgets/general_widget/common_widget.dart';
import '../../../common/widgets/indicators/filled_rounded_rect_tab_indicator.dart';
import 'logic.dart';
import 'state.dart';

class MessageCenterPage extends StatelessWidget {
  MessageCenterPage({Key? key}) : super(key: key);

  final MessageCenterLogic logic = Get.put(MessageCenterLogic());

  static const _tabs = <String>['私信', '评论', '点赞'];

  @override
  Widget build(BuildContext context) {
    final state = logic.state;
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColor.scaffoldBackground,
        appBar: commonAppBar(
          '我的消息',
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(44.w),
            child: const _MessageTabBar(tabs: _tabs),
          ),
        ),
        body: TabBarView(
          children: [
            _MessageList(
              items: state.directMessages,
              onItemTap: (type, item) => logic.onItemTap(type, item),
              showDivider: false,
              type: MessageType.direct,
            ),
            _MessageList(
              items: state.commentMessages,
              onItemTap: (type, item) => logic.onItemTap(type, item),
              type: MessageType.comment,
            ),
            _MessageList(
              items: state.likeMessages,
              onItemTap: (type, item) => logic.onItemTap(type, item),
              type: MessageType.like,
            ),
          ],
        ),
      ),
    );
  }
}

/// AppBar 底部的 TabBar
class _MessageTabBar extends StatelessWidget {
  const _MessageTabBar({required this.tabs});

  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 80.w),
      child: TabBar(
        isScrollable: false,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: FilledRoundedRectTabIndicator(
          color: AppColor.primaryButtonColor,
          width: 11.w,
          height: 4.w,
          borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
        ),
        labelColor: const Color(0xFFFAFAFA),
        unselectedLabelColor: const Color(0xFFC8C8C8),
        labelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
        tabs: tabs.map((e) => Tab(text: e)).toList(),
      ),
    );
  }
}

/// 消息列表
class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.items,
    required this.onItemTap,
    this.showDivider = true,
    required this.type,
  });

  final List<ChatLoaclRecordItem> items;
  final Function(MessageType, UserChatRecordDto) onItemTap;
  final MessageType type;

  /// 是否在条目之间显示分割线（私信无分割线，评论 / 点赞需要）
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return getEmptyWidget();
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.w,
        16.w,
        MediaQuery.paddingOf(context).bottom + 24.w,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => showDivider
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 12.w),
              child: Container(
                height: 1,
                color: Colors.white.withOpacity(.15),
              ),
            )
          : SizedBox(height: 22.w),
      itemBuilder: (_, index) => _MessageRow(
        item: items[index].message!,
        type: type,
        onTap: () => onItemTap(type, items[index].message!),
      ),
    );
  }
}

/// 单条消息：头像 + 右侧主体
class _MessageRow extends StatelessWidget {
  const _MessageRow(
      {required this.item, required this.onTap, required this.type});

  final UserChatRecordDto item;
  final VoidCallback onTap;
  final MessageType type;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: CustomImage(
              url: item.contactAvatar?.url,
              width: 40.w,
              height: 40.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(child: _MessageBody(item: item, type: type)),
        ],
      ),
    );
  }
}

/// 头像右侧主体内容（按类型布局）
class _MessageBody extends StatelessWidget {
  const _MessageBody({required this.item, required this.type});

  final UserChatRecordDto item;
  final MessageType type;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(type),
        if (_hasSecondLine) ...[
          SizedBox(height: 6.w),
          Text(
            item.chatRecord.firstOrNull?.msg ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(.5),
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
        if (type == MessageType.comment || type == MessageType.like) ...[
          SizedBox(height: 12.w),
          const _ReplyContent(
            cover: "item.videoCover",
            title: "item.videoTitle!",
          ),
        ],
      ],
    );
  }

  /// 私信 / 评论：第一行只显示 用户名 + 时间；正文放第二行
  /// 点赞：第一行 用户名 + "赞了你" + 时间；无第二行
  bool get _hasSecondLine =>
      type == MessageType.direct || type == MessageType.comment;

  Widget _buildHeader(MessageType type) {
    final nameStyle = TextStyle(
      color: Colors.white,
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
    );
    final timeStyle = TextStyle(
      color: Colors.white.withOpacity(.5),
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
    );

    if (type == MessageType.like) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(item.contactInfo?.nickName ?? '', style: nameStyle),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              item.chatRecord.firstOrNull?.msg ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(.5),
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
              DataFormats.showMilliSecondsDateDesc(
                  item.chatRecord.firstOrNull?.crtDate ?? 0),
              style: timeStyle),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            item.contactInfo?.nickName ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: nameStyle,
          ),
        ),
        Text(
            DataFormats.showMilliSecondsDateDesc(
                item.chatRecord.firstOrNull?.crtDate ?? 0),
            style: timeStyle),
      ],
    );
  }
}

/// 评论 / 点赞引用的视频卡片
class _ReplyContent extends StatelessWidget {
  const _ReplyContent({required this.cover, required this.title});

  final String? cover;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: CustomImage(
              url: cover,
              width: 50.w,
              height: 50.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(.5),
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
