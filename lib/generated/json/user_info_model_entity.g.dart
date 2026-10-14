// import 'package:comics_app/common/entities/post_entity.dart';
// import 'package:comics_app/generated/json/base/json_convert_content.dart';
// import 'package:comics_app/common/entities/user_info_model_entity.dart';

// UserInfoModelEntity $UserInfoModelEntityFromJson(Map<String, dynamic> json) {
//   final UserInfoModelEntity userInfoModelEntity = UserInfoModelEntity();
//   final int? age = jsonConvert.convert<int>(json['age']);
//   if (age != null) {
//     userInfoModelEntity.age = age;
//   }
//   final int? like = jsonConvert.convert<int>(json['like']);
//   if (like != null) {
//     userInfoModelEntity.like = like;
//   }
//   final int? follow = jsonConvert.convert<int>(json['follow']);
//   if (follow != null) {
//     userInfoModelEntity.follow = follow;
//   }
//   final int? fans = jsonConvert.convert<int>(json['fans']);
//   if (fans != null) {
//     userInfoModelEntity.fans = fans;
//   }
//   final int? dynamics = jsonConvert.convert<int>(json['dynamics']);
//   if (dynamics != null) {
//     userInfoModelEntity.dynamics = dynamics;
//   }
//   final int? collectionCount =
//       jsonConvert.convert<int>(json['collectionCount']);
//   if (collectionCount != null) {
//     userInfoModelEntity.collectionCount = collectionCount;
//   }
//   final int? likeCount = jsonConvert.convert<int>(json['likeCount']);
//   if (likeCount != null) {
//     userInfoModelEntity.likeCount = likeCount;
//   }
//   final int? favoriteCount = jsonConvert.convert<int>(json['favoriteCount']);
//   if (favoriteCount != null) {
//     userInfoModelEntity.favoriteCount = favoriteCount;
//   }
//   final bool? isVip = jsonConvert.convert<bool>(json['isVip']);
//   if (isVip != null) {
//     userInfoModelEntity.isVip = isVip;
//   }
//   final bool? isFollow = jsonConvert.convert<bool>(json['isFollow']);
//   if (isFollow != null) {
//     userInfoModelEntity.isFollow = isFollow;
//   }
//   final String? promoteURL = jsonConvert.convert<String>(json['promoteURL']);
//   if (promoteURL != null) {
//     userInfoModelEntity.promoteURL = promoteURL;
//   }
//   final String? inviterCode = jsonConvert.convert<String>(json['inviterCode']);
//   if (inviterCode != null) {
//     userInfoModelEntity.inviterCode = inviterCode;
//   }
//   final String? city = jsonConvert.convert<String>(json['city']);
//   if (city != null) {
//     userInfoModelEntity.city = city;
//   }
//   final int? buyVidCount = jsonConvert.convert<int>(json['buyVidCount']);
//   if (buyVidCount != null) {
//     userInfoModelEntity.buyVidCount = buyVidCount;
//   }
//   final String? webToken = jsonConvert.convert<String>(json['webToken']);
//   if (webToken != null) {
//     userInfoModelEntity.webToken = webToken;
//   }
//   final int? loginType = jsonConvert.convert<int>(json['loginType']);
//   if (loginType != null) {
//     userInfoModelEntity.loginType = loginType;
//   }
//   final int? louFengDiscount =
//       jsonConvert.convert<int>(json['louFengDiscount']);
//   if (louFengDiscount != null) {
//     userInfoModelEntity.louFengDiscount = louFengDiscount;
//   }
//   final String? appStoreCode =
//       jsonConvert.convert<String>(json['appStoreCode']);
//   if (appStoreCode != null) {
//     userInfoModelEntity.appStoreCode = appStoreCode;
//   }
//   final String? lfCheatGuide =
//       jsonConvert.convert<String>(json['lfCheatGuide']);
//   if (lfCheatGuide != null) {
//     userInfoModelEntity.lfCheatGuide = lfCheatGuide;
//   }
//   final String? videoDiscountExpiration =
//       jsonConvert.convert<String>(json['videoDiscountExpiration']);
//   if (videoDiscountExpiration != null) {
//     userInfoModelEntity.videoDiscountExpiration = videoDiscountExpiration;
//   }
//   final dynamic? newGoldVideoCoupon =
//       jsonConvert.convert<dynamic>(json['newGoldVideoCoupon']);
//   if (newGoldVideoCoupon != null) {
//     userInfoModelEntity.newGoldVideoCoupon = newGoldVideoCoupon;
//   }
//   final String? loufengDiscountExpiration =
//       jsonConvert.convert<String>(json['loufengDiscountExpiration']);
//   if (loufengDiscountExpiration != null) {
//     userInfoModelEntity.loufengDiscountExpiration = loufengDiscountExpiration;
//   }
//   final int? loufengBookDiscount =
//       jsonConvert.convert<int>(json['loufengBookDiscount']);
//   if (loufengBookDiscount != null) {
//     userInfoModelEntity.loufengBookDiscount = loufengBookDiscount;
//   }
//   final String? loufengBookDiscountExpiration =
//       jsonConvert.convert<String>(json['loufengBookDiscountExpiration']);
//   if (loufengBookDiscountExpiration != null) {
//     userInfoModelEntity.loufengBookDiscountExpiration =
//         loufengBookDiscountExpiration;
//   }
//   final int? boughtLoufengCount =
//       jsonConvert.convert<int>(json['boughtLoufengCount']);
//   if (boughtLoufengCount != null) {
//     userInfoModelEntity.boughtLoufengCount = boughtLoufengCount;
//   }
//   final int? boughtNudeChatCount =
//       jsonConvert.convert<int>(json['boughtNudeChatCount']);
//   if (boughtNudeChatCount != null) {
//     userInfoModelEntity.boughtNudeChatCount = boughtNudeChatCount;
//   }
//   final int? likeImageCount = jsonConvert.convert<int>(json['likeImageCount']);
//   if (likeImageCount != null) {
//     userInfoModelEntity.likeImageCount = likeImageCount;
//   }
//   final int? happinessPlazaCount =
//       jsonConvert.convert<int>(json['happinessPlazaCount']);
//   if (happinessPlazaCount != null) {
//     userInfoModelEntity.happinessPlazaCount = happinessPlazaCount;
//   }
//   final String? id = jsonConvert.convert<String>(json['id']);
//   if (id != null) {
//     userInfoModelEntity.id = id;
//   }
//   final int? uid = jsonConvert.convert<int>(json['uid']) ??
//       jsonConvert.convert<int>(json['id']);
//   if (uid != null) {
//     userInfoModelEntity.uid = uid;
//   }
//   final String? devID = jsonConvert.convert<String>(json['devID']);
//   if (devID != null) {
//     userInfoModelEntity.devID = devID;
//   }
//   final String? devType = jsonConvert.convert<String>(json['devType']);
//   if (devType != null) {
//     userInfoModelEntity.devType = devType;
//   }
//   final String? devToken = jsonConvert.convert<String>(json['devToken']);
//   if (devToken != null) {
//     userInfoModelEntity.devToken = devToken;
//   }
//   final String? registerIP = jsonConvert.convert<String>(json['registerIP']);
//   if (registerIP != null) {
//     userInfoModelEntity.registerIP = registerIP;
//   }
//   final String? mobile = jsonConvert.convert<String>(json['mobile']) ??
//       jsonConvert.convert<String>(json['phone']);
//   if (mobile != null) {
//     userInfoModelEntity.mobile = mobile;
//   }
//   final String? gender = jsonConvert.convert<String>(json['gender']) ??
//       jsonConvert.convert<String>(json['sex']);
//   if (gender != null) {
//     userInfoModelEntity.gender = gender;
//   }
//   final String? name = jsonConvert.convert<String>(json['name']) ??
//       jsonConvert.convert<String>(json['nickName']);
//   if (name != null) {
//     userInfoModelEntity.name = name;
//   }
//   final String? portrait = jsonConvert.convert<String>(json['portrait']) ??
//       jsonConvert.convert<String>(json['avatar']);
//   if (portrait != null) {
//     userInfoModelEntity.portrait = portrait;
//   }

//   final String? portraitFrame =
//       jsonConvert.convert<String>(json['portraitFrame']);
//   if (portraitFrame != null) {
//     userInfoModelEntity.portraitFrame = portraitFrame;
//   }

//   final List<String>? background =
//       jsonConvert.convertListNotNull<String>(json['background']);
//   if (background != null) {
//     userInfoModelEntity.background = background;
//   }
//   final String? summary = jsonConvert.convert<String>(json['summary']);
//   if (summary != null) {
//     userInfoModelEntity.summary = summary;
//   }
//   final String? region = jsonConvert.convert<String>(json['region']);
//   if (region != null) {
//     userInfoModelEntity.region = region;
//   }
//   final String? birthday = jsonConvert.convert<String>(json['birthday']);
//   if (birthday != null) {
//     userInfoModelEntity.birthday = birthday;
//   }
//   final int? vipLevel = jsonConvert.convert<int>(json['vipLevel']);
//   if (vipLevel != null) {
//     userInfoModelEntity.vipLevel = vipLevel;
//   }
//   final bool? hasLocked = jsonConvert.convert<bool>(json['hasLocked']);
//   if (hasLocked != null) {
//     userInfoModelEntity.hasLocked = hasLocked;
//   }
//   final String? lockReason = jsonConvert.convert<String>(json['lockReason']);
//   if (lockReason != null) {
//     userInfoModelEntity.lockReason = lockReason;
//   }
//   final bool? hasBanned = jsonConvert.convert<bool>(json['hasBanned']);
//   if (hasBanned != null) {
//     userInfoModelEntity.hasBanned = hasBanned;
//   }
//   final bool? forbidUpload = jsonConvert.convert<bool>(json['forbidUpload']);
//   if (forbidUpload != null) {
//     userInfoModelEntity.forbidUpload = forbidUpload;
//   }
//   final String? token = jsonConvert.convert<String>(json['token']) ??
//       jsonConvert.convert<String>(json['accessToken']);
//   if (token != null) {
//     userInfoModelEntity.token = token;
//   }
//   final int? tokenValidDate = jsonConvert.convert<int>(json['tokenValidDate']);
//   if (tokenValidDate != null) {
//     userInfoModelEntity.tokenValidDate = tokenValidDate;
//   }
//   final int? vipValidDate = jsonConvert.convert<int>(json['vipValidDate']);
//   if (vipValidDate != null) {
//     userInfoModelEntity.vipValidDate = vipValidDate;
//   }
//   final int? createDate = jsonConvert.convert<int>(json['createDate']);
//   if (createDate != null) {
//     userInfoModelEntity.createDate = createDate;
//   }
//   final bool? newUser = jsonConvert.convert<bool>(json['newUser']);
//   if (newUser != null) {
//     userInfoModelEntity.newUser = newUser;
//   }
//   final int? bindStatus = jsonConvert.convert<int>(json['bindStatus']);
//   if (bindStatus != null) {
//     userInfoModelEntity.bindStatus = bindStatus;
//   }
//   final int? accountLevel = jsonConvert.convert<int>(json['accountLevel']);
//   if (accountLevel != null) {
//     userInfoModelEntity.accountLevel = accountLevel;
//   }
//   final String? machineCode = jsonConvert.convert<String>(json['machineCode']);
//   if (machineCode != null) {
//     userInfoModelEntity.machineCode = machineCode;
//   }
//   final int? watchCount = jsonConvert.convert<int>(json['watchCount']);
//   if (watchCount != null) {
//     userInfoModelEntity.watchCount = watchCount;
//   }
//   final String? appLock = jsonConvert.convert<String>(json['appLock']);
//   if (appLock != null) {
//     userInfoModelEntity.appLock = appLock;
//   }
//   final int? trueScore = jsonConvert.convert<int>(json['trueScore']);
//   if (trueScore != null) {
//     userInfoModelEntity.trueScore = trueScore;
//   }
//   final String? ver = jsonConvert.convert<String>(json['ver']);
//   if (ver != null) {
//     userInfoModelEntity.ver = ver;
//   }
//   final String? lastVer = jsonConvert.convert<String>(json['lastVer']);
//   if (lastVer != null) {
//     userInfoModelEntity.lastVer = lastVer;
//   }
//   final String? sysType = jsonConvert.convert<String>(json['sysType']);
//   if (sysType != null) {
//     userInfoModelEntity.sysType = sysType;
//   }
//   final String? lastVisitAt = jsonConvert.convert<String>(json['lastVisitAt']);
//   if (lastVisitAt != null) {
//     userInfoModelEntity.lastVisitAt = lastVisitAt;
//   }
//   final String? lastSysType = jsonConvert.convert<String>(json['lastSysType']);
//   if (lastSysType != null) {
//     userInfoModelEntity.lastSysType = lastSysType;
//   }
//   final String? vipExpireDate =
//       jsonConvert.convert<String>(json['vipExpireDate']);
//   if (vipExpireDate != null) {
//     userInfoModelEntity.vipExpireDate = vipExpireDate;
//   }
//   final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
//   if (createdAt != null) {
//     userInfoModelEntity.createdAt = createdAt;
//   }
//   final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
//   if (updatedAt != null) {
//     userInfoModelEntity.updatedAt = updatedAt;
//   }
//   final dynamic? mobileBindAt =
//       jsonConvert.convert<dynamic>(json['mobileBindAt']);
//   if (mobileBindAt != null) {
//     userInfoModelEntity.mobileBindAt = mobileBindAt;
//   }
//   final dynamic? mobileUnBindAt =
//       jsonConvert.convert<dynamic>(json['mobileUnBindAt']);
//   if (mobileUnBindAt != null) {
//     userInfoModelEntity.mobileUnBindAt = mobileUnBindAt;
//   }
//   final bool? isDAgent = jsonConvert.convert<bool>(json['isDAgent']);
//   if (isDAgent != null) {
//     userInfoModelEntity.isDAgent = isDAgent;
//   }
//   final String? promotionCode =
//       jsonConvert.convert<String>(json['invitationCode']) ??
//           jsonConvert.convert<String>(json['inviterCode']);
//   if (promotionCode != null) {
//     userInfoModelEntity.promotionCode = promotionCode;
//   }
//   final String? channelCode = jsonConvert.convert<String>(json['channelCode']);
//   if (channelCode != null) {
//     userInfoModelEntity.channelCode = channelCode;
//   }
//   final String? districtCode =
//       jsonConvert.convert<String>(json['districtCode']);
//   if (districtCode != null) {
//     userInfoModelEntity.districtCode = districtCode;
//   }
//   final String? promSeqe = jsonConvert.convert<String>(json['promSeqe']);
//   if (promSeqe != null) {
//     userInfoModelEntity.promSeqe = promSeqe;
//   }
//   final bool? isDirect = jsonConvert.convert<bool>(json['isDirect']);
//   if (isDirect != null) {
//     userInfoModelEntity.isDirect = isDirect;
//   }
//   final String? discBindAt = jsonConvert.convert<String>(json['DiscBindAt']);
//   if (discBindAt != null) {
//     userInfoModelEntity.discBindAt = discBindAt;
//   }
//   final int? superUser = jsonConvert.convert<int>(json['superUser']);
//   if (superUser != null) {
//     userInfoModelEntity.superUser = superUser;
//   }
//   final String? superUserExpire =
//       jsonConvert.convert<String>(json['superUserExpire']);
//   if (superUserExpire != null) {
//     userInfoModelEntity.superUserExpire = superUserExpire;
//   }
//   final int? activeValue = jsonConvert.convert<int>(json['activeValue']);
//   if (activeValue != null) {
//     userInfoModelEntity.activeValue = activeValue;
//   }
//   final bool? officialCert = jsonConvert.convert<bool>(json['officialCert']);
//   if (officialCert != null) {
//     userInfoModelEntity.officialCert = officialCert;
//   }
//   final bool? isMadou = jsonConvert.convert<bool>(json['isMadou']);
//   if (isMadou != null) {
//     userInfoModelEntity.isMadou = isMadou;
//   }
//   final int? taxLevel = jsonConvert.convert<int>(json['taxLevel']);
//   if (taxLevel != null) {
//     userInfoModelEntity.taxLevel = taxLevel;
//   }
//   final int? loginDays = jsonConvert.convert<int>(json['loginDays']);
//   if (loginDays != null) {
//     userInfoModelEntity.loginDays = loginDays;
//   }
//   final String? rewarded = jsonConvert.convert<String>(json['rewarded']);
//   if (rewarded != null) {
//     userInfoModelEntity.rewarded = rewarded;
//   }
//   final int? follows = jsonConvert.convert<int>(json['follows']);
//   if (follows != null) {
//     userInfoModelEntity.follows = follows;
//   }
//   final int? beRewardCount = jsonConvert.convert<int>(json['beRewardCount']);
//   if (beRewardCount != null) {
//     userInfoModelEntity.beRewardCount = beRewardCount;
//   }
//   final bool? followsSetFlag =
//       jsonConvert.convert<bool>(json['followsSetFlag']);
//   if (followsSetFlag != null) {
//     userInfoModelEntity.followsSetFlag = followsSetFlag;
//   }
//   final int? snapVip = jsonConvert.convert<int>(json['snapVip']);
//   if (snapVip != null) {
//     userInfoModelEntity.snapVip = snapVip;
//   }
//   final bool? autoFollow = jsonConvert.convert<bool>(json['autoFollow']);
//   if (autoFollow != null) {
//     userInfoModelEntity.autoFollow = autoFollow;
//   }
//   final bool? hasEnteredGame =
//       jsonConvert.convert<bool>(json['hasEnteredGame']);
//   if (hasEnteredGame != null) {
//     userInfoModelEntity.hasEnteredGame = hasEnteredGame;
//   }
//   final int? louFengUnlockTimes =
//       jsonConvert.convert<int>(json['louFengUnlockTimes']);
//   if (louFengUnlockTimes != null) {
//     userInfoModelEntity.louFengUnlockTimes = louFengUnlockTimes;
//   }
//   final String? goldVideoFreeExpire =
//       jsonConvert.convert<String>(json['goldVideoFreeExpire']);
//   if (goldVideoFreeExpire != null) {
//     userInfoModelEntity.goldVideoFreeExpire = goldVideoFreeExpire;
//   }
//   final int? weeklyActiveValue =
//       jsonConvert.convert<int>(json['weeklyActiveValue']);
//   if (weeklyActiveValue != null) {
//     userInfoModelEntity.weeklyActiveValue = weeklyActiveValue;
//   }
//   final String? bankActName = jsonConvert.convert<String>(json['bankActName']);
//   if (bankActName != null) {
//     userInfoModelEntity.bankActName = bankActName;
//   }
//   final int? originalSort = jsonConvert.convert<int>(json['originalSort']);
//   if (originalSort != null) {
//     userInfoModelEntity.originalSort = originalSort;
//   }
//   final String? puc = jsonConvert.convert<String>(json['puc']);
//   if (puc != null) {
//     userInfoModelEntity.puc = puc;
//   }
//   final int? videoDeduction = jsonConvert.convert<int>(json['videoDeduction']);
//   if (videoDeduction != null) {
//     userInfoModelEntity.videoDeduction = videoDeduction;
//   }
//   final int? videoDeductionPayCount =
//       jsonConvert.convert<int>(json['videoDeductionPayCount']);
//   if (videoDeductionPayCount != null) {
//     userInfoModelEntity.videoDeductionPayCount = videoDeductionPayCount;
//   }
//   final int? videoDeductionCount =
//       jsonConvert.convert<int>(json['videoDeductionCount']);
//   if (videoDeductionCount != null) {
//     userInfoModelEntity.videoDeductionCount = videoDeductionCount;
//   }
//   final bool? hasFirstChargeWaLi =
//       jsonConvert.convert<bool>(json['hasFirstChargeWaLi']);
//   if (hasFirstChargeWaLi != null) {
//     userInfoModelEntity.hasFirstChargeWaLi = hasFirstChargeWaLi;
//   }
//   final bool? hasFirstChargeVID =
//       jsonConvert.convert<bool>(json['hasFirstChargeVID']);
//   if (hasFirstChargeVID != null) {
//     userInfoModelEntity.hasFirstChargeVID = hasFirstChargeVID;
//   }
//   final String? merchantAccount =
//       jsonConvert.convert<String>(json['merchantAccount']);
//   if (merchantAccount != null) {
//     userInfoModelEntity.merchantAccount = merchantAccount;
//   }
//   final int? payVidDiscount = jsonConvert.convert<int>(json['payVidDiscount']);
//   if (payVidDiscount != null) {
//     userInfoModelEntity.payVidDiscount = payVidDiscount;
//   }
//   final dynamic videoFreeExpiration =
//       jsonConvert.convert<dynamic>(json['videoFreeExpiration']);
//   if (videoFreeExpiration != null) {
//     userInfoModelEntity.videoFreeExpiration = videoFreeExpiration;
//   }

//   final dynamic officialCertExpire =
//       jsonConvert.convert<dynamic>(json['officialCertExpire']);
//   if (officialCertExpire != null) {
//     userInfoModelEntity.officialCertExpire = officialCertExpire;
//   }

//   final String? passWord = jsonConvert.convert<String>(json['passWord']);
//   if (passWord != null) {
//     userInfoModelEntity.passWord = passWord;
//   }
//   final String? email = jsonConvert.convert<String>(json['email']);
//   if (email != null) {
//     userInfoModelEntity.email = email;
//   }
//   final dynamic? emailCheckedAt =
//       jsonConvert.convert<dynamic>(json['emailCheckedAt']);
//   if (emailCheckedAt != null) {
//     userInfoModelEntity.emailCheckedAt = emailCheckedAt;
//   }
//   final String? account = jsonConvert.convert<String>(json['account']);
//   if (account != null) {
//     userInfoModelEntity.account = account;
//   }
//   final dynamic? accountBindAt =
//       jsonConvert.convert<dynamic>(json['accountBindAt']);
//   if (accountBindAt != null) {
//     userInfoModelEntity.accountBindAt = accountBindAt;
//   }
//   final int? userType = jsonConvert.convert<int>(json['userType']);
//   if (userType != null) {
//     userInfoModelEntity.userType = userType;
//   }
//   final String? agentAccount =
//       jsonConvert.convert<String>(json['agentAccount']);
//   if (agentAccount != null) {
//     userInfoModelEntity.agentAccount = agentAccount;
//   }
//   final bool? payable = jsonConvert.convert<bool>(json['payable']);
//   if (payable != null) {
//     userInfoModelEntity.payable = payable;
//   }
//   final int? deposit = jsonConvert.convert<int>(json['deposit']);
//   if (deposit != null) {
//     userInfoModelEntity.deposit = deposit;
//   }
//   final String? introduce = jsonConvert.convert<String>(json['introduce']);
//   if (introduce != null) {
//     userInfoModelEntity.introduce = introduce;
//   }
//   final dynamic? awards = jsonConvert.convert<dynamic>(json['awards']);
//   if (awards != null) {
//     userInfoModelEntity.awards = awards;
//   }
//   final bool? showProxy = jsonConvert.convert<bool>(json['showProxy']);
//   if (showProxy != null) {
//     userInfoModelEntity.showProxy = showProxy;
//   }
//   final int? level = jsonConvert.convert<int>(json['level']);
//   if (level != null) {
//     userInfoModelEntity.level = level;
//   }
//   final int? current = jsonConvert.convert<int>(json['current']);
//   if (current != null) {
//     userInfoModelEntity.current = current;
//   }
//   final int? limit = jsonConvert.convert<int>(json['limit']);
//   if (limit != null) {
//     userInfoModelEntity.limit = limit;
//   }

//   final int? aiUndressCount = jsonConvert.convert<int>(json['aiUndressCount']);
//   if (aiUndressCount != null) {
//     userInfoModelEntity.aiUndressCount = aiUndressCount;
//   }

//   final bool? hasFollow = jsonConvert.convert<bool>(json['hasFollow']);
//   if (hasFollow != null) {
//     userInfoModelEntity.hasFollow = hasFollow;
//   }

//   final String? desc = jsonConvert.convert<String>(json['desc']);
//   if (desc != null) {
//     userInfoModelEntity.desc = desc;
//   }

//   final List? vInfos = jsonConvert.convert<List>(json['vInfos']);
//   if (vInfos != null) {
//     userInfoModelEntity.vInfos =
//         vInfos.map((e) => PostList.fromJson(e)).toList();
//   }

//   final dynamic? whoringCard =
//       jsonConvert.convert<dynamic>(json['whoringCard']);

//   if (whoringCard != null) {
//     if (whoringCard["detailInfo"] == null) {
//       bool hasWhoringCard = whoringCard["hasWhoringCard"];
//       List<DetailInfo> list = [];
//       userInfoModelEntity.whoringCardClass =
//           WhoringCardClass(hasWhoringCard: hasWhoringCard, detailInfo: list);
//     } else {
//       userInfoModelEntity.whoringCardClass =
//           WhoringCardClass.fromJson(whoringCard);
//     }
//   }

//   return userInfoModelEntity;
// }

// Map<String, dynamic> $UserInfoModelEntityToJson(UserInfoModelEntity entity) {
//   final Map<String, dynamic> data = <String, dynamic>{};
//   data['age'] = entity.age;
//   data['like'] = entity.like;
//   data['follow'] = entity.follow;
//   data['fans'] = entity.fans;
//   data['dynamics'] = entity.dynamics;
//   data['collectionCount'] = entity.collectionCount;
//   data['likeCount'] = entity.likeCount;
//   data['favoriteCount'] = entity.favoriteCount;
//   data['isVip'] = entity.isVip;
//   data['isFollow'] = entity.isFollow;
//   data['promoteURL'] = entity.promoteURL;
//   data['inviterCode'] = entity.inviterCode;
//   data['city'] = entity.city;
//   data['buyVidCount'] = entity.buyVidCount;
//   data['webToken'] = entity.webToken;
//   data['loginType'] = entity.loginType;
//   data['louFengDiscount'] = entity.louFengDiscount;
//   data['appStoreCode'] = entity.appStoreCode;
//   data['lfCheatGuide'] = entity.lfCheatGuide;
//   data['videoDiscountExpiration'] = entity.videoDiscountExpiration;
//   data['newGoldVideoCoupon'] = entity.newGoldVideoCoupon;
//   data['loufengDiscountExpiration'] = entity.loufengDiscountExpiration;
//   data['loufengBookDiscount'] = entity.loufengBookDiscount;
//   data['loufengBookDiscountExpiration'] = entity.loufengBookDiscountExpiration;
//   data['boughtLoufengCount'] = entity.boughtLoufengCount;
//   data['boughtNudeChatCount'] = entity.boughtNudeChatCount;
//   data['likeImageCount'] = entity.likeImageCount;
//   data['happinessPlazaCount'] = entity.happinessPlazaCount;
//   data['id'] = entity.id;
//   data['uid'] = entity.uid;
//   data['devID'] = entity.devID;
//   data['devType'] = entity.devType;
//   data['devToken'] = entity.devToken;
//   data['registerIP'] = entity.registerIP;
//   data['mobile'] = entity.mobile;
//   data['gender'] = entity.gender;
//   data['name'] = entity.name;
//   data['portrait'] = entity.portrait;
//   data['portraitFrame'] = entity.portraitFrame;
//   data['background'] = entity.background;
//   data['summary'] = entity.summary;
//   data['region'] = entity.region;
//   data['birthday'] = entity.birthday;
//   data['vipLevel'] = entity.vipLevel;
//   data['hasLocked'] = entity.hasLocked;
//   data['lockReason'] = entity.lockReason;
//   data['hasBanned'] = entity.hasBanned;
//   data['forbidUpload'] = entity.forbidUpload;
//   data['token'] = entity.token;
//   data['tokenValidDate'] = entity.tokenValidDate;
//   data['vipValidDate'] = entity.vipValidDate;
//   data['createDate'] = entity.createDate;
//   data['newUser'] = entity.newUser;
//   data['bindStatus'] = entity.bindStatus;
//   data['accountLevel'] = entity.accountLevel;
//   data['machineCode'] = entity.machineCode;
//   data['watchCount'] = entity.watchCount;
//   data['appLock'] = entity.appLock;
//   data['trueScore'] = entity.trueScore;
//   data['ver'] = entity.ver;
//   data['lastVer'] = entity.lastVer;
//   data['sysType'] = entity.sysType;
//   data['lastVisitAt'] = entity.lastVisitAt;
//   data['lastSysType'] = entity.lastSysType;
//   data['vipExpireDate'] = entity.vipExpireDate;
//   data['createdAt'] = entity.createdAt;
//   data['updatedAt'] = entity.updatedAt;
//   data['mobileBindAt'] = entity.mobileBindAt;
//   data['mobileUnBindAt'] = entity.mobileUnBindAt;
//   data['isDAgent'] = entity.isDAgent;
//   data['promotionCode'] = entity.promotionCode;
//   data['channelCode'] = entity.channelCode;
//   data['districtCode'] = entity.districtCode;
//   data['promSeqe'] = entity.promSeqe;
//   data['isDirect'] = entity.isDirect;
//   data['DiscBindAt'] = entity.discBindAt;
//   data['superUser'] = entity.superUser;
//   data['superUserExpire'] = entity.superUserExpire;
//   data['activeValue'] = entity.activeValue;
//   data['officialCert'] = entity.officialCert;
//   data['isMadou'] = entity.isMadou;
//   data['taxLevel'] = entity.taxLevel;
//   data['loginDays'] = entity.loginDays;
//   data['rewarded'] = entity.rewarded;
//   data['follows'] = entity.follows;
//   data['beRewardCount'] = entity.beRewardCount;
//   data['followsSetFlag'] = entity.followsSetFlag;
//   data['snapVip'] = entity.snapVip;
//   data['autoFollow'] = entity.autoFollow;
//   data['hasEnteredGame'] = entity.hasEnteredGame;
//   data['louFengUnlockTimes'] = entity.louFengUnlockTimes;
//   data['goldVideoFreeExpire'] = entity.goldVideoFreeExpire;
//   data['weeklyActiveValue'] = entity.weeklyActiveValue;
//   data['bankActName'] = entity.bankActName;
//   data['originalSort'] = entity.originalSort;
//   data['puc'] = entity.puc;
//   data['videoDeduction'] = entity.videoDeduction;
//   data['videoDeductionPayCount'] = entity.videoDeductionPayCount;
//   data['videoDeductionCount'] = entity.videoDeductionCount;
//   data['hasFirstChargeWaLi'] = entity.hasFirstChargeWaLi;
//   data['hasFirstChargeVID'] = entity.hasFirstChargeVID;
//   data['merchantAccount'] = entity.merchantAccount;
//   data['payVidDiscount'] = entity.payVidDiscount;
//   data['videoFreeExpiration'] = entity.videoFreeExpiration;
//   data['officialCertExpire'] = entity.officialCertExpire;
//   data['passWord'] = entity.passWord;
//   data['email'] = entity.email;
//   data['emailCheckedAt'] = entity.emailCheckedAt;
//   data['account'] = entity.account;
//   data['accountBindAt'] = entity.accountBindAt;
//   data['userType'] = entity.userType;
//   data['agentAccount'] = entity.agentAccount;
//   data['payable'] = entity.payable;
//   data['deposit'] = entity.deposit;
//   data['introduce'] = entity.introduce;
//   data['awards'] = entity.awards;
//   data['showProxy'] = entity.showProxy;
//   data['level'] = entity.level;
//   data['current'] = entity.current;
//   data['limit'] = entity.limit;

//   data['aiUndressCount'] = entity.aiUndressCount;

//   return data;
// }

// class WhoringCardClass {
//   bool? hasWhoringCard;
//   List<DetailInfo>? detailInfo;

//   WhoringCardClass({
//     this.hasWhoringCard,
//     this.detailInfo,
//   });

//   factory WhoringCardClass.fromJson(Map<String, dynamic> json) =>
//       WhoringCardClass(
//         hasWhoringCard: json["hasWhoringCard"],
//         detailInfo: json["detailInfo"] != null
//             ? List<DetailInfo>.from(
//                 json["detailInfo"].map((x) => DetailInfo.fromJson(x)))
//             : [],
//       );

//   Map<String, dynamic> toJson() => {
//         "hasWhoringCard": hasWhoringCard,
//         "detailInfo": List<DetailInfo>.from(detailInfo!.map((x) => x.toJson())),
//       };

//   @override
//   String toString() {
//     return 'WhoringCardClass{hasWhoringCard: $hasWhoringCard, detailInfo: $detailInfo}';
//   }
// }

// class DetailInfo {
//   String id;
//   bool hasReturn;
//   int totalDays;
//   int currentSignDays;
//   int forgetSignDays;
//   int renewalSignDays;
//   int renewalSignPrice;
//   String startTime;
//   String endTime;
//   List<RecordTimeModel>? recordTime;

//   DetailInfo({
//     this.id = "",
//     this.hasReturn = false,
//     this.totalDays = 0,
//     this.currentSignDays = 0,
//     this.forgetSignDays = 0,
//     this.renewalSignDays = 0,
//     this.renewalSignPrice = 0,
//     this.startTime = "",
//     this.endTime = "",
//     this.recordTime,
//   });

//   factory DetailInfo.fromJson(Map<String, dynamic> json) => DetailInfo(
//         id: json["id"],
//         hasReturn: json["hasReturn"],
//         totalDays: json["totalDays"],
//         currentSignDays: json["currentSignDays"],
//         forgetSignDays: json["forgetSignDays"],
//         renewalSignDays: json["renewalSignDays"],
//         renewalSignPrice: json["renewalSignPrice"],
//         startTime: json["startTime"],
//         endTime: json["endTime"],
//         recordTime: json["recordTime"] != null
//             ? List<RecordTimeModel>.from(
//                 json["recordTime"].map((x) => RecordTimeModel.fromJson(x)))
//             : [],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "hasReturn": hasReturn,
//         "totalDays": totalDays,
//         "currentSignDays": currentSignDays,
//         "forgetSignDays": forgetSignDays,
//         "renewalSignDays": renewalSignDays,
//         "renewalSignPrice": renewalSignPrice,
//         "startTime": startTime,
//         "endTime": endTime,
//         "recordTime":
//             List<RecordTimeModel>.from(recordTime!.map((x) => x.toJson())),
//       };

//   @override
//   String toString() {
//     return 'DetailInfo{id: $id, hasReturn: $hasReturn, totalDays: $totalDays, currentSignDays: $currentSignDays, forgetSignDays: $forgetSignDays, renewalSignDays: $renewalSignDays, renewalSignPrice: $renewalSignPrice, startTime: $startTime, endTime: $endTime, recordTime: $recordTime}';
//   }
// }

// class RecordTimeModel {
//   String signTime = "";
//   bool isSign = false;

//   RecordTimeModel({this.signTime = "", this.isSign = false});

//   @override
//   String toString() {
//     return 'RecordTimeModel{signTime: $signTime, isSign: $isSign}';
//   }

//   factory RecordTimeModel.fromJson(Map<String, dynamic> json) =>
//       RecordTimeModel(
//         signTime: json["signTime"],
//         isSign: json["isSign"],
//       );

//   Map<String, dynamic> toJson() => {
//         "signTime": signTime,
//         "isSign": isSign,
//       };
// }
