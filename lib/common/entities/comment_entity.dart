import 'dart:convert';
import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/comment_entity.g.dart';

@JsonSerializable()
class CommentEntity {

	bool? hasNext;
	int? lfCount;
	List<CommentList>? list;
	int? total;
	List<CommentQuickSearchList>? quickSearchList;
  CommentEntity();

  factory CommentEntity.fromJson(Map<String, dynamic> json) => $CommentEntityFromJson(json);

  Map<String, dynamic> toJson() => $CommentEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class LinkRichFormat {
	String title;
	bool isRich;
	LinkRichFormat(this.title, this.isRich);
}

@JsonSerializable()
class CommentQuickSearchList {
	String? id;
	String? title;
	String? searchKeyword;
	String? link;
	int? linkType;
	int? type;
	int? userID;
	String? userName;
	String? userPortrait;
	int? gender;
	int? vipLevel;
	String? vipExpireDate;
	String? createdAt;

	List<LinkRichFormat>? _richArr;
	List<LinkRichFormat> get richArr{ // "dfs33df"
		if(_richArr == null && searchKeyword?.isNotEmpty == true){
			_richArr = [];
			if(title?.contains(searchKeyword!) == true){
				var itemArr = title!.split(searchKeyword!);
				for(int i = 0; i < itemArr.length; i++){
					_richArr!.add(LinkRichFormat(itemArr[i], false));
					if(i != itemArr.length - 1) {
						_richArr!.add(LinkRichFormat(searchKeyword!, true));
					}
				}
			}else {
				_richArr!.add(LinkRichFormat(title ?? "", false));
			}
		}
		return _richArr!;
	}

	CommentQuickSearchList();

	factory CommentQuickSearchList.fromJson(Map<String, dynamic> json) => $CommentQuickSearchListFromJson(json);

	Map<String, dynamic> toJson() => $CommentQuickSearchListToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class CommentList {

	String? id;
	String? objID;
	int? userID;
	String? userName;
	String? userPortrait;
	String? content;
	int? likeCount;
	int? commCount;
	int? commCountBurden;
	bool? isAuthor;
	bool? isLike;
	bool? isFollow;
	bool? isDelete;
	bool? isTop;
	bool? isHotComment;
	bool? isOfficial;
	String? gender;
	int? status;
	String? city;
	String? createdAt;
	int? age;
	int? level;
	int? vipLevel;
	dynamic awards;
	int? superUser;
	String? vipExpireDate;
	String? toUserName;
	@JSONField(name: "Info")
	List<CommentList>? info;
	int? linkType;
	String? searchKeyword;
	String? linkStr;
	/// true 隐藏 false 显示

  CommentList();

	bool get isHideLikeOrComment{
		return ((linkType == 1 || linkType == 2) && linkStr?.isNotEmpty == true && searchKeyword?.isNotEmpty == true || userID == 100001);
	}

  factory CommentList.fromJson(Map<String, dynamic> json) => $CommentListFromJson(json);

  Map<String, dynamic> toJson() => $CommentListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class CommentListInfo {

	String? id;
	String? objID;
	String? cid;
	int? userID;
	String? userName;
	String? userPortrait;
	int? toUserID;
	String? toUserName;
	String? content;
	int? likeCount;
	bool? isLike;
	bool? isAuthor;
	bool? isTop;
	bool? isHotComment;
	bool? isFollow;
	bool? isDelete;
	String? gender;
	int? status;
	String? city;
	String? createdAt;
	int? age;
	int? level;
	int? vipLevel;
	dynamic awards;
	int? superUser;
	String? vipExpireDate;
  
  CommentListInfo();

  factory CommentListInfo.fromJson(Map<String, dynamic> json) => $CommentListInfoFromJson(json);

  Map<String, dynamic> toJson() => $CommentListInfoToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}