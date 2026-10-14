import 'ShuApp.dart';
import 'Adv.dart';

class HappyModel {
  HappyModel({
    this.shuApp,
    this.adv,});

  HappyModel.fromJson(dynamic json) {
    if (json['shuApp'] != null) {
      shuApp = [];
      json['shuApp'].forEach((v) {
        shuApp?.add(ShuApp.fromJson(v));
      });
    }
    if (json['hengApp'] != null) {
      hengApp = [];
      json['hengApp'].forEach((v) {
        hengApp?.add(ShuApp.fromJson(v));
      });
    }
    if (json['adv'] != null) {
      adv = [];
      json['adv'].forEach((v) {
        adv?.add(Adv.fromJson(v));
      });
    }







    if (json['gameApp'] != null) {
      gameApp = [];
      json['gameApp'].forEach((v) {
        gameApp?.add(ShuApp.fromJson(v));
      });
    }

    if (json['ypApp'] != null) {
      ypApp = [];
      json['ypApp'].forEach((v) {
        ypApp?.add(ShuApp.fromJson(v));
      });
    }

    if (json['zbApp'] != null) {
      zbApp = [];
      json['zbApp'].forEach((v) {
        zbApp?.add(ShuApp.fromJson(v));
      });
    }

    if (json['qpApp'] != null) {
      qpApp = [];
      json['qpApp'].forEach((v) {
        qpApp?.add(ShuApp.fromJson(v));
      });
    }





  }
  List<ShuApp>? shuApp;
  List<ShuApp>? hengApp;
  List<Adv>? adv;


  List<ShuApp>? gameApp;
  List<ShuApp>? ypApp;
  List<ShuApp>? zbApp;
  List<ShuApp>? qpApp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (shuApp != null) {
      map['shuApp'] = shuApp?.map((v) => v.toJson()).toList();
    }
    if (hengApp != null) {
      map['hengApp'] = hengApp?.map((v) => v.toJson()).toList();
    }
    if (adv != null) {
      map['adv'] = adv?.map((v) => v.toJson()).toList();
    }




    if (gameApp != null) {
      map['gameApp'] = gameApp?.map((v) => v.toJson()).toList();
    }

    if (ypApp != null) {
      map['ypApp'] = ypApp?.map((v) => v.toJson()).toList();
    }

    if (zbApp != null) {
      map['zbApp'] = zbApp?.map((v) => v.toJson()).toList();
    }

    if (qpApp != null) {
      map['qpApp'] = qpApp?.map((v) => v.toJson()).toList();
    }



    return map;
  }

}