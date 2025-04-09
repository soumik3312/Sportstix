import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class CricketGameScreen extends StatefulWidget {
  const CricketGameScreen({Key? key}) : super(key: key);

  @override
  State<CricketGameScreen> createState() => _CricketGameScreenState();
}

class _CricketGameScreenState extends State<CricketGameScreen> {
  int _score = 0;
  int _wickets = 0;
  int _ballsLeft = 30; // 5 overs
  bool _isPlaying = false;
  bool _isOut = false;
  String _lastAction = '';
  final Random _random = Random();
  Timer? _gameTimer;
  String _currentBatsman = 'Player 1';
  String _currentBowler = 'Bowler 1';
  int _targetScore = 0;
  bool _isSecondInnings = false;
  int _innings = 1;
  int _totalBalls = 30;

  // Player and bowler attributes
  final Map<String, Map<String, int>> _playerAttributes = {
    'Player 1': {'battingSkill': 70, 'aggression': 50},
    'Player 2': {'battingSkill': 60, 'aggression': 40},
    'Player 3': {'battingSkill': 80, 'aggression': 60},
    'Player 4': {'battingSkill': 50, 'aggression': 30},
    'Player 5': {'battingSkill': 90, 'aggression': 70},
    'Player 6': {'battingSkill': 40, 'aggression': 20},
    'Player 7': {'battingSkill': 75, 'aggression': 55},
    'Player 8': {'battingSkill': 65, 'aggression': 45},
    'Player 9': {'battingSkill': 55, 'aggression': 35},
    'Player 10': {'battingSkill': 85, 'aggression': 65},
    'Player 11': {'battingSkill': 30, 'aggression': 10},
  };

  final Map<String, Map<String, int>> _bowlerAttributes = {
    'Bowler 1': {'bowlingSkill': 70, 'aggression': 50},
    'Bowler 2': {'bowlingSkill': 60, 'aggression': 40},
    'Bowler 3': {'bowlingSkill': 80, 'aggression': 60},
    'Bowler 4': {'bowlingSkill': 50, 'aggression': 30},
    'Bowler 5': {'bowlingSkill': 90, 'aggression': 70},
  };

  List<String> _batsmenOrder = [
    'Player 1', 'Player 2', 'Player 3', 'Player 4', 'Player 5',
    'Player 6', 'Player 7', 'Player 8', 'Player 9', 'Player 10', 'Player 11',
  ];

  List<String> _bowlersOrder = ['Bowler 1', 'Bowler 2', 'Bowler 3', 'Bowler 4', 'Bowler 5'];
  int _batsmanIndex = 0;
  int _bowlerIndex = 0;

  void _startGame() {
    setState(() {
      _score = 0;
      _wickets = 0;
      _ballsLeft = _totalBalls;
      _isPlaying = true;
      _isOut = false;
      _lastAction = 'Game started!';
      _batsmanIndex = 0;
      _bowlerIndex = 0;
      _currentBatsman = _batsmenOrder[_batsmanIndex];
      _currentBowler = _bowlersOrder[_bowlerIndex];
      _innings = 1;
      _isSecondInnings = false;
      _targetScore = 0;
    });
  }

  void _nextBatsman() {
    _batsmanIndex++;
    if (_batsmanIndex < _batsmenOrder.length) {
      _currentBatsman = _batsmenOrder[_batsmanIndex];
    }
  }

  void _nextBowler() {
    _bowlerIndex = (_bowlerIndex + 1) % _bowlersOrder.length;
    _currentBowler = _bowlersOrder[_bowlerIndex];
  }

  void _playShot(String shotType) {
    if (!_isPlaying || _ballsLeft <= 0 || _wickets >= 10) return;

    int runsProbability;
    int outProbability;

    int battingSkill = _playerAttributes[_currentBatsman]!['battingSkill']!;
    int battingAggression = _playerAttributes[_currentBatsman]!['aggression']!;
    int bowlingSkill = _bowlerAttributes[_currentBowler]!['bowlingSkill']!;
    int bowlingAggression = _bowlerAttributes[_currentBowler]!['aggression']!;

    // Adjusted probabilities based on player and bowler attributes
    switch (shotType) {
      case 'Defensive':
        runsProbability = _random.nextInt(3);
        outProbability = _random.nextInt(20 + (bowlingSkill - battingSkill));
        break;
      case 'Drive':
        runsProbability = _random.nextInt(5);
        outProbability = _random.nextInt(10 + (bowlingSkill - battingSkill) ~/ 2);
        break;
      case 'Pull':
        runsProbability = _random.nextInt(7);
        outProbability = _random.nextInt(8 + (bowlingSkill - battingSkill) ~/ 3);
        break;
      case 'Slog':
        runsProbability = _random.nextInt(10);
        if (runsProbability > 6) runsProbability = 6;
        if (runsProbability == 5) runsProbability = 4;
        outProbability = _random.nextInt(5 + (bowlingSkill - battingSkill) ~/ 4);
        break;
      default:
        runsProbability = _random.nextInt(4);
        outProbability = _random.nextInt(15 + (bowlingSkill - battingSkill) ~/ 5);
    }

    setState(() {
      _ballsLeft--;

      if (outProbability == 0) {
        _wickets++;
        _lastAction = '$_currentBatsman OUT! Playing a $shotType shot';
        _isOut = true;
        _nextBatsman();

        if (_wickets < 10) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                _isOut = false;
                _currentBatsman = _batsmenOrder[_batsmanIndex];
              });
            }
          });
        }
      } else {
        _score += runsProbability;
        _lastAction = '$_currentBatsman played a $shotType shot for $runsProbability runs';
        _nextBowler();
      }

      if (_ballsLeft <= 0 || _wickets >= 10) {
        _endInnings();
      }
    });
  }

  void _endInnings() {
    setState(() {
      if (!_isSecondInnings) {
        _targetScore = _score + 1;
        _score = 0;
        _wickets = 0;
        _ballsLeft = _totalBalls;
        _isSecondInnings = true;
        _innings = 2;
        _lastAction = 'Innings 2 started. Target: $_targetScore';
        _batsmanIndex = 0;
        _bowlerIndex = 0;
        _currentBatsman = _batsmenOrder[_batsmanIndex];
        _currentBowler = _bowlersOrder[_bowlerIndex];
      } else {
        _isPlaying = false;
        if (_score > _targetScore - 1) {
          _lastAction = 'Game Over! $_currentBatsman Won! Final Score: $_score/$_wickets';
        } else {
          _lastAction = 'Game Over! $_currentBowler Won! Final Score: $_score/$_wickets. Target: $_targetScore';
        }
        _showGameOverDialog();
      }
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
            Text('Innings: $_innings'),
            Text('Score: $_score/$_wickets'),
            Text('Target: $_targetScore'),
            Text(_score > _targetScore - 1 
                ? 'Batting Team Wins!' 
                : 'Bowling Team Wins!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cricket Game Simulator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Innings: $_innings',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Balls Left: $_ballsLeft',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Score: $_score/$_wickets',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (_targetScore > 0) 
              Text(
                'Target: $_targetScore',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            const SizedBox(height: 20),
            Text(
              _lastAction,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (!_isPlaying)
              ElevatedButton(
                onPressed: _startGame,
                child: const Text('Start Game'),
              ),
            if (_isPlaying)
              Column(
                children: [
                  Text('Current Batsman: $_currentBatsman'),
                  Text('Current Bowler: $_currentBowler'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _playShot('Defensive'),
                        child: const Text('Defensive'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _playShot('Drive'),
                        child: const Text('Drive'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _playShot('Pull'),
                        child: const Text('Pull'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _playShot('Slog'),
                        child: const Text('Slog'),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}