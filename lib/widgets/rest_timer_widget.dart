import 'dart:async';
import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class RestTimerWidget extends StatefulWidget {
  const RestTimerWidget({super.key});

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  final ThemeService _theme = ThemeService();
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isRunning = false;

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = seconds;
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _theme.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF1F2F42))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer_rounded, color: _theme.secondaryColor, size: 22),
                  const SizedBox(width: 8),
                  const Text('Pihenőidő Időzítő', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              if (_isRunning)
                Text('${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(color: _theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _timerButton('45s', () => _startTimer(45)),
              _timerButton('60s', () => _startTimer(60)),
              _timerButton('90s', () => _startTimer(90)),
              _timerButton('120s', () => _startTimer(120)),
              if (_isRunning)
                IconButton(icon: const Icon(Icons.stop_rounded, color: Colors.redAccent), onPressed: _stopTimer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timerButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: _theme.backgroundColor, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
