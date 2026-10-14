class VidStatusModel {
  bool? hasCollected;
  bool? hasLiked;
  bool? hasPaid;
  int? todayPlayCnt;
  int? todayRank;
  bool? hasDisliked;
  bool? hasPaidSeed;
  bool? hasGraded;

  static VidStatusModel fromJson(Map<String, dynamic>? map) {
    map ??= {};
    VidStatusModel vidStatusBean = VidStatusModel();
    vidStatusBean.hasCollected = map['hasCollected'];
    vidStatusBean.hasLiked = map['hasLiked'];
    vidStatusBean.hasPaid = map['hasPaid'];
    vidStatusBean.todayPlayCnt = map['todayPlayCnt'];
    vidStatusBean.todayRank = map['todayRank'];
    vidStatusBean.hasDisliked = map['hasDisliked'];
    vidStatusBean.hasPaidSeed = map['hasPaidSeed'];
    vidStatusBean.hasGraded = map['hasGraded'];
    return vidStatusBean;
  }

  Map toJson() => {
        "hasDisliked": hasDisliked,
        "hasCollected": hasCollected,
        "hasLiked": hasLiked,
        "hasPaid": hasPaid,
        "todayPlayCnt": todayPlayCnt,
        "todayRank": todayRank,
        "hasGraded": hasGraded,
      };
}
