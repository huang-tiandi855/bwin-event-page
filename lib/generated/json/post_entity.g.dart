import 'package:comics_app/common/entities/post_entity.dart';
import 'package:comics_app/generated/json/base/json_convert_content.dart';

PostEntity $PostEntityFromJson(Map<String, dynamic> json) {
  final PostEntity postEntity = PostEntity();
  final List<PostList>? list =
      jsonConvert.convertListNotNull<PostList>(json['list']);
  if (list != null) {
    postEntity.list = list;
  }
  final List<PostList>? vInfos =
      jsonConvert.convertListNotNull<PostList>(json['vInfos']);
  if (vInfos != null) {
    postEntity.vInfos = vInfos;
  }
  final bool? hasNext = jsonConvert.convert<bool>(json['hasNext']);
  if (hasNext != null) {
    postEntity.hasNext = hasNext;
  }
  return postEntity;
}

Map<String, dynamic> $PostEntityToJson(PostEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['list'] = entity.list?.map((v) => v.toJson()).toList();
  data['vInfos'] = entity.vInfos?.map((v) => v.toJson()).toList();
  data['hasNext'] = entity.hasNext;
  return data;
}

PostList $PostListFromJson(Map<String, dynamic> json) {
  final PostList postList = PostList();
  final String? id = jsonConvert.convert<String>(json['id']);
  if (id != null) {
    postList.id = id;
  }
  final String? newsType = jsonConvert.convert<String>(json['newsType']);
  if (newsType != null) {
    postList.newsType = newsType;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    postList.title = title;
  }
  final List<PostListTags>? tags =
      jsonConvert.convertListNotNull<PostListTags>(json['tags']);
  if (tags != null) {
    postList.tags = tags;
  }
  final String? sourceURL = jsonConvert.convert<String>(json['sourceURL']);
  if (sourceURL != null) {
    postList.sourceURL = sourceURL;
  }
  final int? playTime = jsonConvert.convert<int>(json['playTime']);
  if (playTime != null) {
    postList.playTime = playTime;
  }
  final String? cover = jsonConvert.convert<String>(json['cover']);
  if (cover != null) {
    postList.cover = cover;
  }
  final String? coverThumb = jsonConvert.convert<String>(json['coverThumb']);
  if (coverThumb != null) {
    postList.coverThumb = coverThumb;
  }
  final List<String>? seriesCover =
      jsonConvert.convertListNotNull<String>(json['seriesCover']);
  if (seriesCover != null) {
    postList.seriesCover = seriesCover;
  }
  final int? playCount = jsonConvert.convert<int>(json['playCount']);
  if (playCount != null) {
    postList.playCount = playCount;
  }
  final int? purchaseCount = jsonConvert.convert<int>(json['purchaseCount']);
  if (purchaseCount != null) {
    postList.purchaseCount = purchaseCount;
  }
  final int? likeCount = jsonConvert.convert<int>(json['likeCount']);
  if (likeCount != null) {
    postList.likeCount = likeCount;
  }
  final int? commentCount = jsonConvert.convert<int>(json['commentCount']);
  if (commentCount != null) {
    postList.commentCount = commentCount;
  }
  final int? shareCount = jsonConvert.convert<int>(json['shareCount']);
  if (shareCount != null) {
    postList.shareCount = shareCount;
  }
  final int? forwardCount = jsonConvert.convert<int>(json['forwardCount']);
  if (forwardCount != null) {
    postList.forwardCount = forwardCount;
  }
  final int? coins = jsonConvert.convert<int>(json['coins']);
  if (coins != null) {
    postList.coins = coins;
  }
  final int? size = jsonConvert.convert<int>(json['size']);
  if (size != null) {
    postList.size = size;
  }
  final String? resolution = jsonConvert.convert<String>(json['resolution']);
  if (resolution != null) {
    postList.resolution = resolution;
  }
  final String? seedLink = jsonConvert.convert<String>(json['seedLink']);
  if (seedLink != null) {
    postList.seedLink = seedLink;
  }
  final double? ratio = jsonConvert.convert<double>(json['ratio']);
  if (ratio != null) {
    postList.ratio = ratio;
  }
  final int? status = jsonConvert.convert<int>(json['status']);
  if (status != null) {
    postList.status = status;
  }
  final String? reason = jsonConvert.convert<String>(json['reason']);
  if (reason != null) {
    postList.reason = reason;
  }
  final int? freeTime = jsonConvert.convert<int>(json['freeTime']);
  if (freeTime != null) {
    postList.freeTime = freeTime;
  }
  final bool? isHideLocation =
      jsonConvert.convert<bool>(json['isHideLocation']);
  if (isHideLocation != null) {
    postList.isHideLocation = isHideLocation;
  }
  final bool? freeArea = jsonConvert.convert<bool>(json['freeArea']);
  if (freeArea != null) {
    postList.freeArea = freeArea;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    postList.createdAt = createdAt;
  }
  final String? reviewAt = jsonConvert.convert<String>(json['reviewAt']);
  if (reviewAt != null) {
    postList.reviewAt = reviewAt;
  }
  final bool? isTopping = jsonConvert.convert<bool>(json['isTopping']);
  if (isTopping != null) {
    postList.isTopping = isTopping;
  }
  final bool? isRecommend = jsonConvert.convert<bool>(json['isRecommend']);
  if (isRecommend != null) {
    postList.isRecommend = isRecommend;
  }
  final bool? isChoosen = jsonConvert.convert<bool>(json['isChoosen']);
  if (isChoosen != null) {
    postList.isChoosen = isChoosen;
  }
  final String? rewarded = jsonConvert.convert<String>(json['rewarded']);
  if (rewarded != null) {
    postList.rewarded = rewarded;
  }
  final int? originCoins = jsonConvert.convert<int>(json['originCoins']);
  if (originCoins != null) {
    postList.originCoins = originCoins;
  }
  final PostListPublisher? publisher =
      jsonConvert.convert<PostListPublisher>(json['publisher']);
  if (publisher != null) {
    postList.publisher = publisher;
  }
  final PostListLocation? location =
      jsonConvert.convert<PostListLocation>(json['location']);
  if (location != null) {
    postList.location = location;
  }
  final PostListVidStatus? vidStatus =
      jsonConvert.convert<PostListVidStatus>(json['vidStatus']);
  if (vidStatus != null) {
    postList.vidStatus = vidStatus;
  }
  final PostListComment? comment =
      jsonConvert.convert<PostListComment>(json['comment']);
  if (comment != null) {
    postList.comment = comment;
  }
  final PostListWatch? watch =
      jsonConvert.convert<PostListWatch>(json['watch']);
  if (watch != null) {
    postList.watch = watch;
  }
  final bool? isForWard = jsonConvert.convert<bool>(json['isForWard']);
  if (isForWard != null) {
    postList.isForWard = isForWard;
  }
  final int? forWardUser = jsonConvert.convert<int>(json['forWardUser']);
  if (forWardUser != null) {
    postList.forWardUser = forWardUser;
  }
  final String? forWardUserName =
      jsonConvert.convert<String>(json['forWardUserName']);
  if (forWardUserName != null) {
    postList.forWardUserName = forWardUserName;
  }

  final String? content = jsonConvert.convert<String>(json['content']);
  if (content != null) {
    postList.content = content;
  }

  final String? richText = jsonConvert.convert<String>(json['richText']);
  if (richText != null) {
    postList.richText = richText;
  }

  return postList;
}

Map<String, dynamic> $PostListToJson(PostList entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['newsType'] = entity.newsType;
  data['title'] = entity.title;
  data['tags'] = entity.tags?.map((v) => v.toJson()).toList();
  data['sourceURL'] = entity.sourceURL;
  data['playTime'] = entity.playTime;
  data['cover'] = entity.cover;
  data['coverThumb'] = entity.coverThumb;
  data['seriesCover'] = entity.seriesCover;
  data['playCount'] = entity.playCount;
  data['purchaseCount'] = entity.purchaseCount;
  data['likeCount'] = entity.likeCount;
  data['commentCount'] = entity.commentCount;
  data['shareCount'] = entity.shareCount;
  data['forwardCount'] = entity.forwardCount;
  data['coins'] = entity.coins;
  data['size'] = entity.size;
  data['resolution'] = entity.resolution;
  data['ratio'] = entity.ratio;
  data['status'] = entity.status;
  data['reason'] = entity.reason;
  data['freeTime'] = entity.freeTime;
  data['isHideLocation'] = entity.isHideLocation;
  data['freeArea'] = entity.freeArea;
  data['createdAt'] = entity.createdAt;
  data['reviewAt'] = entity.reviewAt;
  data['isTopping'] = entity.isTopping;
  data['isRecommend'] = entity.isRecommend;
  data['isChoosen'] = entity.isChoosen;
  data['rewarded'] = entity.rewarded;
  data['originCoins'] = entity.originCoins;
  data['publisher'] = entity.publisher?.toJson();
  data['location'] = entity.location?.toJson();
  data['vidStatus'] = entity.vidStatus?.toJson();
  data['comment'] = entity.comment?.toJson();
  data['watch'] = entity.watch?.toJson();
  data['isForWard'] = entity.isForWard;
  data['forWardUser'] = entity.forWardUser;
  data['forWardUserName'] = entity.forWardUserName;
  data['content'] = entity.content;
  data['richText'] = entity.richText;
  return data;
}

PostListTags $PostListTagsFromJson(Map<String, dynamic> json) {
  final PostListTags postListTags = PostListTags();
  final String? id = jsonConvert.convert<String>(json['id']);
  if (id != null) {
    postListTags.id = id;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    postListTags.name = name;
  }
  final String? coverImg = jsonConvert.convert<String>(json['coverImg']);
  if (coverImg != null) {
    postListTags.coverImg = coverImg;
  }
  final String? description = jsonConvert.convert<String>(json['description']);
  if (description != null) {
    postListTags.description = description;
  }
  final int? playCount = jsonConvert.convert<int>(json['playCount']);
  if (playCount != null) {
    postListTags.playCount = playCount;
  }
  final bool? hasCollected = jsonConvert.convert<bool>(json['hasCollected']);
  if (hasCollected != null) {
    postListTags.hasCollected = hasCollected;
  }
  return postListTags;
}

Map<String, dynamic> $PostListTagsToJson(PostListTags entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['name'] = entity.name;
  data['coverImg'] = entity.coverImg;
  data['description'] = entity.description;
  data['playCount'] = entity.playCount;
  data['hasCollected'] = entity.hasCollected;
  return data;
}

PostListPublisher $PostListPublisherFromJson(Map<String, dynamic> json) {
  final PostListPublisher postListPublisher = PostListPublisher();
  final int? uid = jsonConvert.convert<int>(json['uid']);
  if (uid != null) {
    postListPublisher.uid = uid;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    postListPublisher.name = name;
  }
  final String? gender = jsonConvert.convert<String>(json['gender']);
  if (gender != null) {
    postListPublisher.gender = gender;
  }
  final String? portrait = jsonConvert.convert<String>(json['portrait']);
  if (portrait != null) {
    postListPublisher.portrait = portrait;
  }
  final String? portraitFrame =
      jsonConvert.convert<String>(json['portraitFrame']);
  if (portrait != null) {
    postListPublisher.portraitFrame = portraitFrame;
  }
  final bool? hasLocked = jsonConvert.convert<bool>(json['hasLocked']);
  if (hasLocked != null) {
    postListPublisher.hasLocked = hasLocked;
  }
  final bool? hasBanned = jsonConvert.convert<bool>(json['hasBanned']);
  if (hasBanned != null) {
    postListPublisher.hasBanned = hasBanned;
  }
  final int? vipLevel = jsonConvert.convert<int>(json['vipLevel']);
  if (vipLevel != null) {
    postListPublisher.vipLevel = vipLevel;
  }
  final bool? isVip = jsonConvert.convert<bool>(json['isVip']);
  if (isVip != null) {
    postListPublisher.isVip = isVip;
  }
  final int? rechargeLevel = jsonConvert.convert<int>(json['rechargeLevel']);
  if (rechargeLevel != null) {
    postListPublisher.rechargeLevel = rechargeLevel;
  }
  final int? superUser = jsonConvert.convert<int>(json['superUser']);
  if (superUser != null) {
    postListPublisher.superUser = superUser;
  }
  final String? vipExpireDate =
      jsonConvert.convert<String>(json['vipExpireDate']);
  if (vipExpireDate != null) {
    postListPublisher.vipExpireDate = vipExpireDate;
  }

  final String? superUserExpire =
      jsonConvert.convert<String>(json['superUserExpire']);
  if (superUserExpire != null) {
    postListPublisher.superUserExpire = superUserExpire;
  }

  final String? officialCertExpire =
      jsonConvert.convert<String>(json['officialCertExpire']);
  if (officialCertExpire != null) {
    postListPublisher.officialCertExpire = officialCertExpire;
  }

  final String? videoFreeExpiration =
      jsonConvert.convert<String>(json['videoFreeExpiration']);
  if (videoFreeExpiration != null) {
    postListPublisher.videoFreeExpiration = videoFreeExpiration;
  }

  final int? activeValue = jsonConvert.convert<int>(json['activeValue']);
  if (activeValue != null) {
    postListPublisher.activeValue = activeValue;
  }
  final bool? officialCert = jsonConvert.convert<bool>(json['officialCert']);
  if (officialCert != null) {
    postListPublisher.officialCert = officialCert;
  }
  final int? age = jsonConvert.convert<int>(json['age']);
  if (age != null) {
    postListPublisher.age = age;
  }
  final int? follows = jsonConvert.convert<int>(json['follows']);
  if (follows != null) {
    postListPublisher.follows = follows;
  }
  final int? fans = jsonConvert.convert<int>(json['fans']);
  if (fans != null) {
    postListPublisher.fans = fans;
  }
  final String? summary = jsonConvert.convert<String>(json['summary']);
  if (summary != null) {
    postListPublisher.summary = summary;
  }
  final dynamic awards = jsonConvert.convert<dynamic>(json['awards']);
  if (awards != null) {
    postListPublisher.awards = awards;
  }
  final bool? hasFollowed = jsonConvert.convert<bool>(json['hasFollowed']);
  if (hasFollowed != null) {
    postListPublisher.hasFollowed = hasFollowed;
  }
  return postListPublisher;
}

Map<String, dynamic> $PostListPublisherToJson(PostListPublisher entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['uid'] = entity.uid;
  data['name'] = entity.name;
  data['gender'] = entity.gender;
  data['portrait'] = entity.portrait;
  data['portraitFrame'] = entity.portraitFrame;
  data['hasLocked'] = entity.hasLocked;
  data['hasBanned'] = entity.hasBanned;
  data['vipLevel'] = entity.vipLevel;
  data['isVip'] = entity.isVip;
  data['rechargeLevel'] = entity.rechargeLevel;
  data['superUser'] = entity.superUser;
  data['vipExpireDate'] = entity.vipExpireDate;
  data['activeValue'] = entity.activeValue;
  data['officialCert'] = entity.officialCert;
  data['age'] = entity.age;
  data['follows'] = entity.follows;
  data['fans'] = entity.fans;
  data['summary'] = entity.summary;
  data['awards'] = entity.awards;
  data['hasFollowed'] = entity.hasFollowed;
  return data;
}

PostListLocation $PostListLocationFromJson(Map<String, dynamic> json) {
  final PostListLocation postListLocation = PostListLocation();
  final String? id = jsonConvert.convert<String>(json['id']);
  if (id != null) {
    postListLocation.id = id;
  }
  final String? city = jsonConvert.convert<String>(json['city']);
  if (city != null) {
    postListLocation.city = city;
  }
  final String? cover = jsonConvert.convert<String>(json['cover']);
  if (cover != null) {
    postListLocation.cover = cover;
  }
  final int? visit = jsonConvert.convert<int>(json['visit']);
  if (visit != null) {
    postListLocation.visit = visit;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    postListLocation.createdAt = createdAt;
  }
  return postListLocation;
}

Map<String, dynamic> $PostListLocationToJson(PostListLocation entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['city'] = entity.city;
  data['cover'] = entity.cover;
  data['visit'] = entity.visit;
  data['createdAt'] = entity.createdAt;
  return data;
}

PostListVidStatus $PostListVidStatusFromJson(Map<String, dynamic> json) {
  final PostListVidStatus postListVidStatus = PostListVidStatus();
  final bool? hasLiked = jsonConvert.convert<bool>(json['hasLiked']);
  if (hasLiked != null) {
    postListVidStatus.hasLiked = hasLiked;
  }
  final bool? hasPaid = jsonConvert.convert<bool>(json['hasPaid']);
  if (hasPaid != null) {
    postListVidStatus.hasPaid = hasPaid;
  }
  final bool? hasCollected = jsonConvert.convert<bool>(json['hasCollected']);
  if (hasCollected != null) {
    postListVidStatus.hasCollected = hasCollected;
  }
  final int? todayRank = jsonConvert.convert<int>(json['todayRank']);
  if (todayRank != null) {
    postListVidStatus.todayRank = todayRank;
  }
  final int? todayPlayCnt = jsonConvert.convert<int>(json['todayPlayCnt']);
  if (todayPlayCnt != null) {
    postListVidStatus.todayPlayCnt = todayPlayCnt;
  }
  return postListVidStatus;
}

Map<String, dynamic> $PostListVidStatusToJson(PostListVidStatus entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['hasLiked'] = entity.hasLiked;
  data['hasPaid'] = entity.hasPaid;
  data['hasCollected'] = entity.hasCollected;
  data['todayRank'] = entity.todayRank;
  data['todayPlayCnt'] = entity.todayPlayCnt;
  return data;
}

PostListComment $PostListCommentFromJson(Map<String, dynamic> json) {
  final PostListComment postListComment = PostListComment();
  final int? uid = jsonConvert.convert<int>(json['uid']);
  if (uid != null) {
    postListComment.uid = uid;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    postListComment.name = name;
  }
  final String? portrait = jsonConvert.convert<String>(json['portrait']);
  if (portrait != null) {
    postListComment.portrait = portrait;
  }
  final String? cid = jsonConvert.convert<String>(json['cid']);
  if (cid != null) {
    postListComment.cid = cid;
  }
  final String? content = jsonConvert.convert<String>(json['content']);
  if (content != null) {
    postListComment.content = content;
  }
  final int? likeCount = jsonConvert.convert<int>(json['likeCount']);
  if (likeCount != null) {
    postListComment.likeCount = likeCount;
  }
  final bool? isAuthor = jsonConvert.convert<bool>(json['isAuthor']);
  if (isAuthor != null) {
    postListComment.isAuthor = isAuthor;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    postListComment.createdAt = createdAt;
  }
  return postListComment;
}

Map<String, dynamic> $PostListCommentToJson(PostListComment entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['uid'] = entity.uid;
  data['name'] = entity.name;
  data['portrait'] = entity.portrait;
  data['cid'] = entity.cid;
  data['content'] = entity.content;
  data['likeCount'] = entity.likeCount;
  data['isAuthor'] = entity.isAuthor;
  data['createdAt'] = entity.createdAt;
  return data;
}

PostListWatch $PostListWatchFromJson(Map<String, dynamic> json) {
  final PostListWatch postListWatch = PostListWatch();
  final int? watchCount = jsonConvert.convert<int>(json['watchCount']);
  if (watchCount != null) {
    postListWatch.watchCount = watchCount;
  }
  final bool? isWatch = jsonConvert.convert<bool>(json['isWatch']);
  if (isWatch != null) {
    postListWatch.isWatch = isWatch;
  }
  final bool? isFreeWatch = jsonConvert.convert<bool>(json['isFreeWatch']);
  if (isFreeWatch != null) {
    postListWatch.isFreeWatch = isFreeWatch;
  }
  return postListWatch;
}

Map<String, dynamic> $PostListWatchToJson(PostListWatch entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['watchCount'] = entity.watchCount;
  data['isWatch'] = entity.isWatch;
  data['isFreeWatch'] = entity.isFreeWatch;
  return data;
}
