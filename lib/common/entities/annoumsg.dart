class Annoumsg {
  int? total;
  List<AnnouList>? list;

  Annoumsg({this.total, this.list});

  Annoumsg.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    if (json['list'] != null) {
      list = <AnnouList>[];
      json['list'].forEach((v) {
        list!.add(AnnouList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AnnouList {
  String? id;
  String? title;
  String? content;
  String? cover;
  String? href;
  int? type;
  String? time;

  AnnouList(
      {this.id,
        this.title,
        this.content,
        this.cover,
        this.href,
        this.type,
        this.time});

  AnnouList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    cover = json['cover'];
    href = json['href'];
    type = json['type'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['cover'] = cover;
    data['href'] = href;
    data['type'] = type;
    data['time'] = time;
    return data;
  }
}
