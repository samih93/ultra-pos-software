import 'dart:async';

import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';

class DefaultTimeWidget extends StatefulWidget {
  const DefaultTimeWidget({super.key});

  @override
  State<DefaultTimeWidget> createState() => _DefaultTimeWidgetState();
}

class _DefaultTimeWidgetState extends State<DefaultTimeWidget> {
  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();

    // Start the timer to update the current time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Update the current time
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  // Variable to store the current time
  late DateTime _currentTime;

  // Timer to update the current time every second
  late Timer _timer;

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        '${_currentTime.mMMddyyyyFormat()}  ${_currentTime.toAmPmWithSecondsFormat()}';
    return Padding(
      padding: kPadd8,
      child: DefaultTextView(
        text: formattedTime,
        color: Colors.white,
        fontSize: 25,
      ),
    );
  }
}
