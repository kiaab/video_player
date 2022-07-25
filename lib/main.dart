import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final VideoPlayerController _controller =
      VideoPlayerController.asset('assets/video.mp4')
        ..initialize()
        ..setLooping(true)
        ..play();

  bool isControlPanelShowing = false;
  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  Timer? timer;

  void initControlPanelTiming() {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 4), () {
      setState(() {
        isControlPanelShowing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (!isControlPanelShowing) {
                      isControlPanelShowing = true;
                      initControlPanelTiming();
                    }
                  });
                },
                child: VideoPlayer(_controller))),
        if (isControlPanelShowing)
          ControlPanel(
            controller: _controller,
            onTap: () {
              if (isControlPanelShowing) {
                setState(() {
                  isControlPanelShowing = false;
                });
              }
            },
          )
      ]),
    );
  }
}

class ControlPanel extends StatefulWidget {
  const ControlPanel({
    Key? key,
    required VideoPlayerController controller,
    required this.onTap,
  })  : _controller = controller,
        super(key: key);

  final VideoPlayerController _controller;
  final GestureTapCallback onTap;

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 46, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/profile3.jpg',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'James Jonas',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text('@jamesjons',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          )),
                    ],
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('captivate lesson chapter 2',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 2,
                  ),
                  const Text('by matin ebrahimpanah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      )),
                  const SizedBox(
                    height: 8,
                  ),
                  VideoProgressIndicator(
                    widget._controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        bufferedColor: Colors.white),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  VideoDuraton(widget: widget),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            iconSize: 22,
                            onPressed: () {
                              widget._controller.seekTo(
                                  widget._controller.value.position -
                                      const Duration(seconds: 5));
                            },
                            icon: const Icon(
                              CupertinoIcons.backward_fill,
                              color: Colors.white,
                            )),
                        IconButton(
                            iconSize: 50,
                            onPressed: () {
                              if (widget._controller.value.isPlaying) {
                                setState(() {
                                  widget._controller.pause();
                                });
                              } else {
                                setState(() {
                                  widget._controller.play();
                                });
                              }
                            },
                            icon: widget._controller.value.isPlaying
                                ? const Icon(
                                    CupertinoIcons.pause_circle_fill,
                                    color: Colors.white,
                                  )
                                : const Icon(CupertinoIcons.play_circle_fill,
                                    color: Colors.white)),
                        IconButton(
                            iconSize: 22,
                            onPressed: () {
                              widget._controller.seekTo(
                                  widget._controller.value.position +
                                      const Duration(seconds: 5));
                            },
                            icon: const Icon(CupertinoIcons.forward_fill,
                                color: Colors.white)),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }
}

class VideoDuraton extends StatefulWidget {
  const VideoDuraton({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final ControlPanel widget;

  @override
  State<VideoDuraton> createState() => _VideoDuratonState();
}

class _VideoDuratonState extends State<VideoDuraton> {
  late Timer timer;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.widget._controller.value.position.toMinutesSeconds(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            )),
        Text(widget.widget._controller.value.duration.toMinutesSeconds(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            )),
      ],
    );
  }
}

extension DurationExtensions on Duration {
  /// Converts the duration into a readable string
  /// 05:15
  String toHoursMinutes() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    return "${_toTwoDigits(inHours)}:$twoDigitMinutes";
  }

  /// Converts the duration into a readable string
  /// 05:15:35
  String toHoursMinutesSeconds() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = _toTwoDigits(inSeconds.remainder(60));
    return "${_toTwoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String toMinutesSeconds() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = _toTwoDigits(inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String _toTwoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }
}
