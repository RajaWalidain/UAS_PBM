import 'dart:async';
import 'package:flutter/material.dart';
import 'notification_service.dart';

class KegiatanPage extends StatefulWidget {
  const KegiatanPage({super.key});

  @override
  State<KegiatanPage> createState() => _KegiatanPageState();
}

class _KegiatanPageState extends State<KegiatanPage> {
  int _selectedTechnique = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  final List<Map<String, dynamic>> _techniques = [
    {'label': 'Pomodoro (25/5)', 'duration': 25},
    {'label': 'Fokus 50/10', 'duration': 50},
    {'label': 'Custom (60)', 'duration': 60},
  ];

  void _startTimer() {
    if (_isRunning) return;

    final duration = _techniques[_selectedTechnique]['duration'] * 60;
    setState(() {
      _remainingSeconds = duration;
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds == 0) {
        _stopTimer();

        // ⏰ Notifikasi selesai belajar
        await NotificationService.scheduleNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Belajar Selesai!',
          body: 'Waktunya istirahat sejenak 🎉',
          scheduledTime: DateTime.now().add(const Duration(seconds: 1)),
        );
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer Belajar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<int>(
              value: _selectedTechnique,
              items: List.generate(_techniques.length, (index) {
                return DropdownMenuItem(
                  value: index,
                  child: Text(_techniques[index]['label']),
                );
              }),
              onChanged: !_isRunning
                  ? (value) {
                      setState(() {
                        _selectedTechnique = value!;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 30),
            Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: _startTimer,
                  label: const Text('Mulai'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  onPressed: _stopTimer,
                  label: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
