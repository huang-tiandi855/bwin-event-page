import 'package:comics_app/common/entities/wallet_pay_for_model.dart';
import 'package:comics_app/common/entities/wallet_product_item.dart';

class NewProductList {
  DCModel? daichong;
  List<TabVipItem>? list;
  bool? isNewUser;

  static NewProductList? fromJson(Map<String, dynamic>? map) {
    if (map == null) return null;
    var data = map["data"];
    NewProductList productListBean = NewProductList();
    productListBean.daichong = DCModel.fromJson(data['daichong']);
    productListBean.isNewUser = data["isNewUser"];
    productListBean.list = [];

    if (data['list'] != null) {
      for (var element in (data['list'] as List)) {
        TabVipItem? tabVipIem = TabVipItem.fromJson(element);
        productListBean.list?.add(tabVipIem);
      }
    }
    return productListBean;
  }

  Map toJson() => {
        "list": list,
        "isNewUser": isNewUser,
        "daichong": daichong.toString(),
      };
}

class TabVipItem {
  String? position;
  int? showType;
  List<ProductItemBean>? vips;
  String? positionID;

  TabVipItem.fromJson(Map<String, dynamic> json) {
    position = json["position"];
    showType = json["showType"];
    positionID = json["positionID"];
    if (null != json["list"]) {
      vips = <ProductItemBean>[];
      json["list"].forEach((it) {
        vips?.add(ProductItemBean.fromJson(it));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["position"] = position;
    if (vips != null) {
      data['list'] = vips?.map((v) => v.toJson()).toList();
    }
    data["showType"] = showType;
    data["positionID"] = positionID;
    return data;
  }

  @override
  String toString() {
    return 'TabVipItem{position: $position, showType: $showType, vips: $vips, positionID: $positionID}';
  }
}
