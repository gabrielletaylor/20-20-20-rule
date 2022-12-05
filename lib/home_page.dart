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
  Duration duration = Duration(minutes: 1);
  final reduceSecondsBy = 1;
  double percent = 0, secPercentage = 0;
  static int timeInMinute = 1;
  int timeInSec = timeInMinute * 60;
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
    secPercentage = (timeInSec / 100);
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
    timeInMinute = 1;
    timeInSec = timeInMinute * 60;
    setState(() => duration = Duration(minutes: 1));
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
          duration = Duration(minutes: 1);
        });
      }
      else {
        duration = Duration(seconds: sec);
        timeInSec--;
        if (timeInSec % 60 == 0) {
          timeInMinute--;
        }
        if (timeInSec / 60 <= 1) {
          timerAlmostDone = true;
        }
        if (timeInSec % secPercentage == 0) {
          if (percent < 1) {
            if (percent + 0.01 < 1) {
              percent += 0.01;
            }
          } else {
            percent = 1;
          }
        }
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
              fontSize: 27,
              color: Color(0xff6a8759)
            ),
          ),
          backgroundColor: Color(0xff313335),
          content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(
                    '\nTime to rest for 20 seconds.',
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff9876aa)
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
            'Look at something 20 feet away for 20 seconds.',
            style: TextStyle(
              fontSize: 25,
              color: Color(0xff6a8759)
            ),
          ),
          backgroundColor: Color(0xff313335),
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
                            color: Color(0xff9876aa)
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
    String minutes = strDigits(duration.inMinutes.remainder(1));
    String seconds = strDigits(duration.inSeconds.remainder(60));
    if (minutes == "00" && (!timerAlmostDone || twentyMinTimerDone)) {
      minutes = "01";
    }

    /*
    * green 0xff6a8759 - strings
    * purple 0xff9876aa - variables
    * orange 0xffcc7832 - keywords
    * yellow 0xffffc66d - widgets/method names
    * blue 0xff6897bb - values (int, double)
    * white over dark 0xffa9b7c6
    * white over light 0xffbbbbbb
    * med gray 0xff313335 - line number area
    * red 0xffbd3f3c - error squiggle
    * */
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
              flex: 55,
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
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 35,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xff3c3f41),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24.0),
                    topLeft: Radius.circular(24.0),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 30, left: 25, right: 25),
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
                                // SizedBox(
                                //   height: 10.0,
                                // ),
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
                                      color: Color(0xffcc7832)
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
                                      color: Color(0xffcc7832)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 23, left: 20, right: 20),
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
                                  primary: Color(0xffffc66d),
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
                                  primary: Color(0xffffc66d),
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("20-20-20 Rule"),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade600,
                  Colors.blue.shade400
                ],
                begin: const FractionalOffset(.25, 1),
                end: const FractionalOffset(.75, .25)),
          ),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Text(
                  '20-20-20 Rule',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                  ),
                ),
              ),
              Expanded(
                child: CircularPercentIndicator(
                  circularStrokeCap: CircularStrokeCap.round,
                  percent: percent,
                  animation: true,
                  animateFromLastPercent: true,
                  radius: 150.0,
                  lineWidth: 16.0,
                  progressColor: Colors.amber,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$minutes:$seconds',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24.0),
                      topLeft: Radius.circular(24.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 30.0, left: 20.0, right: 20.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: const [
                                    Text(
                                      'Activity Time',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      "20",
                                      style: TextStyle(fontSize: 60.0),
                                    ),
                                    Text(
                                      "minutes",
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: const [
                                    Text(
                                      'Rest Time',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      "20",
                                      style: TextStyle(fontSize: 60.0),
                                    ),
                                    Text(
                                      "seconds",
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40.0),
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
                                    primary: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40.0),
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
                                    primary: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}