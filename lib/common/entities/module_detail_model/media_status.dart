class MediaStatus {
  bool? hasCollected;
  bool? hasDisliked;
  bool? hasGraded;
  bool? hasLiked;
  bool? hasPaid;
  bool? hasRead;

  MediaStatus({
    this.hasCollected,
    this.hasDisliked,
    this.hasGraded,
    this.hasLiked,
    this.hasPaid,
    this.hasRead,
  });

  MediaStatus.fromJson(Map<String, dynamic> json) {
    hasCollected = json["hasCollected"];
    hasDisliked = json["hasDisliked"];
    hasGraded = json["hasGraded"];
    hasLiked = json["hasLiked"];
    hasPaid = json["hasPaid"];
    hasRead = json["hasRead"];
  }

  Map<String, dynamic> toJson() => {
        "hasCollected": hasCollected,
        "hasDisliked": hasDisliked,
        "hasGraded": hasGraded,
        "hasLiked": hasLiked,
        "hasPaid": hasPaid,
        "hasRead": hasRead,
      };
}
