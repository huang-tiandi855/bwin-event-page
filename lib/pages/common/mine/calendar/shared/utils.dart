// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:flutter/widgets.dart';

/// Signature for a function that creates a widget for a given `day`.
typedef DayBuilder = Widget Function(BuildContext context, DateTime day);

/// Signature for a function that creates a widget for a given `day`.
/// Additionally, contains the currently focused day.
typedef FocusedDayBuilder = Widget Function(
    BuildContext context, DateTime day, DateTime focusedDay);

/// Signature for a function returning text that can be localized and formatted with `DateFormat`.
typedef TextFormatter = String Function(DateTime date, dynamic locale);

/// Gestures available for the calendar.
enum AvailableGestures { none, verticalSwipe, horizontalSwipe, all }

/// Formats that the calendar can display.
enum CalendarFormat { month, twoWeeks, week }

/// Days of the week that the calendar can start with.
enum StartingDayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

/// Returns a numerical value associated with given `weekday`.
///
/// Returns 1 for `StartingDayOfWeek.monday`, all the way to 7 for `StartingDayOfWeek.sunday`.
int getWeekdayNumber(StartingDayOfWeek weekday) {
  return StartingDayOfWeek.values.indexOf(weekday) + 1;
}

/// Returns `date` in UTC format, without its time part.
DateTime normalizeDate(DateTime date) {
  return DateTime.utc(date.year, date.month, date.day);
}

/// Checks if two DateTime objects are the same day.
/// Returns `false` if either of them is null.
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }

  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool moreThanToDay(DateTime? day) {
  if (day == null) {
    return false;
  }
  DateTime today = DateTime.now();
  bool isAfter = today.isAfter(day);
  debugPrint("more than to day = $isAfter");
  debugPrint("day = $day");
  debugPrint("today = $today");
  return today.isAfter(day);
}

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
  ..addAll({
    kToday: [
      const Event('Today\'s Event 1'),
      const Event('Today\'s Event 2'),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
        (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

Map<DateTime, DateTime>? obtainCurrentYear(String sDay) {
  DateTime sd = DateTime.parse(sDay);
  switch (sd.month) {
    case 1:
      return {sd: DateTime(sd.year, sd.month + 11, sd.day)};
    case 2:
      return {
        DateTime(sd.year, sd.month - 1, sd.day):
        DateTime(sd.year, sd.month + 10, sd.day)
      };
    case 3:
      return {
        DateTime(sd.year, sd.month - 2, sd.day):
        DateTime(sd.year, sd.month + 9, sd.day)
      };
    case 4:
      return {
        DateTime(sd.year, sd.month - 3, sd.day):
        DateTime(sd.year, sd.month + 8, sd.day)
      };
    case 5:
      return {
        DateTime(sd.year, sd.month - 4, sd.day):
        DateTime(sd.year, sd.month + 7, sd.day)
      };
    case 6:
      return {
        DateTime(sd.year, sd.month - 5, sd.day):
        DateTime(sd.year, sd.month + 6, sd.day)
      };
    case 7:
      return {
        DateTime(sd.year, sd.month - 6, sd.day):
        DateTime(sd.year, sd.month + 5, sd.day)
      };
    case 8:
      return {
        DateTime(sd.year, sd.month - 7, sd.day):
        DateTime(sd.year, sd.month + 4, sd.day)
      };
    case 9:
      return {
        DateTime(sd.year, sd.month - 8, sd.day):
        DateTime(sd.year, sd.month + 3, sd.day)
      };
    case 10:
      return {
        DateTime(sd.year, sd.month - 9, sd.day):
        DateTime(sd.year, sd.month + 2, sd.day)
      };
    case 11:
      return {
        DateTime(sd.year, sd.month - 10, sd.day):
        DateTime(sd.year, sd.month + 1, sd.day)
      };
    case 12:
      return {
        DateTime(sd.year, sd.month - 11, sd.day):
        DateTime(sd.year, sd.month, sd.day)
      };
    default:
      return null;
  }
}

Map<DateTime, DateTime> obtainStartEndDays(String sDay, String eDay) {
  DateTime sd = DateTime.parse(sDay);
  DateTime ed = DateTime.parse(eDay);
  return { DateTime(sd.year,sd.month,sd.day):  DateTime(ed.year,ed.month,ed.day)};
}

bool judgeRangeTime(DateTime st, DateTime et, DateTime dt) {
  debugPrint("st = $st   --- et = $et");
  List<DateTime> rangeList = daysInRange(st,et);
  bool hasContains = rangeList.contains(dt);
  debugPrint("hasContains = $hasContains");

  return hasContains;
}