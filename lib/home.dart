import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controllerHour = TextEditingController();
  final TextEditingController _controllerMinute = TextEditingController();

  final List<String> _periods = ['AM', 'PM'];
  String _selectedPeriod = 'AM';

  String _resultText = '';

  @override
  void dispose() {
    _controllerHour.dispose();
    _controllerMinute.dispose();
    super.dispose();
  }

  //sleep cycle
  void _calculateBedtimes() {
    try {
      String hourText = _controllerHour.text.trim();
      String minuteText = _controllerMinute.text.trim();

      if (hourText.isEmpty || minuteText.isEmpty) {
        setState(() => _resultText = 'Please fill both hour and minute.');
        return;
      }

      int hour = int.parse(hourText);
      int minute = int.parse(minuteText);

      if (hour < 1 || hour > 12 || minute < 0 || minute > 59) {
        setState(() => _resultText = 'Hour must be 1–12 and minute 0–59.');
        return;
      }

      //convert to 24h
      int h24 = hour;
      if (_selectedPeriod == 'PM' && hour != 12) h24 = hour + 12;
      if (_selectedPeriod == 'AM' && hour == 12) h24 = 0;

      int totalMinutes = h24 * 60 + minute;
      List<int> cycles = [6, 5, 4];
      List<String> results = [];

      for (int cycle in cycles) {
        int bedMinutes = totalMinutes - (cycle * 90);
        while (bedMinutes < 0) bedMinutes += 24 * 60;
        results.add(_formatTime12h(bedMinutes));
      }

      setState(() {
        _resultText =
            'Recommended bedtimes:\n\n'
            '${results[0]} (6 cycles - 9 hrs)\n'
            '${results[1]} (5 cycles - 7.5 hrs)\n'
            '${results[2]} (4 cycles - 6 hrs)';
      });
    } catch (e) {
      setState(() => _resultText = 'Please enter valid numbers.');
    }
  }

  String _formatTime12h(int totalMinutes) {
    int h24 = totalMinutes ~/ 60;
    int m = totalMinutes % 60;

    String period = h24 >= 12 ? 'PM' : 'AM';
    int h12 = h24 % 12;
    if (h12 == 0) h12 = 12;

    return '$h12:${m.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'For a better sleep',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 5, 10, 36),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            //banner at top
            Image.asset(
              'assets/bedtime.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 50),

            Center(
              child: Column(
                children: [
                  const Text(
                    'Enter your desired wake-up time',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  //inputs
                  IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurple, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _controllerHour,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Hour',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _controllerMinute,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Min',
                                hintStyle: TextStyle(color: Colors.white54),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          SizedBox(
                            width: 90,
                            child: DropdownMenu<String>(
                              width: 90,
                              initialSelection: _selectedPeriod,
                              dropdownMenuEntries: _periods
                                  .map(
                                    (p) =>
                                        DropdownMenuEntry(value: p, label: p),
                                  )
                                  .toList(),
                              onSelected: (value) {
                                setState(() => _selectedPeriod = value ?? 'AM');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _calculateBedtimes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 40,
                      ),
                    ),
                    child: const Text(
                      'SUBMIT',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (_resultText.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.25),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        _resultText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          height: 1.5,
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
