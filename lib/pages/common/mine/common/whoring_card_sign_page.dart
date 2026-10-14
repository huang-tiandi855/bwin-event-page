import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/pages/common/mine/calendar/table_calendar.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/store/store.dart';
import '../../../../common/values/widgetAttibutes/RoundUnderlineTablndicator.dart';
import '../calendar/customization/calendar_builders.dart';
import '../calendar/shared/utils.dart';

import 'package:comics_app/common/utils/logger.dart';

class WhoringCardSignPage extends StatefulWidget {
  const WhoringCardSignPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WhoringCardSignPageState();
  }
}

class _WhoringCardSignPageState extends State<WhoringCardSignPage>
    with TickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime _focusedDay = DateTime.now();

  List<String> mouthList = [
    "1月",
    "2月",
    "3月",
    "4月",
    "5月",
    "6月",
    "7月",
    "8月",
    "9月",
    "10月",
    "11月",
    "12月"
  ];

  Map<DateTime, DateTime>? startEndDates;

  Map<DateTime, DateTime>? startEndDays;

  DateTime? startDays;

  DateTime? endDays;

  // List<RecordTimeModel>? records ;

  // DetailInfo? info;

  TabController? tabController;

  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    parseDate();
  }

  void parseDate() {
    // if(UserStore.to.getUserInfoModel!.whoringCardClass!.detailInfo!.isNotEmpty){
    //   info = UserStore.to.getUserInfoModel?.whoringCardClass?.detailInfo![0];
    //   records = info?.recordTime;
    //   l.d("info = $info");
    //   DateTime st =   DateTime.parse(info!.startTime);
    //   l.d("startTime = $st");
    //   l.d("startTime = ${st.month}");
    //   startEndDates = obtainCurrentYear(info!.startTime);
    //   l.d("se = ${startEndDates?.keys}");
    //   l.d("se = ${startEndDates?.values}");
    //   startEndDays = obtainStartEndDays(info!.startTime, info!.endTime);
    //   l.d("startEndDays = ${startEndDays?.values}");
    //   if(startEndDays!.keys.isNotEmpty?? false){
    //     startDays = startEndDays!.keys.first;
    //   l.d("startDays = ${startDays}");
    //   }
    //   if(startEndDays!.values.isNotEmpty?? false){
    //     endDays = moreThanToDay(startEndDays?.values.first) ? startEndDays?.values.first : DateTime.now();
    //     l.d("endDays = ${endDays}");
    //   }
    // }

    tabController = TabController(length: 12, vsync: this, initialIndex: 0);
    tabController!.addListener(() {
      changeTab(tabController!.index);
    });
  }

  @override
  void dispose() {
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(left: 16, right: 16),
          // decoration: const BoxDecoration(
          //   image: DecorationImage(
          //     fit: BoxFit.cover,
          //     image: AssetImage('assets/images/whoring_card_sign_bg.png'),
          //   ),
          // ),
          child: Stack(children: [
            Column(
              children: [
                const SizedBox(height: 15),
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Image.asset(
                          'assets/images/back_arrow.png',
                          width: 28,
                          height: 28,
                        )),
                    const Spacer(),
                  ],
                ),
                signView(),
                const SizedBox(
                  height: 18,
                ),
                signPanelView(),
                const SizedBox(
                  height: 18,
                ),
                calendarWidget(),
                const SizedBox(
                  height: 26,
                ),
                noteView(),
              ],
            ),
            Positioned(
                top: 199,
                left: 20,
                child: Container(
                  width: 10,
                  height: 44,
                  decoration: ShapeDecoration(
                    color: const Color.fromRGBO(230, 230, 230, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                )),
            Positioned(
                top: 199,
                right: 20,
                child: Container(
                  width: 10,
                  height: 44,
                  decoration: ShapeDecoration(
                    color: const Color.fromRGBO(230, 230, 230, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                )),
          ]),
        ),
      ),
    );
  }

  void changeTab(int index) {
    _pageController?.animateToPage(index,
        duration: const Duration(microseconds: 300), curve: Curves.ease);
  }

  Widget noteView() {
    return const SizedBox(
      width: 391.48,
      height: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '温馨提醒：',
            style: TextStyle(
              color: Color.fromRGBO(252, 65, 98, 1),
              fontSize: 13.70,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4.57),
          SizedBox(
            width: 391.48,
            child: Text(
              '连续登录打卡完成任务,获得全额返现奖励;\n补签金额递增，依次递增为10/20/40 金币\n✓为已打卡,ㄨ为未打卡\n点击补签即可补齐打卡天数',
              style: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget signView() {
    return Padding(
        padding: const EdgeInsets.only(top: 28),
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: [
            const Text(
              '登录打卡',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(51, 51, 51, 1),
                fontSize: 16,
              ),
            ),
            GestureDetector(
              onTap: () async {
                Map<String, dynamic> data = {
                  "pid":
                      "UserStore.to.getUserInfoModel?.whoringCardClass?.detailInfo![0].id",
                };

                BaseRespBean baseRespBean = await UserApi.postSign(data);

                if (baseRespBean.isSuccess) {
                  showToast(msg: "补签成功");

                  UserStore.to.refreshUser().then((value) {
                    parseDate();

                    setState(() {});
                  });

                  return;
                }

                if (baseRespBean.code == 8000) {
                  showDialog(
                      barrierDismissible: true,
                      context: Get.context!,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                height: 252,
                                alignment: Alignment.center,
                                width: ScreenUtil.getScreenW(context),
                                decoration: ShapeDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment(0.00, -1.00),
                                    end: Alignment(0, 1),
                                    colors: [Color(0xFFE5FDFF), Colors.white],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    const Text(
                                      '温馨提示',
                                      style: TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    const Opacity(
                                      opacity: 0.90,
                                      child: Text(
                                        '您当前金豆余额不足',
                                        style: TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Opacity(
                                      opacity: 0.90,
                                      child: Text(
                                        '前往购买金豆 返回继续操作',
                                        style: TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Get.back();
                                          },
                                          child: SizedBox(
                                            width: 108,
                                            height: 38,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 0,
                                                  top: 0,
                                                  child: Container(
                                                    width: 108,
                                                    height: 38,
                                                    decoration: ShapeDecoration(
                                                      color: const Color(
                                                          0xFFB3B3B3),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(19),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Positioned(
                                                  left: 26,
                                                  top: 9,
                                                  child: Text(
                                                    '稍后再说',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Get.toNamed(AppRoutes.MEMBER_CENTER,
                                                arguments: {"initialIndex": 1});
                                          },
                                          child: SizedBox(
                                            width: 136,
                                            height: 38,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 0,
                                                  top: 0,
                                                  child: Container(
                                                    width: 136,
                                                    height: 38,
                                                    decoration: ShapeDecoration(
                                                      color: const Color(
                                                          0xFF94D6DA),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(19),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Positioned(
                                                  left: 40,
                                                  top: 9,
                                                  child: Text(
                                                    '前往购买',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Opacity(
                                      opacity: 0.10,
                                      child: Container(
                                        width: 296,
                                        height: 1,
                                        decoration: const BoxDecoration(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        );
                      }).then((value) {});
                } else {
                  showToast(msg: "补签成功");
                }
              },
              child: Visibility(
                  maintainState: true,
                  visible: true,
                  child: Container(
                      padding: const EdgeInsets.only(
                          left: 12, right: 12, top: 2, bottom: 2),
                      alignment: Alignment.center,
                      height: 30,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: const Color.fromRGBO(148, 214, 218, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        '${"info!.renewalSignPrice"}金币/补签打卡',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ))),
            ),
          ],
        ));
  }

  Widget calendarWidget() {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      // decoration: const BoxDecoration(
      //     image: DecorationImage(
      //         image: AssetImage("assets/images/sign_bj.png"),
      //         fit: BoxFit.cover)),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            width: ScreenUtil.getScreenW(context),
            child: TabBar(
              onTap: (int index) {
                changeTab(index);
              },
              controller: tabController,
              tabs: obtainTabWidgets(),
              indicator: const RoundUnderlineTabIndicator(
                borderSide: BorderSide(
                    color: Color.fromRGBO(148, 214, 218, 1), width: 3),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              unselectedLabelColor: const Color.fromRGBO(153, 153, 153, 1),
              unselectedLabelStyle: const TextStyle(fontSize: 18),
              labelColor: const Color.fromRGBO(51, 51, 51, 1),
              isScrollable: true,
              labelStyle: const TextStyle(fontSize: 18),
              //labelPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
          Container(
            height: 1,
            decoration:
                const BoxDecoration(color: Color.fromRGBO(230, 230, 230, 1)),
          ),
          Container(
            height: 2,
          ),
          Container(
              margin: const EdgeInsets.only(top: 18),
              height: 290,
              child: calendarView())
        ],
      ),
    );
  }

  List<Widget> obtainTabWidgets() {
    List<Widget> list = [];
    for (var element in mouthList) {
      list.add(Text(
        element,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ));
    }
    return list;
  }

  Widget calendarView() {
    if (startEndDates == null) {
      l.d("startEndDates = $startEndDates");
      return const SizedBox();
    }
    return TableCalendar(
      firstDay: DateTime(kToday.year, 1, 1),
      lastDay: DateTime(kToday.year, 12, 31),
      onCalendarCreated: (controller) => _pageController = controller,
      headerVisible: false,
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          // Call `setState()` when updating calendar format
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (index, focusedDay) {
        // No need to call `setState()` here
        l.d("focusedDay = $focusedDay   index = $index");
        tabController?.animateTo(index,
            duration: const Duration(microseconds: 300), curve: Curves.ease);
        _focusedDay = focusedDay;
      },
      calendarBuilders:
          CalendarBuilders<Widget>(defaultBuilder: (context, day, focusedDay) {
        return _defaultBuilder(context, day, focusedDay);
      }, todayBuilder: (context, day, focusedDay) {
        return _defaultBuilder(context, day, focusedDay);
      }),
    );
  }

  Widget _defaultBuilder(context, day, focusedDay) {
    bool isRange = judgeRangeTime(startDays ?? DateTime.now(), endDays!, day);
    if (isRange) {
      // if(records != null && records!.isNotEmpty){
      //   var sameDay = records
      //       !.where((element) => isSameDay(DateTime.parse(element.signTime), day));
      //   if(sameDay.isNotEmpty){
      //     return sameDay.first.isSign ? _signDay(day) : _unSignDay(day);
      //   }else{
      //     return _signDay(day);
      //   }
      // }else{
      //   if(moreThanToDay(day)){
      //     return _signDay(day);
      //   }
      // }
    }

    return _defaultDay(day);
  }

  Widget _defaultDay(DateTime day) {
    return Center(
      child: Text(
        "${day.day}",

        style:
            const TextStyle(color: Color.fromRGBO(51, 51, 51, 1), fontSize: 14),

        //style: const TextStyle(color: Color(0xFFE6E6E6),fontSize: 12),
      ),
    );
  }

  Widget signPanelView() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      height: 92,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: [
            panelItemView('连续打卡', 0),
            panelItemView('需要打卡', 0),
            panelItemView('忘记打卡', 0),
          ]),
    );
  }

  Widget panelItemView(String title, int dayNum) {
    return SizedBox(
      height: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$dayNum",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: title == "连续打卡"
                      ? const Color.fromRGBO(252, 65, 98, 1)
                      : const Color.fromRGBO(102, 102, 102, 1),
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '天',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
