import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///关于我们
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.cf5f5f5,
      appBar: commonAppBar("关于我们"),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.w),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            "本站属于特殊行业，如果您未满18岁或您当地法律许可之法定年龄、或是对情色反感或是卫道人士建议您离开本站！本站归类为限制级、限定为成年者已具有完整行为能力且愿接受本站内影音内容、及各项条款之网友才可浏览，未满18岁谢绝进入。",
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.sp,
              height: 1.8,
            ),
          ),
          SizedBox(height: 20.w),
          _buildBusinessUI("商务合作", Address.businessCooperation ?? ""),
          _buildBusinessUI("官方邮箱", Address.groupEmail ?? ""),
          _buildBusinessUI("下载地址", Address.landUrl ?? ""),
        ],
      ),
    );
  }

  ///商务合作
  Container _buildBusinessUI(String title, String url) => Container(
        height: 63.w,
        margin: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("$title $url",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800 , color: Colors.black),),
            SizedBox(
              width: 10.w,
              height: 10.w,
            ),
            GestureDetector(
              onTap: () {
                if (url.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: url));
                  showToast(msg: "复制成功");
                }
              },
              child: Container(
                width: 50.w,
                height: 24.w,
                // margin: EdgeInsets.only(top: 12.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(174, 174, 192, 0.2),
                    borderRadius: BorderRadius.circular(10.5)),
                child: Text("复制",
                    style: TextStyle(color: const Color.fromRGBO(176, 159, 217, 1), fontSize: 12.sp)),
              ),
            ),
          ],
        ),
      );
}
