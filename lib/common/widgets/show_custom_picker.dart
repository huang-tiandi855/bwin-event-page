import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/style/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as Date;

import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';

import '../utils/logger.dart';

Future<DateTime?> showDOBDatePicker(BuildContext context) async {
  final Future<DateTime?> date = Date.DatePicker.showDatePicker(context,
      showTitleActions: true,
      minTime: DateTime.now().subtract(const Duration(days: 32385)),
      maxTime: DateTime.now(),
      theme: Date.DatePickerTheme(
        headerColor: AppColor.kBackgroundColour,
        backgroundColor: AppColor.kBackgroundColour,
        itemStyle: AppTextStyles.kUserProfileTextStyle,
        doneStyle: AppTextStyles.kUserProfileTextStyle,
        cancelStyle: AppTextStyles.kUserProfileTextStyle,
      ), onChanged: (date) {
    l.d('change $date in time zone ${date.timeZoneOffset.inHours}');
  }, onConfirm: (date) {
    l.d('confirm date: $date');
  }, currentTime: DateTime.now(), locale: Date.LocaleType.zh);
  return date;
}

Future<String?> showLocationPicker(BuildContext context) async {
  String address = '';
  Pickers.showAddressPicker(
    context,
    pickerStyle: PickerStyle(
      backgroundColor: AppColor.kBackgroundColour,
      textColor: Colors.white,
      textSize: 16,
      commitButton: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 12, right: 22),
        child: Text('确定', style: AppTextStyles.kUserProfileTextStyle),
      ),
      cancelButton: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 12, right: 22),
        child: Text('取消', style: AppTextStyles.kUserProfileTextStyle),
      ),
      headDecoration: const BoxDecoration(color: AppColor.kBackgroundColour),
    ),
    onConfirm: (province, city, town) {
      l.d('city: $city');
      l.d('province: $province');
      address = city + province;
      l.d('inside address: $address');
      return address;
    },
  );
  l.d('final address: $address');
  return address;
}

Future<String?> showGenderPicker(BuildContext context) async {
  String address = '';
  var data = ['不公开', '男', '女'];
  Pickers.showSinglePicker(
      onCancel: (isCancel) {},
      onConfirm: (p, position) {},
      pickerStyle: PickerStyle(
        backgroundColor: AppColor.kBackgroundColour,
        textColor: Colors.white,
        textSize: 16,
        commitButton: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 12, right: 22),
          child: Text('确定', style: AppTextStyles.kUserProfileTextStyle),
        ),
        cancelButton: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 12, right: 22),
          child: Text('取消', style: AppTextStyles.kUserProfileTextStyle),
        ),
        headDecoration: const BoxDecoration(color: AppColor.kBackgroundColour),
      ),
      context,
      data: data);

  l.d('final address: $address');

  return address;
}
