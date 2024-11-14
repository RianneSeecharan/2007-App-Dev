import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:signature/signature.dart';

// Main entry point for the app
void main() {
  runApp(const TraceNumbersApp());
}

// Root widget of the application
class TraceNumbersApp extends StatelessWidget {
  const TraceNumbersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trace Numbers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NumbersGrid(), // Sets initial screen to the grid of numbers
    );
  }
}

// Widget to display a grid of numbers for tracing
class NumbersGrid extends StatefulWidget {
  const NumbersGrid({super.key});

  @override
  NumbersGridState createState() => NumbersGridState();
}

// State class for NumbersGrid, manages unlocked numbers and speech functionality
class NumbersGridState extends State<NumbersGrid> {
  int unlockedNumbers = 1; // Tracks the highest unlocked number
  FlutterTts flutterTts = FlutterTts(); // Text-to-speech object

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US"); // Sets TTS language to US English
    flutterTts.setPitch(1.0); // Sets TTS pitch
  }

  // Speaks the number selected by the user
  Future<void> speakNumber(int number) async {
    await flutterTts.speak(" $number");
  }

  // Speaks a message when the tracing is complete
  Future<void> speakCompletion(int number) async {
    await flutterTts.speak("$number completed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write the Numbers'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 5 columns in grid
          childAspectRatio: 1, // Equal width and height for grid items
        ),
        itemCount: 20, // Total items in the grid (0-19)
        itemBuilder: (context, index) {
          bool isUnlocked = index <= unlockedNumbers; // Check if number is unlocked

          return GestureDetector(
            onTap: () async {
              if (isUnlocked) { // If the number is unlocked
                await speakNumber(index); // Speak the number
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TraceScreen(
                      number: index,
                      onComplete: () {
                        setState(() {
                          if (index == unlockedNumbers) {
                            unlockedNumbers++; // Unlock the next number
                          }
                        });
                      },
                      onCompletedSpeak: () => speakCompletion(index), // Speak completion message
                    ),
                  ),
                );
              }
            },
            child: Card(
              color: isUnlocked ? Colors.blue : Colors.grey, // Color based on unlock status
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

// Screen where the user can trace a specific number
class TraceScreen extends StatefulWidget {
  final int number; // The number being traced
  final VoidCallback onComplete; // Callback to update unlocked numbers
  final VoidCallback onCompletedSpeak; // Callback to speak completion message

  const TraceScreen({
    super.key,
    required this.number,
    required this.onComplete,
    required this.onCompletedSpeak,
  });

  @override
  _TraceScreenState createState() => _TraceScreenState();
}

// State class for TraceScreen, manages tracing and eraser functionality
class _TraceScreenState extends State<TraceScreen> {
  late SignatureController _controller; // Controller for drawing
  bool isErasing = false; // Tracks if the eraser is active

  // List of pastel colors for drawing
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

  Color selectedChalkColor = Colors.blue; // Default chalk color

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 8,
      penColor: selectedChalkColor,
    );
  }

  // Updates the drawing color and disables the eraser
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

  // Toggles eraser mode on and off
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
        title: Text('Trace ${widget.number}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/chalkboard.png', // Background image
                    fit: BoxFit.cover,
                  ),
                  Text(
                    '${widget.number}', // Display the number to trace
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 150,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Area where the user can trace the number
                  ClipPath(
                    clipper: NumberClipper(widget.number), // Clipping to number shape
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.0,
                          colors: <Color>[
                            selectedChalkColor.withOpacity(0.6),
                            selectedChalkColor,
                          ],
                          tileMode: TileMode.mirror,
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Signature(
                        controller: _controller, // Signature controller for drawing
                        backgroundColor: Colors.transparent,
                        height: 300,
                        width: 300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Row of color options
          Container(
            height: 60,
            color: const Color.fromARGB(172, 0, 0, 0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chalkColors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _updateChalkColor(chalkColors[index]); // Select a color
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
          // Eraser toggle button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _toggleEraser,
              child: Text(isErasing ? 'Switch to Drawing' : 'Switch to Eraser'),
            ),
          ),
          // Complete button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                if (_controller.isNotEmpty) {
                  widget.onComplete(); // Unlock next number
                  widget.onCompletedSpeak(); // Speak "number completed"
                  Navigator.pop(context); // Return to grid
                } else {
                  // Prompt to trace the number if not yet drawn
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please trace the number')),
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
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }
}

// Custom clipper class to shape the drawing area around the number
class NumberClipper extends CustomClipper<Path> {
  final int number;

  NumberClipper(this.number);

  @override
  Path getClip(Size size) {
    Path path = Path();
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    // Radius adjusted based on the number
    double radius = number <= 9 ? 75.0 : 90.0;
    path.addOval(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false; // No need to reclip as shape doesn't change
  }
}

