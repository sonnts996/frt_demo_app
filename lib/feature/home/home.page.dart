/*
 Created by Thanh Son on 28/09/2022.
 Copyright (c) 2022 . All rights reserved.
*/
import 'package:age_calculator/age_calculator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  ValueNotifier<DateTime?> date = ValueNotifier(null);
  ValueNotifier<String> waitingMessage = ValueNotifier('');

  String get displayDate {
    if (date.value == null) {
      return 'Chọn ngày...';
    }
    return DateFormat('dd/MM/yyyy').format(date.value!);
  }

  Future _showDialog(Widget child) {
    return showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 16),
              // The Bottom margin is provided to align the popup above the system navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }

  Future<DateTime?> pickADate() async {
    DateTime? _date;
    final now = DateTime.now();
    await _showDialog(CupertinoDatePicker(
        initialDateTime: now,
        maximumDate: now,
        minimumDate: DateTime(1950, 1, 1),
        mode: CupertinoDatePickerMode.date,
        backgroundColor: Colors.white,
        onDateTimeChanged: (date) {
          _date = date;
        }));
    return _date;
  }

  String age2String(DateDuration age) {
    String s = '';
    if (age.years > 0) {
      s += '${age.years} năm ';
    }
    if (age.months > 0) {
      s += '${age.months} tháng ';
    }
    if (age.days > 0 || s == '') {
      s += '${age.days} ngày ';
    }
    return s.trim();
  }

  void nhay(DateTime? date) async {
    if (date != null) {
      waitingMessage.value = 'Chờ chút nha';
      showDialog(
          context: context,
          builder: (context) => Container(
                color: Colors.black45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SpinKitChasingDots(color: Colors.white),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<String>(
                      valueListenable: waitingMessage,
                      builder: (context, value, child) => Text(
                        value,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.apply(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ));
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        waitingMessage.value = 'Chờ chút, AI đang tính...';
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        waitingMessage.value = '...xong rồi nè...';
      });
      await Future.delayed(const Duration(seconds: 3));
      setState(() {
        Navigator.pop(context);
        this.date.value = date;
      });
    }
  }

  Future<String> getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber} - ${info.packageName}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 56, top: 64),
                    child: Text(
                      'How old are you?',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  const Text('Cho tui biết ngày sinh của bạn: '),
                  GestureDetector(
                    onTap: () async {
                      final _date = await pickADate();
                      nhay(_date);
                    },
                    child: Container(
                      width: 200,
                      child: Row(children: [
                        const Icon(CupertinoIcons.calendar),
                        Expanded(
                            child: Text(
                          displayDate,
                          textAlign: TextAlign.center,
                        ))
                      ]),
                      margin: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 16),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                offset: Offset(5, 5),
                                blurRadius: 10)
                          ]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Tui đã tính được kết quả là bạn đã sống: '),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<DateTime?>(
                      valueListenable: date,
                      builder: (context, value, child) {
                        if (value != null) {
                          final age = AgeCalculator.age(value);
                          return Text(
                            age2String(age),
                            style: Theme.of(context).textTheme.titleLarge,
                          );
                        } else {
                          return Text(
                            'Tui chưa biết tuổi của bạn!',
                            style: Theme.of(context).textTheme.labelSmall,
                          );
                        }
                      }),
                  const SizedBox(height: 24),
                  const Text(
                      'Còn nhiêu đây ngày nữa là tới sinh nhật kết của bạn: '),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<DateTime?>(
                      valueListenable: date,
                      builder: (context, value, child) {
                        if (value != null) {
                          final age = AgeCalculator.timeToNextBirthday(value);
                          return Text(
                            age2String(age),
                            style: Theme.of(context).textTheme.titleLarge,
                          );
                        } else {
                          return Text(
                            'Tui chưa biết tuổi của bạn!',
                            style: Theme.of(context).textTheme.labelSmall,
                          );
                        }
                      }),
                  const Spacer(),
                  FutureBuilder<String>(
                      future: getVersion(),
                      builder: (context, snapshot) {
                        return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(snapshot.data ?? '...'));
                      }),
                ]),
          ),
        ),
      );
}
