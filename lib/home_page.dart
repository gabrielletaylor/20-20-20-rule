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
  Duration duration = Duration(days: 5);
  final reduceSecondsBy = 1;
  double percent = 0;
  static int timeInMinute = 20;
  int timeInSec = timeInMinute * 60;
  double secPercentage = 0;
  bool startPressed = false;

  @override
  void initState() {
    super.initState();
  }

  void startTimer() {
    // if (!countdownTimer!.isActive) {
    startPressed = true;
    timeInMinute = 20;
    secPercentage = (timeInSec / 100);
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) => setCountdown());
    // }
  }

  void pauseTimer() {
    setState(() => countdownTimer!.cancel());
    startPressed = false;
  }

  void resetTimer() {
    pauseTimer();
    percent = 0;
    timeInMinute = 20;
    timeInSec = timeInMinute * 60;
    setState(() => duration = Duration(days: 5));
  }

  void setCountdown() {
    setState(() {
      final seconds = duration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        percent = 0;
        timeInMinute = 20;
        timeInSec = timeInMinute * 60;
        countdownTimer!.cancel();
      }
      else {
        duration = Duration(seconds: seconds);
        timeInSec--;
        if (timeInSec % 60 == 0) {
          timeInMinute--;
        }

        if (timeInSec % secPercentage == 0) {
          if (percent < 1) {
            percent += 0.01;
          } else {
            percent = 1;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final days = strDigits(duration.inDays);
    final minutes = strDigits(duration.inMinutes.remainder(20));
    final seconds = strDigits(duration.inSeconds.remainder(60));

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
                                  child: const Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Text(
                                      'Start Timer',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (!startPressed) {
                                      startTimer();
                                    }
                                    // startTimer();
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
                                      'Pause Timer',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (countdownTimer == null || countdownTimer!.isActive) {
                                      pauseTimer();
                                    }
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

// class _HomePageState extends State<HomePage> {
//   // Step 2
//   Timer? countdownTimer;
//   Duration myDuration = Duration(days: 5);
//   bool startPressed = false;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//   /// Timer related methods ///
//   // Step 3
//   void startTimer() {
//     print(startPressed);
//     if (startPressed) {
//       countdownTimer =
//           Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
//     }
//   }
//   // Step 4
//   void stopTimer() {
//     setState(() => countdownTimer!.cancel());
//   }
//   // Step 5
//   void resetTimer() {
//     stopTimer();
//     setState(() => myDuration = Duration(days: 5));
//   }
//   // Step 6
//   void setCountDown() {
//     final reduceSecondsBy = 1;
//     setState(() {
//       final seconds = myDuration.inSeconds - reduceSecondsBy;
//       if (seconds < 0) {
//         countdownTimer!.cancel();
//       } else {
//         myDuration = Duration(seconds: seconds);
//       }
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     String strDigits(int n) => n.toString().padLeft(2, '0');
//     final days = strDigits(myDuration.inDays);
//     // Step 7
//     // final hours = strDigits(myDuration.inHours.remainder(24));
//     final minutes = strDigits(myDuration.inMinutes.remainder(20));
//     final seconds = strDigits(myDuration.inSeconds.remainder(60));
//     return Scaffold(
//       // appBar: ...,
//       body: Center(
//         child: Column(
//           children: [
//             SizedBox(
//               height: 50,
//             ),
//             // Step 8
//             Text(
//               '$minutes:$seconds',
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                   fontSize: 50),
//             ),
//             SizedBox(height: 20),
//             // Step 9
//             ElevatedButton(
//               onPressed: () {
//                 startPressed = true;
//                 startTimer();
//               },
//               child: Text(
//                 'Start',
//                 style: TextStyle(
//                   fontSize: 30,
//                 ),
//               ),
//             ),
//             // Step 10
//             ElevatedButton(
//               onPressed: () {
//                 if (countdownTimer == null || countdownTimer!.isActive) {
//                   stopTimer();
//                 }
//               },
//               child: Text(
//                 'Stop',
//                 style: TextStyle(
//                   fontSize: 30,
//                 ),
//               ),
//             ),
//             // Step 11
//             ElevatedButton(
//                 onPressed: () {
//                   resetTimer();
//                 },
//                 child: Text(
//                   'Reset',
//                   style: TextStyle(
//                     fontSize: 30,
//                   ),
//                 ))
//           ],
//         ),
//       ),
//     );
//   }
// }