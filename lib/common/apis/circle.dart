// import 'package:comics_app/common/http/base_resp_bean.dart';
// import 'package:comics_app/common/http/http_request.dart';

// class CircleApi {
//   /// 热门话题
//   /// [pageNumber] 页码
//   /// [pageSize] 每页条数
//   static Future<BaseRespBean> getHtagList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/hotspot/wonder/list', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 获取发现帖子
//   /// [pageNumber] 页码
//   /// [pageSize] 每页条数
//   /// [reqDate] 时间
//   /// [tag] 标签
//   static Future<BaseRespBean> getCommunityList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/vid/community/list', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 关注或者取消博主
//   /// [followUID] 用户ID
//   /// [isFollow] 是否关注
//   static Future<BaseRespBean> careOrcancle(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().post('/mine/follow', data: data);
//     return baseRespBean;
//   }

//   ///打赏
//   static Future<BaseRespBean> rewardBlogger(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().post('/mine/reward', data: data);
//     return baseRespBean;
//   }

//   /// 获取关注帖子
//   /// [pageNumber] 页码
//   /// [pageSize] 每页条数
//   static Future<BaseRespBean> carePostList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/follow/dynamics/list', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 获取关注话题
//   /// [pageNumber] 页码
//   /// [pageSize] 每页条数
//   static Future<BaseRespBean> communityFollowTagList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/vid/community/tag/myCollect', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 标签详情
//   /// [tagID] 标签ID
//   static Future<BaseRespBean> getTagInfo(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/tag/info', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 标签详情 列表
//   /// [pageNumber] 页码
//   /// [pageSize] 每页条数
//   /// [tag] 标签
//   /// [sort] 排序 //排序(0最新 1最热)
//   static Future<BaseRespBean> getCommunityTagList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/vid/community/tag/list', queryParameters: data);
//     return baseRespBean;
//   }

//   static Future<BaseRespBean> getNewCommunityTagList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/tag/vid/list', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 帖子详情
//   /// [videoID] 视频ID
//   static Future<BaseRespBean> getPostInfo(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/vid/info', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 查询用户信息
//   /// [uid] 用户ID
//   static Future<BaseRespBean> getMineInfo(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/mine/info', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 收藏
//   /// [isCollect] 是否收藏
//   /// [objID] id
//   /// [type] 话题(标签)tag   短视频(SP)video   图文(COVER)img   影视（MOVIE）movie
//   static Future<BaseRespBean> tagCollect(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().post('/mine/collect', data: data);
//     return baseRespBean;
//   }

//   /// 获取收藏状态
//   static Future<BaseRespBean> isCollect(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().post('/mine/isCollect', data: data);
//     return baseRespBean;
//   }

//   /// 获取收藏
//   /// [pageNumber] 页码
//   /// [pageSize]  每页数量
//   /// [type] 标签  tag
//   /// [uid] 标签  用户id
//   static Future<BaseRespBean> getCollectList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/mine/collect/infoList', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 获取用户帖子、作品
//   /// [pageNumber] 页码
//   /// [pageSize] 每页数量
//   /// [type]    new
//   /// [newsType] SP 视频  COVER帖子
//   static Future<BaseRespBean> getMineCollcetion(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/mine/collection', queryParameters: data);
//     return baseRespBean;
//   }

//   static Future<BaseRespBean> getMineLike(int page, int size, int uid, {String? type}) async {
//     var queryParameters = {"page": page, "pageSize": size, "uid": uid, 'type': type}
//       ..removeWhere((key, value) => value == null);
//     BaseRespBean baseRespBean = await HttpRequest().get('/mine/like', queryParameters: queryParameters);
//     return baseRespBean;
//   }

//   static Future<BaseRespBean> getRecommendUser(int page, int size) async {
//     var queryParameters = {"page": page, "pageSize": size};
//     BaseRespBean baseRespBean = await HttpRequest().get('/recommend/user/list', queryParameters: queryParameters);
//     return baseRespBean;
//   }

//   /// 获取评论
//   /// [pageNumber] 页码
//   /// [pageSize] 每页数量
//   /// [curTime] 当前时间
//   /// [objID] 帖子id
//   static Future<BaseRespBean> getCommentList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/comment/list', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 获取评论详情
//   /// [pageNumber] 页码
//   /// [pageSize] 每页数量
//   /// [curTime] 当前时间
//   /// [objID] 帖子id
//   /// [fstID] 二级评论第一条数据的id
//   /// [cmtId] 评论id
//   static Future<BaseRespBean> getCommentInfo(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/comment/info', queryParameters: data);
//     return baseRespBean;
//   }

//   static Future<BaseRespBean> getSecondCommentList(String objID, String cmtId, String fstID, String curTime,
//       {int pageNumber = 1, int pageSize = 30}) async {
//     final param = <String, dynamic>{
//       'objID': objID,
//       'cmtId': cmtId,
//       'curTime': curTime,
//       'page': pageNumber,
//       'pageSize': pageSize,
//       'fstID': fstID,
//     };
//     BaseRespBean baseRespBean = await HttpRequest().get(
//       '/comment/info',
//       queryParameters: param,
//     );
//     return baseRespBean;
//   }

//   /// 点赞
//   /// [objID] id
//   /// [type] comment评论
//   static Future<BaseRespBean> thumbsUpApp(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().post('/thumbsUp', data: data);
//     return baseRespBean;
//   }

//   /// 取消点赞
//   /// [objID] id
//   /// [type] comment评论
//   static Future<BaseRespBean> thumbsDownApp(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().post('/thumbsDown', data: data);
//     return baseRespBean;
//   }

//   /// 获取关注列表
//   /// [pageNumber] pageNumber
//   /// [pageSize] pageSize
//   /// [uid] 用户id
//   static Future<BaseRespBean> getFollowList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/follow/list', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 获取粉丝列表
//   /// [pageNumber] pageNumber
//   /// [pageSize] pageSize
//   /// [uid] 用户id
//   static Future<BaseRespBean> getFansList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/follow/fans/list', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 产品购买
//   /// [productType] 产品类型(0 vip/1 video)  //动漫17    //漫画18    //cos19    //真人21  //禁播22 //29预售
//   /// [productID] 产品id
//   static Future<BaseRespBean> productBuy(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().post('/product/buy', data: data);
//     return baseRespBean;
//   }

//   /// 观阅券购买
//   /// [contentID] 产品id
//   static Future<BaseRespBean> ticketPurchasePaying(String id) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/vid/user/count', queryParameters: {"vid": id});
//     return baseRespBean;
//   }

//   /// 我的消息获取
//   /// [pageNumber] pageNumber
//   /// [pageSize] pageSize
//   static Future<BaseRespBean> getDynamicList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/msg/dynamic/list', queryParameters: data);
//     return baseRespBean;
//   }

//   /// 我的消息获取
//   /// [msgIDs] 消息id -- 不传的话，删除全部
//   static Future<BaseRespBean> msgDel(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().post('/msg/del', data: data);
//     return baseRespBean;
//   }

//   ///删除创作中心的帖子
//   static Future<BaseRespBean> delete(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().post('/vid/del', data: data);
//     return baseRespBean;
//   }

//   ///删除创作中心的帖子
//   static Future<BaseRespBean> getUserresourceList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/mine/userresource/list', queryParameters: data);
//     return baseRespBean;
//   }

//   ///获取推荐短视频
//   static Future<BaseRespBean> getRecommedVidList(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().get('/recommend/vid/list', queryParameters: data);
//     return baseRespBean;
//   }

//   static Future<BaseRespBean> vidPlay(data) async {
//     BaseRespBean baseRespBean = await HttpRequest().post('/vid/play', data: data);
//     return baseRespBean;
//   }
// }
