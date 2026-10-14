class WatchModel {
  int? watchCount;
  bool? isWatch;
  bool? isFreeWatch;

  WatchModel({
    this.watchCount,
    this.isWatch,
    this.isFreeWatch,
  });

  factory WatchModel.fromJson(Map<String, dynamic> json) => WatchModel(
        watchCount: json["watchCount"],
        isWatch: json["isWatch"],
        isFreeWatch: json["isFreeWatch"],
      );

  Map<String, dynamic> toJson() => {
        "watchCount": watchCount,
        "isWatch": isWatch,
        "isFreeWatch": isFreeWatch,
      };
}
