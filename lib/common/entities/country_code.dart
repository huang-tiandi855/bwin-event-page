class CountryCodeEntity {
  List<CountryCode>? list;

  static List<CountryCode> fromJson(Map<String, dynamic> json) {
    List<CountryCode> list = [];
    if (json["list"] != null) {
      for (var element in (json["list"] as List)) {
        list.add(CountryCode(element["city"], element["code"]));
      }
    }
    return list;
  }
}

class CountryCode {
  String? city;
  String? code;

  CountryCode(this.city, this.code);
}
