import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class FootballGameScreen extends StatefulWidget {
  const FootballGameScreen({Key? key}) : super(key: key);

  @override
  State<FootballGameScreen> createState() => _FootballGameScreenState();
}

class _FootballGameScreenState extends State<FootballGameScreen> with SingleTickerProviderStateMixin {
  // Game state variables
  int _score = 0;
  int _attempts = 0;
  int _maxAttempts = 10;
  int _highScore = 0;
  bool _isPlaying = false;
  bool _isAnimating = false;
  String _lastResult = '';
  final Random _random = Random();
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _ballAnimation;
  late Animation<double> _keeperAnimation;
  
  // Game mechanics
  final List<String> _positions = ['Left', 'Center', 'Right'];
  String? _selectedPosition;
  String? _goalkeeperPosition;
  
  // Sound and difficulty variables
  bool _soundEnabled = true;
  int _difficulty = 1; // 1: Easy, 2: Medium, 3: Hard
  
  // Power meter for shot accuracy
  double _powerMeter = 0.5;
  late Timer _powerMeterTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimationController();
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _ballAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      )
    );
    
    _keeperAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeInOut),
      )
    );
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleShotResult();
      }
    });
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _attempts = 0;
      _isPlaying = true;
      _lastResult = 'Choose where to shoot!';
      _selectedPosition = null;
      _goalkeeperPosition = null;
      _powerMeter = 0.5;
    });
    
    // Start power meter animation
    _startPowerMeterTimer();
  }

  void _startPowerMeterTimer() {
    _powerMeterTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _powerMeter += 0.05;
        if (_powerMeter >= 1 || _powerMeter <= 0) {
          _powerMeterTimer.cancel();
        }
      });
    });
  }

  void _shootBall(String position) {
    if (!_isPlaying || _isAnimating || _attempts >= _maxAttempts) return;
    
    _powerMeterTimer.cancel();
    
    setState(() {
      _selectedPosition = position;
      _isAnimating = true;
      _attempts++;
      
      // Adjust goalkeeper probability based on difficulty
      double savedProbability = _getDifficultySavedProbability();
      
      // Randomly determine goalkeeper position
      _goalkeeperPosition = _positions[_random.nextInt(_positions.length)];
    });
    
    // Start animation
    _animationController.forward(from: 0.0);
  }

  double _getDifficultySavedProbability() {
    switch (_difficulty) {
      case 1: // Easy
        return 0.3;
      case 2: // Medium
        return 0.5;
      case 3: // Hard
        return 0.7;
      default:
        return 0.5;
    }
  }

  void _handleShotResult() {
    setState(() {
      _isAnimating = false;
      
      // Check if goal or saved based on position and power meter
      bool isGoal = _selectedPosition != _goalkeeperPosition;
      
      // Adjust goal based on power meter
      if (isGoal) {
        // Power meter accuracy bonus/penalty
        if (_powerMeter < 0.3 || _powerMeter > 0.7) {
          isGoal = false;
        }
      }
      
      if (isGoal) {
        _score++;
        _lastResult = 'GOAL! The goalkeeper went ${_goalkeeperPosition!.toLowerCase()}';
      } else {
        _lastResult = 'SAVED! The goalkeeper guessed ${_goalkeeperPosition!.toLowerCase()}';
      }
      
      // Check if game over
      if (_attempts >= _maxAttempts) {
        _endGame();
      } else {
        // Restart power meter for next shot
        _startPowerMeterTimer();
      }
    });
  }

  void _endGame() {
    // Update high score
    _highScore = max(_highScore, _score);
    
    setState(() {
      _isPlaying = false;
      _lastResult = 'Game Over! Final Score: $_score/$_maxAttempts';
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
        title: const Text('Penalty Shootout Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Final Score: $_score/$_maxAttempts',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Conversion Rate: ${(_score / _maxAttempts * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'High Score: $_highScore',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
              ),
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
                  '+${_score * 20} points',
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
              _showSettingsDialog();
            },
            child: const Text('Settings'),
          ),
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Game Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sound toggle
              SwitchListTile(
                title: const Text('Sound'),
                value: _soundEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                },
              ),
              
              // Difficulty selection
              const SizedBox(height: 16),
              const Text('Difficulty:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 1; i <= 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(['Easy', 'Medium', 'Hard'][i-1]),
                        selected: _difficulty == i,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) _difficulty = i;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penalty Shootout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Game info section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn('Score', '$_score'),
                _buildInfoColumn('Attempts', '$_attempts/$_maxAttempts'),
                _buildInfoColumn('High Score', '$_highScore'),
              ],
            ),
          ),
          
          // Game area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Football goal visualization
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Stack(
                      children: [
                        // Goal posts
                        Positioned(
                          top: 20,
                          left: 20,
                          right: 20,
                          height: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                        
                        // Goal sections
                        Row(
                          children: [
                            for (int i = 0; i < 3; i++)
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        // Goalkeeper
                        if (_goalkeeperPosition != null && _isAnimating)
                          AnimatedBuilder(
                            animation: _keeperAnimation,
                            builder: (context, child) {
                              return Positioned(
                                top: 40,
                                left: _goalkeeperPosition == 'Left'
                                    ? 30
                                    : _goalkeeperPosition == 'Center'
                                        ? MediaQuery.of(context).size.width / 2 - 50
                                        : MediaQuery.of(context).size.width - 110,
                                child: Transform.scale(
                                  scale: 1 + (_keeperAnimation.value * 0.2),
                                  child: Icon(
                                    Icons.sports_soccer,
                                    size: 40,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            },
                          ),
                        
                        // Ball
                        if (_selectedPosition != null && _isAnimating)
                          AnimatedBuilder(
                            animation: _ballAnimation,
                            builder: (context, child) {
                              return Positioned(
                                bottom: 20 + (80 * _ballAnimation.value),
                                left: _selectedPosition == 'Left'
                                    ? 50
                                    : _selectedPosition == 'Center'
                                        ? MediaQuery.of(context).size.width / 2 - 30
                                        : MediaQuery.of(context).size.width - 90,
                                child: Transform.rotate(
                                  angle: _ballAnimation.value * 3.14 * 2,
                                  child: Icon(
                                    Icons.sports_soccer,
                                    size: 30,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            },
                          ),
                        
                        // Power meter
                        if (_isPlaying && !_isAnimating)
                          Positioned(
                            bottom: 10,
                            left: 20,
                            right: 20,
                            child: LinearProgressIndicator(
                              value: _powerMeter,
                              backgroundColor: Colors.grey[300],
                              color: _powerMeter > 0.3 && _powerMeter < 0.7 
                                  ? Colors.green 
                                  : Colors.red,
                            ),
                          ),
                        
                        // Result text
                        if (!_isPlaying && _score == 0)
                          const Center(
                            child: Text(
                              'Tap Start to play!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (!_isAnimating)
                          Center(
                            child: Text(
                              _lastResult,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _lastResult.contains('GOAL')
                                    ? Colors.green
                                    : _lastResult.contains('SAVED')
                                        ? Colors.red
                                        : Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Shot buttons
                  if (_isPlaying && !_isAnimating)
                    Column(
                      children: [
                        const Text(
                          'Choose where to shoot:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (String position in _positions)
                              ElevatedButton(
                                onPressed: () => _shootBall(position),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                child: Text(position),
                              ),
                          ],
                        ),
                      ],
                    )
                  else if (!_isPlaying)
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

  @override
  void dispose() {
    _animationController.dispose();
    _powerMeterTimer.cancel();
    super.dispose();
  }
}