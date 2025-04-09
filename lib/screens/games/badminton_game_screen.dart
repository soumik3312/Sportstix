import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class BadmintonGameScreen extends StatefulWidget {
  const BadmintonGameScreen({Key? key}) : super(key: key);

  @override
  State<BadmintonGameScreen> createState() => _BadmintonGameScreenState();
}

class _BadmintonGameScreenState extends State<BadmintonGameScreen> with TickerProviderStateMixin {
  // Game state variables
  int _score = 0;
  int _highScore = 0;
  bool _isPlaying = false;
  bool _isGameOver = false;
  
  // Random generator
  final Random _random = Random();
  
  // Animation controllers
  late AnimationController _shuttleController;
  late Animation<double> _shuttleAnimation;
  
  late AnimationController _playerController;
  late Animation<double> _playerAnimation;
  
  // Game parameters
  double _playerPosition = 0.5; // 0.0 to 1.0
  double _shuttleTargetPosition = 0.5; // 0.0 to 1.0
  double _difficultyFactor = 0.15; // How close player needs to be to hit
  int _rallySpeed = 1000; // milliseconds
  
  // Power-ups
  bool _hasPowerUp = false;
  int _powerUpCountdown = 0;
  Timer? _powerUpTimer;
  
  // Game timer to prevent potential freezing
  Timer? _gameTimer;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize shuttle animation controller
    _shuttleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _rallySpeed),
    );
    
    _shuttleAnimation = CurvedAnimation(
      parent: _shuttleController,
      curve: Curves.easeInOut,
    );
    
    _shuttleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkShuttleHit();
      }
    });
    
    // Initialize player animation controller
    _playerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _playerAnimation = CurvedAnimation(
      parent: _playerController,
      curve: Curves.easeOut,
    );
  }

  void _checkShuttleHit() {
    // Check if player hit the shuttle
    if ((_playerPosition - _shuttleTargetPosition).abs() <= _difficultyFactor) {
      // Hit successful
      setState(() {
        _score++;
        
        // Increase difficulty progressively
        _increaseDifficulty();
        
        // Set new target position
        _shuttleTargetPosition = _random.nextDouble();
      });
      
      // Continue rally
      _shuttleController.reverse(from: 1.0);
      
      // Chance for power-up
      _checkPowerUpSpawn();
    } else {
      // Miss
      _endGame();
    }
  }

  void _increaseDifficulty() {
    // Adjust difficulty factors
    if (_score > 10 && _difficultyFactor > 0.05) {
      _difficultyFactor -= 0.01;
    }
    
    // Speed up rally
    if (_score > 5 && _rallySpeed > 500) {
      _rallySpeed -= 50;
      _shuttleController.duration = Duration(milliseconds: _rallySpeed);
    }
  }

  void _checkPowerUpSpawn() {
    // 10% chance of spawning a power-up
    if (_random.nextDouble() < 0.1 && !_hasPowerUp) {
      setState(() {
        _hasPowerUp = true;
        _powerUpCountdown = 5; // 5 seconds to collect
      });
      
      _startPowerUpTimer();
    }
  }

  void _startPowerUpTimer() {
    _powerUpTimer?.cancel();
    _powerUpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _powerUpCountdown--;
        
        if (_powerUpCountdown <= 0) {
          _hasPowerUp = false;
          timer.cancel();
        }
      });
    });
  }

  void _collectPowerUp() {
    if (_hasPowerUp) {
      setState(() {
        // Reduce difficulty or add bonus points
        _difficultyFactor += 0.05;
        _score += 5;
        _hasPowerUp = false;
      });
      _powerUpTimer?.cancel();
    }
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _isPlaying = true;
      _isGameOver = false;
      _difficultyFactor = 0.15;
      _rallySpeed = 1000;
      _shuttleController.duration = Duration(milliseconds: _rallySpeed);
      _shuttleTargetPosition = 0.5;
      _playerPosition = 0.5;
      _hasPowerUp = false;
    });
    
    // Update high score if needed
    _highScore = max(_highScore, _score);
    
    // Start the first shuttle with a timeout to prevent freezing
    _gameTimer?.cancel();
    _gameTimer = Timer(const Duration(seconds: 10), () {
      if (_isPlaying) {
        _endGame(); // Force end if game runs too long
      }
    });
    
    _shuttleController.forward(from: 0.0);
  }

  void _movePlayer(double position) {
    setState(() {
      _playerPosition = position.clamp(0.0, 1.0);
    });
    
    _playerController.forward(from: 0.0);
  }

  void _endGame() {
    // Cancel any running timers
    _shuttleController.stop();
    _gameTimer?.cancel();
    _powerUpTimer?.cancel();

    setState(() {
      _isPlaying = false;
      _isGameOver = true;
      _highScore = max(_highScore, _score);
    });
    
    // Show game over dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      _showGameOverDialog();
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Score: $_score',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'High Score: $_highScore',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _score < 5
                  ? 'Keep practicing!'
                  : _score < 15
                      ? 'Good job!'
                      : 'Amazing rally!',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'You earned:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '+${_score * 10} points',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of all controllers and timers
    _shuttleController.dispose();
    _playerController.dispose();
    _gameTimer?.cancel();
    _powerUpTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badminton Rally'),
      ),
      body: Column(
        children: [
          // Game info section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn('Score', '$_score'),
                _buildInfoColumn('High Score', '$_highScore'),
                _buildInfoColumn('Difficulty', '${(10 - (_difficultyFactor * 100)).toStringAsFixed(0)}%'),
              ],
            ),
          ),
          
          // Game area
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: _isPlaying
                  ? (details) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final newPosition = (_playerPosition * screenWidth + details.delta.dx) / screenWidth;
                      _movePlayer(newPosition);
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    // Court background
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green[300]!),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Net
                    Positioned(
                      left: 0,
                      right: 0,
                      top: MediaQuery.of(context).size.height / 2 - 100,
                      height: 4,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                    
                    // Shuttle
                    if (_isPlaying || _isGameOver)
                      AnimatedBuilder(
                        animation: _shuttleAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: MediaQuery.of(context).size.width * (_shuttleTargetPosition * 0.8 + 0.1),
                            top: MediaQuery.of(context).size.height / 2 - 100 - 
                                 (MediaQuery.of(context).size.height / 2 - 140) * 
                                 (1 - _shuttleAnimation.value),
                            child: Icon(
                              Icons.sports_tennis,
                              size: 24,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    
                    // Power-up
                    if (_hasPowerUp)
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.5 - 25,
                        top: MediaQuery.of(context).size.height / 2 - 150,
                        child: GestureDetector(
                          onTap: _collectPowerUp,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 7,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$_powerUpCountdown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Player
                    if (_isPlaying || _isGameOver)
                      AnimatedBuilder(
                        animation: _playerAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: MediaQuery.of(context).size.width * (_playerPosition * 0.8 + 0.1) - 20,
                            bottom: 20,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    
                    // Game over or start message
                    if (!_isPlaying)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isGameOver ? 'Game Over!' : 'Tap Start to play!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_isGameOver)
                              Text(
                                'Score: $_score',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 24),
                            if (!_isGameOver)
                              ElevatedButton(
                                onPressed: _startGame,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                ),
                                child: const Text(
                                  'Start Game',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                          ],
                        ),
                      ),
                    
                    // Instructions
                    if (_isPlaying)
                      Positioned(
                        bottom: 80,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            'Drag left and right to move',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}