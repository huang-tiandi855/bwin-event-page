import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/comment_entity.dart';

CommentEntity $CommentEntityFromJson(Map<String, dynamic> json) {
	final CommentEntity commentEntity = CommentEntity();
	final bool? hasNext = jsonConvert.convert<bool>(json['hasNext']);
	if (hasNext != null) {
		commentEntity.hasNext = hasNext;
	}
	final int? lfCount = jsonConvert.convert<int>(json['lfCount']);
	if (lfCount != null) {
		commentEntity.lfCount = lfCount;
	}
	final List<CommentList>? list = jsonConvert.convertListNotNull<CommentList>(json['list']);
	if (list != null) {
		commentEntity.list = list;
	}
	final int? total = jsonConvert.convert<int>(json['total']);
	if (total != null) {
		commentEntity.total = total;
	}

	final List<CommentQuickSearchList>? quickSearchList = jsonConvert.convertListNotNull<CommentQuickSearchList>(json['quickSearchList']);
	if (quickSearchList != null) {
		commentEntity.quickSearchList = quickSearchList;
	}
	return commentEntity;
}

Map<String, dynamic> $CommentEntityToJson(CommentEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['hasNext'] = entity.hasNext;
	data['lfCount'] = entity.lfCount;
	data['list'] =  entity.list?.map((v) => v.toJson()).toList();
	data['total'] = entity.total;
	data['quickSearchList'] = entity.quickSearchList?.map((e) => e.toJson()).toList();
	return data;
}

CommentList $CommentListFromJson(Map<String, dynamic> json) {
	final CommentList commentList = CommentList();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		commentList.id = id;
	}
	final String? objID = jsonConvert.convert<String>(json['objID']);
	if (objID != null) {
		commentList.objID = objID;
	}
	final int? userID = jsonConvert.convert<int>(json['userID']);
	if (userID != null) {
		commentList.userID = userID;
	}
	final String? userName = jsonConvert.convert<String>(json['userName']);
	if (userName != null) {
		commentList.userName = userName;
	}
	final String? toUserName = jsonConvert.convert<String>(json['toUserName']);
	if (userName != null) {
		commentList.toUserName = toUserName;
	}
	final String? userPortrait = jsonConvert.convert<String>(json['userPortrait']);
	if (userPortrait != null) {
		commentList.userPortrait = userPortrait;
	}
	final String? content = jsonConvert.convert<String>(json['content']);
	if (content != null) {
		commentList.content = content;
	}
	final int? likeCount = jsonConvert.convert<int>(json['likeCount']);
	if (likeCount != null) {
		commentList.likeCount = likeCount;
	}
	final bool? isTop = jsonConvert.convert<bool>(json['isTop']);
	if (isTop != null) {
		commentList.isTop = isTop;
	}
	final bool? isHotComment = jsonConvert.convert<bool>(json['isHotComment']);
	if (isHotComment != null) {
		commentList.isHotComment = isHotComment;
	}
	final bool? isOfficial = jsonConvert.convert<bool>(json['isOfficial']);
	if (isOfficial != null) {
		commentList.isOfficial = isOfficial;
	}
	final int? commCount = jsonConvert.convert<int>(json['commCount']);
	if (commCount != null) {
		commentList.commCount = commCount;
	}
	final int? commCountBurden = jsonConvert.convert<int>(json['commCountBurden']);
	if (commCountBurden != null) {
		commentList.commCountBurden = commCountBurden;
	}
	final bool? isAuthor = jsonConvert.convert<bool>(json['isAuthor']);
	if (isAuthor != null) {
		commentList.isAuthor = isAuthor;
	}
	final bool? isLike = jsonConvert.convert<bool>(json['isLike']);
	if (isLike != null) {
		commentList.isLike = isLike;
	}
	final bool? isFollow = jsonConvert.convert<bool>(json['isFollow']);
	if (isFollow != null) {
		commentList.isFollow = isFollow;
	}
	final bool? isDelete = jsonConvert.convert<bool>(json['isDelete']);
	if (isDelete != null) {
		commentList.isDelete = isDelete;
	}
	final String? gender = jsonConvert.convert<String>(json['gender']);
	if (gender != null) {
		commentList.gender = gender;
	}
	final int? status = jsonConvert.convert<int>(json['status']);
	if (status != null) {
		commentList.status = status;
	}
	final String? city = jsonConvert.convert<String>(json['city']);
	if (city != null) {
		commentList.city = city;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		commentList.createdAt = createdAt;
	}
	final int? age = jsonConvert.convert<int>(json['age']);
	if (age != null) {
		commentList.age = age;
	}
	final int? level = jsonConvert.convert<int>(json['level']);
	if (level != null) {
		commentList.level = level;
	}
	final int? vipLevel = jsonConvert.convert<int>(json['vipLevel']);
	if (vipLevel != null) {
		commentList.vipLevel = vipLevel;
	}
	final dynamic awards = jsonConvert.convert<dynamic>(json['awards']);
	if (awards != null) {
		commentList.awards = awards;
	}
	final int? superUser = jsonConvert.convert<int>(json['superUser']);
	if (superUser != null) {
		commentList.superUser = superUser;
	}
	final String? vipExpireDate = jsonConvert.convert<String>(json['vipExpireDate']);
	if (vipExpireDate != null) {
		commentList.vipExpireDate = vipExpireDate;
	}
	final List<CommentList>? info = jsonConvert.convertListNotNull<CommentList>(json['Info']);
	if (info != null) {
		commentList.info = info;
	}
	final int? linkType = jsonConvert.convert<int>(json['linkType']);
	if (linkType != null) {
		commentList.linkType = linkType;
	}
	final String? searchKeyword = jsonConvert.convert<String>(json['searchKeyword']);
	if (searchKeyword != null) {
		commentList.searchKeyword = searchKeyword;
	}

	final String? linkStr = jsonConvert.convert<String>(json['linkStr']);
	if (linkStr != null) {
		commentList.linkStr = linkStr;
	}

	return commentList;
}

Map<String, dynamic> $CommentListToJson(CommentList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['objID'] = entity.objID;
	data['userID'] = entity.userID;
	data['userName'] = entity.userName;
	data['userPortrait'] = entity.userPortrait;
	data['content'] = entity.content;
	data['likeCount'] = entity.likeCount;
	data['commCount'] = entity.commCount;
	data['commCountBurden'] = entity.commCountBurden;
	data['isAuthor'] = entity.isAuthor;
	data['isLike'] = entity.isLike;
	data['isFollow'] = entity.isFollow;
	data['isDelete'] = entity.isDelete;
	data['gender'] = entity.gender;
	data['status'] = entity.status;
	data['city'] = entity.city;
	data['createdAt'] = entity.createdAt;
	data['age'] = entity.age;
	data['level'] = entity.level;
	data['vipLevel'] = entity.vipLevel;
	data['awards'] = entity.awards;
	data['superUser'] = entity.superUser;
	data['linkStr'] = entity.linkStr;
	data['linkType'] = entity.linkType;
	data['searchKeyword'] = entity.searchKeyword;
	data['vipExpireDate'] = entity.vipExpireDate;
	data['Info'] =  entity.info?.map((v) => v.toJson()).toList();
	return data;
}

CommentListInfo $CommentListInfoFromJson(Map<String, dynamic> json) {
	final CommentListInfo commentListInfo = CommentListInfo();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		commentListInfo.id = id;
	}
	final String? objID = jsonConvert.convert<String>(json['objID']);
	if (objID != null) {
		commentListInfo.objID = objID;
	}
	final String? cid = jsonConvert.convert<String>(json['cid']);
	if (cid != null) {
		commentListInfo.cid = cid;
	}
	final int? userID = jsonConvert.convert<int>(json['userID']);
	if (userID != null) {
		commentListInfo.userID = userID;
	}
	final String? userName = jsonConvert.convert<String>(json['userName']);
	if (userName != null) {
		commentListInfo.userName = userName;
	}
	final String? userPortrait = jsonConvert.convert<String>(json['userPortrait']);
	if (userPortrait != null) {
		commentListInfo.userPortrait = userPortrait;
	}
	final int? toUserID = jsonConvert.convert<int>(json['toUserID']);
	if (toUserID != null) {
		commentListInfo.toUserID = toUserID;
	}
	final String? toUserName = jsonConvert.convert<String>(json['toUserName']);
	if (toUserName != null) {
		commentListInfo.toUserName = toUserName;
	}
	final String? content = jsonConvert.convert<String>(json['content']);
	if (content != null) {
		commentListInfo.content = content;
	}
	final int? likeCount = jsonConvert.convert<int>(json['likeCount']);
	if (likeCount != null) {
		commentListInfo.likeCount = likeCount;
	}
	final bool? isLike = jsonConvert.convert<bool>(json['isLike']);
	if (isLike != null) {
		commentListInfo.isLike = isLike;
	}
	final bool? isAuthor = jsonConvert.convert<bool>(json['isAuthor']);
	if (isAuthor != null) {
		commentListInfo.isAuthor = isAuthor;
	}
	final bool? isTop = jsonConvert.convert<bool>(json['isTop']);
	if (isTop != null) {
		commentListInfo.isTop = isTop;
	}
	final bool? isHotComment = jsonConvert.convert<bool>(json['isHotComment']);
	if (isHotComment != null) {
		commentListInfo.isHotComment = isHotComment;
	}
	final bool? isFollow = jsonConvert.convert<bool>(json['isFollow']);
	if (isFollow != null) {
		commentListInfo.isFollow = isFollow;
	}
	final bool? isDelete = jsonConvert.convert<bool>(json['isDelete']);
	if (isDelete != null) {
		commentListInfo.isDelete = isDelete;
	}
	final String? gender = jsonConvert.convert<String>(json['gender']);
	if (gender != null) {
		commentListInfo.gender = gender;
	}
	final int? status = jsonConvert.convert<int>(json['status']);
	if (status != null) {
		commentListInfo.status = status;
	}
	final String? city = jsonConvert.convert<String>(json['city']);
	if (city != null) {
		commentListInfo.city = city;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		commentListInfo.createdAt = createdAt;
	}
	final int? age = jsonConvert.convert<int>(json['age']);
	if (age != null) {
		commentListInfo.age = age;
	}
	final int? level = jsonConvert.convert<int>(json['level']);
	if (level != null) {
		commentListInfo.level = level;
	}
	final int? vipLevel = jsonConvert.convert<int>(json['vipLevel']);
	if (vipLevel != null) {
		commentListInfo.vipLevel = vipLevel;
	}
	final dynamic awards = jsonConvert.convert<dynamic>(json['awards']);
	if (awards != null) {
		commentListInfo.awards = awards;
	}
	final int? superUser = jsonConvert.convert<int>(json['superUser']);
	if (superUser != null) {
		commentListInfo.superUser = superUser;
	}
	final String? vipExpireDate = jsonConvert.convert<String>(json['vipExpireDate']);
	if (vipExpireDate != null) {
		commentListInfo.vipExpireDate = vipExpireDate;
	}
	return commentListInfo;
}

Map<String, dynamic> $CommentListInfoToJson(CommentListInfo entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['objID'] = entity.objID;
	data['cid'] = entity.cid;
	data['userID'] = entity.userID;
	data['userName'] = entity.userName;
	data['userPortrait'] = entity.userPortrait;
	data['toUserID'] = entity.toUserID;
	data['toUserName'] = entity.toUserName;
	data['content'] = entity.content;
	data['likeCount'] = entity.likeCount;
	data['isLike'] = entity.isLike;
	data['isAuthor'] = entity.isAuthor;
	data['isTop'] = entity.isTop;
	data['isHotComment'] = entity.isHotComment;
	data['isFollow'] = entity.isFollow;
	data['isDelete'] = entity.isDelete;
	data['gender'] = entity.gender;
	data['status'] = entity.status;
	data['city'] = entity.city;
	data['createdAt'] = entity.createdAt;
	data['age'] = entity.age;
	data['level'] = entity.level;
	data['vipLevel'] = entity.vipLevel;
	data['awards'] = entity.awards;
	data['superUser'] = entity.superUser;
	data['vipExpireDate'] = entity.vipExpireDate;
	return data;
}

CommentQuickSearchList $CommentQuickSearchListFromJson(Map<String, dynamic> json) {
  final CommentQuickSearchList commentList = CommentQuickSearchList();
  final String? id = jsonConvert.convert<String>(json['id']);
  if (id != null) {
    commentList.id = id;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    commentList.title = title;
  }
  final String? searchKeyword = jsonConvert.convert<String>(json['searchKeyword']);
  if (searchKeyword != null) {
    commentList.searchKeyword = searchKeyword;
  }
  final String? userName = jsonConvert.convert<String>(json['userName']);
  if (userName != null) {
    commentList.userName = userName;
  }
  final String? link = jsonConvert.convert<String>(json['link']);
  if (link != null) {
    commentList.link = link;
  }
  final String? userPortrait = jsonConvert.convert<String>(json['userPortrait']);
  if (userPortrait != null) {
    commentList.userPortrait = userPortrait;
  }

  final int? linkType = jsonConvert.convert<int>(json['linkType']);
  if (linkType != null) {
    commentList.linkType = linkType;
  }
  final int? type = jsonConvert.convert<int>(json['type']);
  if (type != null) {
    commentList.type = type;
  }
  final int? gender = jsonConvert.convert<int>(json['gender']);
  if (gender != null) {
    commentList.gender = gender;
  }
  final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
  if (createdAt != null) {
    commentList.createdAt = createdAt;
  }
  final int? vipLevel = jsonConvert.convert<int>(json['vipLevel']);
  if (vipLevel != null) {
    commentList.vipLevel = vipLevel;
  }
  final String? vipExpireDate = jsonConvert.convert<String>(json['vipExpireDate']);
  if (vipExpireDate != null) {
    commentList.vipExpireDate = vipExpireDate;
  }

  return commentList;
}

Map<String, dynamic> $CommentQuickSearchListToJson(CommentQuickSearchList entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['title'] = entity.title;
  data['searchKeyword'] = entity.searchKeyword;
  data['searchKeyword'] = entity.userName;
  data['link'] = entity.link;
  data['linkType'] = entity.linkType;
  data['type'] = entity.type;
  data['userID'] = entity.userID;
  data['userName'] = entity.userName;
  data['userPortrait'] = entity.userPortrait;
  data['vipLevel'] = entity.vipLevel;
  data['gender'] = entity.gender;
  data['vipExpireDate'] = entity.vipExpireDate;
  data['gender'] = entity.gender;
  data['createdAt'] = entity.createdAt;
  return data;
}