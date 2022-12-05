import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? twentyMinTimer, twentySecTimer;
  static int timeInMin = 20;
  Duration duration = Duration(minutes: timeInMin);
  final reduceSecondsBy = 1;
  double percent = 0;
  int timeInSec = timeInMin * 60;
  String startOrPause = "Start Timer";
  int timesPressed = 0;
  bool timerAlmostDone = false, twentyMinTimerDone = false, twentySecTimerDone = false;
  StreamController<int> streamEvents = StreamController<int>();

  @override
  void initState() {
    super.initState();
    streamEvents = StreamController<int>();
    streamEvents.add(20);
  }

  void getTimerOption() {
    // pause timer
    if (timesPressed % 2 == 0) {
        pause20MinTimer();
    }
    // start timer
    else {
      start20MinTimer();
    }
  }

  void start20MinTimer() {
    twentyMinTimerDone = false;
    setState(() => startOrPause = "Pause Timer");
    twentyMinTimer = Timer.periodic(Duration(seconds: 1), (_) => setCountdown());
  }

  void pause20MinTimer() {
    setState(() {
      startOrPause = "Start Timer";
      twentyMinTimer!.cancel();
    });
  }

  void reset20MinTimer() {
    pause20MinTimer();
    timerAlmostDone = false;
    timesPressed = 0;
    percent = 0;
    setState(() => duration = Duration(minutes: timeInMin));
  }

  void setCountdown() {
    setState(() {
      final sec = duration.inSeconds - reduceSecondsBy;
      if (sec < 0) {
        twentyMinTimerDone = true;
        FlutterRingtonePlayer.playNotification();
        setState(() {
          reset20MinTimer();
          readyMessage();
          startOrPause = "Start Timer";
          duration = Duration(minutes: timeInMin);
        });
      }
      else {
        duration = Duration(seconds: sec);
        if (sec / 60 <= 1) {
          timerAlmostDone = true;
        }
        percent = 1 - (sec / timeInSec);
      }
    });
  }

  void start20SecTimer() {
    int _counter = 20;
    streamEvents = StreamController<int>();
    streamEvents.add(20);
    if (twentySecTimer != null) {
      twentySecTimer!.cancel();
    }
    twentySecTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        _counter--;
      }
      else {
        FlutterRingtonePlayer.playNotification();
        twentySecTimer!.cancel();
        twentySecTimerDone = true;
      }
      streamEvents.add(_counter);
    });
  }

  Future<void> readyMessage() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "\"20 minutes are up!\"",
            style: TextStyle(
              fontSize: 26,
              color: Color(0xff6a8759)
            ),
          ),
          backgroundColor: Color(0xff3c3f41),
          content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(
                    '\nTime to rest for 20 seconds.',
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xffbbbbbb)
                    ),
                  ),
                ],
              ),
            ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10),
              child: TextButton(
                child: const Text(
                  'Ready',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xffffc66d)
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  start20SecTimer();
                  popUpMessage();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> popUpMessage() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "\"Look at something 20 feet away for 20 seconds.\"",
            style: TextStyle(
              fontSize: 24,
              color: Color(0xff6a8759)
            ),
          ),
          backgroundColor: Color(0xff3c3f41),
          content: StreamBuilder<int>(
            stream: streamEvents.stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return SingleChildScrollView(
                child: ListBody(
                  children: [
                    Row(
                      children: [
                        Text(
                          '\nTime remaining: ',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xffbbbbbb)
                          ),
                        ),
                        Text(
                          '\n${snapshot.data.toString()}',
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xff6897bb)
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              );
            },
          ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10),
              child: TextButton(
                child: const Text(
                  'Done',
                  style: TextStyle(
                      fontSize: 16,
                      color: Color(0xffffc66d)
                  ),
                ),
                onPressed: () {
                  if (twentySecTimerDone) {
                    twentySecTimerDone = false;
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = strDigits(duration.inMinutes.remainder(timeInMin));
    String seconds = strDigits(duration.inSeconds.remainder(60));
    DateTime timeNow = DateTime.now();
    late DateTime inTwenty;
    String timeInTwenty = '';
    if (minutes == "00") {
      if (!timerAlmostDone || twentyMinTimerDone) {
        minutes = timeInMin.toString().padLeft(2, '0');
      }
      if (seconds == "00") {
        inTwenty = timeNow.add(Duration(minutes: timeInMin));
      }
      else {
        inTwenty = timeNow.add(Duration(seconds: int.parse(seconds)));
      }
    }
    else {
      inTwenty = timeNow.add(Duration(minutes: int.parse(minutes), seconds: int.parse(seconds)));
    }
    setState(() {
      timeInTwenty = (inTwenty.hour).toString().padLeft(2, '0') + ":" + (inTwenty.minute).toString().padLeft(2, '0');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "20-20-20 Rule",
          style: TextStyle(
            color: Color(0xffbbbbbb)
          ),
        ),
      ),
      backgroundColor: Color(0xff2b2b2b),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 25,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xff313335),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(top: 25, left: 20, right: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: const [
                            Text(
                              "\"Activity Time\"",
                              style: TextStyle(
                                  fontSize: 19.0,
                                  color: Color(0xff6a8759)
                              ),
                            ),
                            Text(
                              "20",
                              style: TextStyle(
                                  fontSize: 60.0,
                                  color: Color(0xff6897bb)
                              ),
                            ),
                            Text(
                              "minutes",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xff9876aa)
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: const [
                            Text(
                              "\"Rest Time\"",
                              style: TextStyle(
                                  fontSize: 19.0,
                                  color: Color(0xff6a8759)
                              ),
                            ),
                            Text(
                              "20",
                              style: TextStyle(
                                  fontSize: 60.0,
                                  color: Color(0xff6897bb)
                              ),
                            ),
                            Text(
                              "seconds",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xff9876aa)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),),
            Expanded(
              flex: 50,
              child: Container(
                margin: EdgeInsets.only(top: 40),
                child: CircularPercentIndicator(
                  circularStrokeCap: CircularStrokeCap.round,
                  percent: percent,
                  animation: true,
                  animateFromLastPercent: true,
                  radius: 150.0,
                  lineWidth: 15.0,
                  backgroundColor: Color(0xffa9b7c6),
                  progressColor: Color(0xffbd3f3c),
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$minutes:$seconds',
                        style: const TextStyle(
                          color: Color(0xffa9b7c6),
                          fontSize: 50,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.alarm,
                            color: Color(0xff808080),
                          ),
                          Text(
                            ' $timeInTwenty',
                            style: const TextStyle(
                              color: Color(0xff808080),
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 25,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 7),
                              child: ElevatedButton(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    '$startOrPause',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  timesPressed++;
                                  getTimerOption();
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 4,
                                  primary: Color(0xfffcc642),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 7),
                              child: ElevatedButton(
                                child: const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    'Reset Timer',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  reset20MinTimer();
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 4,
                                  primary: Color(0xfffcc642),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}