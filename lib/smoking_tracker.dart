import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmokingTracker extends StatefulWidget {
  const SmokingTracker({super.key});

  @override
  State<SmokingTracker> createState() => _SmokingTrackerState();
}

class _SmokingTrackerState extends State<SmokingTracker> {
  final TextEditingController _controller = TextEditingController();
  int _count = 0;
  static const String _countKey = 'daily_smoke_count';

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _count = prefs.getInt(_countKey) ?? 0;
      _controller.text = _count.toString();
    });
  }

  Future<void> _saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, _count);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Count saved: $_count')),
    );
  }

  void _updateCount(int newCount) {
    setState(() {
      _count = newCount;
      _controller.text = _count.toString();
    });
    _saveCount(); // Auto-save when count changes
  }

  void _incrementCount() {
    _updateCount(_count + 1);
  }

  void _decrementCount() {
    if (_count > 0) {
      _updateCount(_count - 1);
    }
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
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCount, // Manual save button
              child: const Text('Save Count'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
