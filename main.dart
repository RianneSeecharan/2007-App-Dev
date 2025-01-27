import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:signature/signature.dart';

void main() {
  runApp(const TraceApp());
}

class TraceApp extends StatelessWidget {
  const TraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trace App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FrontPage(),
    );
  }
}

class FrontPage extends StatelessWidget {
  const FrontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Trace App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NumbersGrid(),
                  ),
                );
              },
              child: const Text('Trace Numbers'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LettersGrid(),
                  ),
                );
              },
              child: const Text('Trace Letters'),
            ),
          ],
        ),
      ),
    );
  }
}

class NumbersGrid extends StatefulWidget {
  const NumbersGrid({super.key});

  @override
  NumbersGridState createState() => NumbersGridState();
}

class NumbersGridState extends State<NumbersGrid> {
  int unlockedNumbers = 1;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0);
  }

  Future<void> speakNumber(int number) async {
    await flutterTts.speak("$number");
  }

  Future<void> speakCompletion(int number) async {
    await flutterTts.speak("$number completed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trace Numbers'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1,
        ),
        itemCount: 21,
        itemBuilder: (context, index) {
          bool isUnlocked = index <= unlockedNumbers;

          return GestureDetector(
            onTap: () async {
              if (isUnlocked) {
                await speakNumber(index);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TraceScreen(
                      text: '$index',
                      onComplete: () {
                        setState(() {
                          if (index == unlockedNumbers) {
                            unlockedNumbers++;
                          }
                        });
                      },
                      onCompletedSpeak: () => speakCompletion(index),
                    ),
                  ),
                );
              }
            },
            child: Card(
              color: isUnlocked ? Colors.blue : Colors.grey,
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LettersGrid extends StatefulWidget {
  const LettersGrid({super.key});

  @override
  LettersGridState createState() => LettersGridState();
}

class LettersGridState extends State<LettersGrid> {
  int unlockedLetters = 0;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    flutterTts.setPitch(1.0);
  }

  Future<void> speakLetter(String letter) async {
    await flutterTts.speak(letter);
  }

  Future<void> speakCompletion(String letter) async {
    await flutterTts.speak("$letter completed");
  }

  @override
  Widget build(BuildContext context) {
    List<String> letters = [];
    for (int i = 0; i < 26; i++) {
      letters.add(String.fromCharCode(65 + i));
      letters.add(String.fromCharCode(97 + i));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trace Letters'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 1,
        ),
        itemCount: letters.length,
        itemBuilder: (context, index) {
          bool isUnlocked = index <= unlockedLetters;
          String letter = letters[index];

          return GestureDetector(
            onTap: () async {
              if (isUnlocked) {
                await speakLetter(letter);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TraceScreen(
                      text: letter,
                      onComplete: () {
                        setState(() {
                          if (index == unlockedLetters) {
                            unlockedLetters++;
                          }
                        });
                      },
                      onCompletedSpeak: () => speakCompletion(letter),
                    ),
                  ),
                );
              }
            },
            child: Card(
              color: isUnlocked ? Colors.blue : Colors.grey,
              child: Center(
                child: Text(
                  letter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TraceScreen extends StatefulWidget {
  final String text;
  final VoidCallback onComplete;
  final VoidCallback onCompletedSpeak;

  const TraceScreen({
    super.key,
    required this.text,
    required this.onComplete,
    required this.onCompletedSpeak,
  });

  @override
  _TraceScreenState createState() => _TraceScreenState();
}

class _TraceScreenState extends State<TraceScreen> {
  late SignatureController _controller;
  bool isErasing = false;

  final List<Color> chalkColors = [
    Colors.pink[100]!,
    Colors.blue[100]!,
    Colors.red[100]!,
    Colors.green[100]!,
    Colors.yellow[100]!,
    Colors.orange[100]!,
    Colors.purple[100]!,
    Colors.cyan[100]!,
  ];

  Color selectedChalkColor = Colors.blue[100]!;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 8,
      penColor: selectedChalkColor,
    );
  }

  void _updateChalkColor(Color newColor) {
    setState(() {
      selectedChalkColor = newColor;
      isErasing = false;
      _controller = SignatureController(
        penStrokeWidth: 8,
        penColor: selectedChalkColor,
      );
    });
  }

  void _toggleEraser() {
    setState(() {
      isErasing = !isErasing;
      _controller = SignatureController(
        penStrokeWidth: 8,
        penColor: isErasing ? Colors.transparent : selectedChalkColor,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trace ${widget.text}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/chalkboard.png',
                    fit: BoxFit.cover,
                  ),
                  Text(
                    widget.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 150,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Signature(
                    controller: _controller,
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 60,
            color: const Color.fromARGB(172, 0, 0, 0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chalkColors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _updateChalkColor(chalkColors[index]);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: chalkColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedChalkColor == chalkColors[index]
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _toggleEraser,
              child: Text(isErasing ? 'Switch to Drawing' : 'Switch to Eraser'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                if (_controller.isNotEmpty) {
                  widget.onComplete();
                  widget.onCompletedSpeak();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please trace the figure')),
                  );
                }
              },
              child: const Text('Complete'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
