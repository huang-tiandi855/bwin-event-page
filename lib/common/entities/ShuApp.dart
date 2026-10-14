class ShuApp {
  ShuApp({
      this.id, 
      this.name, 
      this.desc, 
      this.icon, 
      this.url, 
      this.type, 
      this.downloadNum,});

  ShuApp.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    desc = json['desc'];
    icon = json['icon'];
    url = json['url'];
    type = json['type'];
    downloadNum = json['downloadNum'];
  }
  String? id;
  String? name;
  String? desc;
  String? icon;
  String? url;
  String? type;
  int? downloadNum;

  getDownLoadNumDesc(){
    String countDesc;
    if ((downloadNum??0) >= 10000) {
      String unit = "w";
      double newNum = (downloadNum??0) / 10000.0;

      countDesc = newNum.toStringAsFixed(2) + unit;
    } else {
      countDesc = (downloadNum??0).toString();
    }
    return countDesc;
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['desc'] = desc;
    map['icon'] = icon;
    map['url'] = url;
    map['type'] = type;
    map['downloadNum'] = downloadNum;
    return map;
  }

}