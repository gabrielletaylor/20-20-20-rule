import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? countdownTimer;
  Duration duration = Duration(minutes: 1);
  final reduceSecondsBy = 1;
  double percent = 0;
  static int timeInMinute = 1;
  int timeInSec = timeInMinute * 60;
  double secPercentage = 0;
  String startOrPause = "Start Timer";
  int timesPressed = 0;
  bool timerAlmostDone = false, timerDone = false;
  int timeRemaining = 20;

  @override
  void initState() {
    super.initState();
  }

  void getTimerOption() {
    // pause timer
    if (timesPressed % 2 == 0) {
        pauseTimer();
    }
    // start timer
    else {
      startTimer();
    }
  }

  void startTimer() {
    timerDone = false;
    secPercentage = (timeInSec / 100);
    setState(() => startOrPause = "Pause Timer");
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) => setCountdown());
  }

  void pauseTimer() {
    setState(() {
      startOrPause = "Start Timer";
      countdownTimer!.cancel();
    });
  }

  void resetTimer() {
    pauseTimer();
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
        timerDone = true;
        setState(() {
          resetTimer();
          _showMyDialog();
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

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('20 minutes are up!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Look at something 20 feet away for 20 seconds.'),
                Text('\nTime remaining: $timeRemaining'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
    if (minutes == "00" && (!timerAlmostDone || timerDone)) {
      minutes = "01";
    }

    return SafeArea(
      child: Scaffold(
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
                      fontFamily: 'RobotoMono'
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
                                    resetTimer();
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