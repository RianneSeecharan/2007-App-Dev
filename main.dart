import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

void main() {
  runApp(const TraceNumbersApp());
}

class TraceNumbersApp extends StatelessWidget {
  const TraceNumbersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trace Numbers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NumbersGrid(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write the Numbers'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1,
        ),
        itemCount: 20,
        itemBuilder: (context, index) {
          bool isUnlocked = index <= unlockedNumbers;

          return GestureDetector(
            onTap: () {
              if (isUnlocked) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TraceScreen(
                      number: index,
                      onComplete: () {
                        setState(() {
                          if (index == unlockedNumbers) {
                            unlockedNumbers++;
                          }
                        });
                      },
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

class TraceScreen extends StatefulWidget {
  final int number;
  final VoidCallback onComplete;

  const TraceScreen({super.key, required this.number, required this.onComplete});

  @override
  _TraceScreenState createState() => _TraceScreenState();
}

class _TraceScreenState extends State<TraceScreen> {
  late SignatureController _controller;
  bool isErasing = false;  // Eraser mode

  // List of chalk colors to choose from
  final List<Color> chalkColors = [
    Colors.white,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.pink,
    Colors.purple,
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

  // Function to update the chalk color and reinitialize the controller
  void _updateChalkColor(Color newColor) {
    setState(() {
      selectedChalkColor = newColor;
      isErasing = false;  // Turn off eraser when changing color
      _controller = SignatureController(
        penStrokeWidth: 8,
        penColor: selectedChalkColor,
      );
    });
  }

  // Function to toggle eraser mode
  void _toggleEraser() {
    setState(() {
      isErasing = !isErasing;
      _controller = SignatureController(
        penStrokeWidth: isErasing ? 8:8,  // Make eraser thicker
        penColor: isErasing ? Colors.transparent : selectedChalkColor,  // Eraser is transparent
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
                    'assets/chalkboard.png', // Add chalkboard background
                    fit: BoxFit.cover,
                  ),
                  Text(
                    '${widget.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 150,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ClipPath(
                    clipper: NumberClipper(widget.number), // Custom clipper for the number
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.0,
                          colors: <Color>[selectedChalkColor.withOpacity(0.6), selectedChalkColor],
                          tileMode: TileMode.mirror,
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Signature(
                        controller: _controller,
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
          // Chalk color selection bar
          Container(
            height: 60,
            color: Colors.black12,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chalkColors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _updateChalkColor(chalkColors[index]); // Update the chalk color
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
                            ? Colors.black
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                if (_controller.isNotEmpty) {
                  widget.onComplete();
                  Navigator.pop(context);
                } else {
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
    _controller.dispose();
    super.dispose();
  }
}

// Custom Clipper Class
class NumberClipper extends CustomClipper<Path> {
  final int number;

  NumberClipper(this.number);

  @override
  Path getClip(Size size) {
    Path path = Path();

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    
    // Adjust the radius based on the number range
    double radius;
    if (number >= 0 && number <= 9) {
      radius = 75.0;  // For numbers 0-9
    } else {
      radius = 90.0;  // For numbers 10-19
    }

    path.addOval(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false; // Return true if the clipper should update when the widget rebuilds
  }
}


