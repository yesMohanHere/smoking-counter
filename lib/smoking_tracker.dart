import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SmokingTracker extends StatefulWidget {
  const SmokingTracker({super.key});

  @override
  State<SmokingTracker> createState() => _SmokingTrackerState();
}

class _SmokingTrackerState extends State<SmokingTracker> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  int _count = 0;
  int _goal = 10;
  static const String _countKey = 'daily_smoke_count';
  static const String _goalKey = 'daily_smoke_goal';
  final List<String> _tips = [
    'Take a walk when craving a cigarette.',
    'Stay hydrated to reduce cravings.',
    'Reach out to a friend for support.',
    'Deep breathing can help manage stress.',
  ];

  @override
  void initState() {
    super.initState();
    _loadCount();
    _loadGoal();
  }

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _count = prefs.getInt(_countKey) ?? 0;
      _controller.text = _count.toString();
    });
  }

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _goal = prefs.getInt(_goalKey) ?? 10;
      _goalController.text = _goal.toString();
    });
  }

  Future<void> _saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, _count);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Count saved: $_count')),
    );
  }

  Future<void> _saveGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_goalKey, _goal);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Goal saved: $_goal')),
    );
  }

  void _updateGoal(int newGoal) {
    setState(() {
      _goal = newGoal;
      _goalController.text = _goal.toString();
    });
    _saveGoal();
  }

  void _updateCount(int newCount) {
    setState(() {
      _count = newCount;
      _controller.text = _count.toString();
    });
    _saveCount(); // Auto-save when count changes
    _checkGoalReached();
  }

  void _incrementCount() {
    _updateCount(_count + 1);
  }

  void _decrementCount() {
    if (_count > 0) {
      _updateCount(_count - 1);
    }
  }

  void _resetCount() {
    _updateCount(0);
  }

  void _checkGoalReached() {
    if (_count >= _goal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Congratulations! Goal of $_goal reached.')),
      );
    }
  }

  String _getRandomTip() {
    final rand = Random();
    return _tips[rand.nextInt(_tips.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smoking Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter cigarette count',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final newCount = int.tryParse(value);
                if (newCount != null) {
                  _updateCount(newCount);
                }
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily goal',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final newGoal = int.tryParse(value);
                if (newGoal != null && newGoal > 0) {
                  _updateGoal(newGoal);
                }
              },
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _goal > 0 ? _count / _goal.clamp(1, double.infinity) : 0,
            ),
            const SizedBox(height: 20),
            Text(
              'Current count: $_count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _decrementCount,
                  child: const Icon(Icons.remove),
                ),
                ElevatedButton(
                  onPressed: _incrementCount,
                  child: const Icon(Icons.add),
                ),
                ElevatedButton(
                  onPressed: _resetCount,
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCount, // Manual save button
              child: const Text('Save Count'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveGoal,
              child: const Text('Save Goal'),
            ),
            const SizedBox(height: 20),
            Text(
              'Tip: ${_getRandomTip()}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _goalController.dispose();
    super.dispose();
  }
}
