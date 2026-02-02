import 'package:flutter/material.dart';
import '../models/hexagram.dart';
import '../widgets/yin_yang_switch.dart';
import '../data/hexagram_data.dart';
import 'result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Index 0 is Bottom Line, Index 5 is Top Line.
  // Default to all Yang (Qian)
  List<bool> lines = List.filled(6, true);

  void _toggleLine(int index) {
    setState(() {
      lines[index] = !lines[index];
    });
  }

  void _analyze() {
    // Convert boolean list to binary string '1' or '0'
    // lines[0] is the first char in our key convention?
    // In hexagram_data.dart: "Binary key is from Bottom (index 0) to Top (index 5)"
    // String construction:
    // We want "101010". 
    // If lines[0] is '1', lines[1] is '0'.
    // The string should likely be index 0 + index 1 + ... + index 5
    // Yes, verified in data file logic.
    
    String binary = lines.map((e) => e ? '1' : '0').join('');
    
    Hexagram result = getHexagram(binary);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(hexagram: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('金钱卦 (Money Gua)'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '请自下而上拨动爻象',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 32),
              // We render from Top (Index 5) to Bottom (Index 0)
              ...List.generate(6, (index) {
                int lineIndex = 5 - index; // 5, 4, 3, 2, 1, 0
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: YinYangSwitch(
                    isYang: lines[lineIndex],
                    onToggle: () => _toggleLine(lineIndex),
                    activeColor: const Color(0xFFFFD700),
                    inactiveColor: const Color(0xFF424242),
                  ),
                );
              }),
              const SizedBox(height: 48),
              SizedBox(
                width: 200,
                height: 56,
                child: ElevatedButton(
                  onPressed: _analyze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8D8B9), // Pale Green
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                  ),
                  child: const Text(
                    '解读卦象',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
