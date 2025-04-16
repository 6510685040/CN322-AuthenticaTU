import 'dart:async';
import 'package:flutter/material.dart';

class TOTPCountdownBar extends StatefulWidget {
  @override
  _TOTPCountdownBarState createState() => _TOTPCountdownBarState();
}

class _TOTPCountdownBarState extends State<TOTPCountdownBar> {
  Timer? _timer;
  double _progress = 1.0; // Full bar (1.0 = 100%)
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsRemaining--;
          _progress = _secondsRemaining / 30; // Update progress (1 to 0)
          if (_secondsRemaining == 0) {
            _secondsRemaining = 30; // Reset countdown
            _progress = 1.0; // Reset progress bar
          }
        });
      }
    });
  }

  void _updateTime() {
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _secondsRemaining = 30 - (currentTime % 30);
    _progress = _secondsRemaining / 30; // Set initial progress
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop timer when widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: _progress,
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      minHeight: 6,
    );
  }
}
