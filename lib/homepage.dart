import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SnakeGameHomePage(),
    );
  }
}

class SnakeGameHomePage extends StatefulWidget {
  const SnakeGameHomePage({super.key});

  @override
  _SnakeGameHomePageState createState() => _SnakeGameHomePageState();
}

class _SnakeGameHomePageState extends State<SnakeGameHomePage> {
  static const int _rows = 20;
  static const int _columns = 20;
  static const int _initialSnakeLength = 5;
  static const Duration _gameSpeed = Duration(milliseconds: 300);

  List<int> _snake = [];
  int _food = 0;
  String _direction = 'up';
  bool _isPlaying = false;
  Timer? _timer;
  int _score = 0;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    setState(() {
      _snake = List.generate(
          _initialSnakeLength, (index) => _columns * (_rows - 2) + index);
      _generateFood();
      _direction = 'up';
      _isPlaying = true;
      _score = 0;
      _level = 1;
    });

    _timer = Timer.periodic(_gameSpeed, (timer) {
      if (_isPlaying) {
        _moveSnake();
      }
    });
  }

  void _generateFood() {
    Random random = Random();
    _food = random.nextInt(_rows * _columns);

    // Ensure food is not generated on the snake
    while (_snake.contains(_food)) {
      _food = random.nextInt(_rows * _columns);
    }
  }

  void _moveSnake() {
    setState(() {
      int newHead;
      switch (_direction) {
        case 'up':
          newHead = _snake.first - _columns;
          break;
        case 'down':
          newHead = _snake.first + _columns;
          break;
        case 'left':
          newHead = (_snake.first % _columns == 0)
              ? _snake.first + (_columns - 1)
              : _snake.first - 1;
          break;
        case 'right':
          newHead = (_snake.first % _columns == (_columns - 1))
              ? _snake.first - (_columns - 1)
              : _snake.first + 1;
          break;
        default:
          return;
      }

      // Game over if snake runs into itself or the boundary
      if (_snake.contains(newHead) ||
          newHead < 0 ||
          newHead >= _rows * _columns) {
        _gameOver();
        return;
      }

      _snake.insert(0, newHead);

      // Check if the snake eats the food
      if (_snake.first == _food) {
        _generateFood();
        _score += 10;

        // Level up every 100 points
        if (_score % 100 == 0) {
          _level++;
        }
      } else {
        _snake.removeLast();
      }
    });
  }

  void _gameOver() {
    setState(() {
      _isPlaying = false;
    });
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Game Over"),
          content: const Text("You have lost. Try again?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              child: const Text("Restart"),
            ),
          ],
        );
      },
    );
  }

  void _changeDirection(String newDirection) {
    if ((newDirection == 'up' && _direction != 'down') ||
        (newDirection == 'down' && _direction != 'up') ||
        (newDirection == 'left' && _direction != 'right') ||
        (newDirection == 'right' && _direction != 'left')) {
      setState(() {
        _direction = newDirection;
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game'),
      ),
      body: Column(
        children: [
          // Score and Level board at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $_score', style: const TextStyle(fontSize: 18)),
                Text('Level: $_level', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy < 0) {
                  _changeDirection('up');
                } else if (details.delta.dy > 0) {
                  _changeDirection('down');
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx < 0) {
                  _changeDirection('left');
                } else if (details.delta.dx > 0) {
                  _changeDirection('right');
                }
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _columns,
                ),
                itemCount: _rows * _columns,
                itemBuilder: (BuildContext context, int index) {
                  if (_snake.contains(index)) {
                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  } else if (index == _food) {
                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          // Directional buttons and play/pause in the middle
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Up button
                    IconButton(
                      onPressed: () => _changeDirection('up'),
                      icon: const Icon(Icons.arrow_upward),
                      iconSize: 40,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Left button
                    IconButton(
                      onPressed: () => _changeDirection('left'),
                      icon: const Icon(Icons.arrow_back),
                      iconSize: 40,
                    ),
                    // Play/Pause button in the center
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      iconSize: 50,
                    ),
                    // Right button
                    IconButton(
                      onPressed: () => _changeDirection('right'),
                      icon: const Icon(Icons.arrow_forward),
                      iconSize: 40,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Down button
                    IconButton(
                      onPressed: () => _changeDirection('down'),
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 40,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Add footer: Developed by Chipcode
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Developed by Chipcode',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
