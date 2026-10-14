//广告插入工具
//每两个专题插入一组1排5个的广告小方块


import '../../entities/config.dart';
import '../../entities/module_detail_model/all_section_model.dart';
import 'getAdv.dart';

final adsInsertUtils = AdsInsertUtils();

class AdsInsertUtils {
  //AdGroupCount 几个广告一组，如5个广告一组
  //adGap 广告插入间隔
  static handelAdsSource(List<AllSectionModel> modelArr,
      {required AdsType adPos, int? adGroupCount = 5, required int adGap}) {
    List<AdsInfoList> adsList =  getAdsByType(adPos); //广告位置
    if (adsList.isEmpty || modelArr.isEmpty) return;
    List<AdsInfoList> groupAdsList = [];
    for(int i = 0; i < (adGroupCount??5); i++){
      groupAdsList.addAll(adsList);
    }
    List<List<AdsInfoList>> sepList = splitAdList(groupAdsList, adGroupCount??5);
    int adIndex = 0;
    modelArr.removeWhere((element) => element.isAdsArr());
    int allCount = modelArr.length;
    for (int i = adGap; i <= allCount; i += adGap) {
      AllSectionModel adModel = AllSectionModel();
      int realIndex = adIndex % sepList.length;
      adModel.adsInfoArr = sepList[realIndex];
      int index = i ~/ adGap;
      modelArr.insert(i + (index - 1), adModel);
      adIndex++;
    }
  }

  static List<List<AdsInfoList>> splitAdList(List<AdsInfoList> adList, int gap) {
    if (adList.length <= gap) {
      return [adList];
    }
    List<List<AdsInfoList>> result = [];
    if(adList.length <= gap){
      result.add(adList);
    }else {
      int allIndex = adList.length ~/ gap;
      for (int i = 0; i < allIndex; i++) {
        result.add(adList.sublist(i * gap, (i + 1) * gap));
      }
      if (allIndex * gap < adList.length) {
        result.add(adList.sublist(allIndex * gap, adList.length));
      }
    }
    return result;
  }
}

List splitList(List list, int len) {
  if (len <= 1) {
    return [list];
  }
  List result = [];
  int index = 1;
  while (true) {
    if (index * len < list.length) {
      List temp = list.skip((index - 1) * len).take(len).toList();
      result.add(temp);
      index++;
      continue;
    }
    List temp = list.skip((index - 1) * len).toList();
    result.add(temp);
    break;
  }
  return result;
}
