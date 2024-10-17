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
  NumbersGridState createState() => NumbersGridState(); // Removed underscore to make it public
}

class NumbersGridState extends State<NumbersGrid> {
  int unlockedNumbers = 1; // Initially, only 0 is unlocked

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
        itemCount: 20, // You can extend this to 100 numbers
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

class TraceScreen extends StatelessWidget {
  final int number;
  final VoidCallback onComplete;

  const TraceScreen({super.key, required this.number, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final SignatureController controller = SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.blue,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Trace $number'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/chalkboard.png', // Add a chalkboard background
                    fit: BoxFit.cover,
                  ),
                  Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 150,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Signature(
                    controller: controller,
                    backgroundColor: Colors.transparent,
                    height: 300,
                    width: 300,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                if (controller.isNotEmpty) {
                  onComplete();
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
}
