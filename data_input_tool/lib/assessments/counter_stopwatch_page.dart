import 'package:flutter/material.dart';
import 'dart:async';

/// A widget representing a page with a counter and a stopwatch.
class CounterStopwatchPage extends StatefulWidget {
  final ValueChanged<int> onCounterChanged; // Add this parameter

  const CounterStopwatchPage({required this.onCounterChanged, super.key});

  @override
  _CounterStopwatchPageState createState() => _CounterStopwatchPageState();
}

class _CounterStopwatchPageState extends State<CounterStopwatchPage> {
  int _counter = 0;
  bool _isRunning = false;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCounterChanged(_counter); // Pass the final counter value back
    });
    super.dispose();
  }

  void _startStopwatch() {
    setState(() {
      _isRunning = true;
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() {});
      });
    });
  }

  void _stopStopwatch() {
    setState(() {
      _isRunning = false;
      _stopwatch.stop();
      _timer?.cancel();
    });
  }

  void _resetStopwatch() {
    setState(() {
      _isRunning = false;
      _stopwatch.reset();
      _timer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final int seconds = _stopwatch.elapsed.inSeconds;
    final int milliseconds = (_stopwatch.elapsed.inMilliseconds % 1000) ~/ 10;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zähler und Stoppuhr'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Counter: $_counter',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _counter++),
                  child: const Text('+ Zähler'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _counter--),
                  child: const Text('- Zähler'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => _showStopwatchDialog(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Stoppuhrenzeit',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$seconds.${milliseconds.toString().padLeft(2, '0')} seconds',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _stopStopwatch : _startStopwatch,
                  child: Text(_isRunning ? 'Stop' : 'Start'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _resetStopwatch,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStopwatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final int seconds = _stopwatch.elapsed.inSeconds;
        final int milliseconds = (_stopwatch.elapsed.inMilliseconds % 1000) ~/ 10;

        return AlertDialog(
          title: const Text('Stoppuhr'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$seconds.${milliseconds.toString().padLeft(2, '0')} seconds',
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
