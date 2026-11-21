// lib/features/word_generator/controllers/word_timer_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/models/word_model.dart';
import '../data/word_repository.dart';

class WordTimerController extends ChangeNotifier {
  final WordRepository _repository;
  
  WordTimerController({WordRepository? repository}) 
      : _repository = repository ?? WordRepository() {
    // Populate with an initial random word immediately upon startup
    generateNextWord();
  }

  Timer? _timer;
  WordModel? _currentWord;
  
  bool _isAutoGenerateActive = false; // Controls if the clock input area is open
  bool _isTimerRunning = false;       // Controls if the clock is running
  
  int _selectedSeconds = 10;          // Interval configured by user
  int _secondsRemaining = 10;         // Ticking down to 0
  
  bool _showCountdownOverlay = false; // Triggers the screen-level 3-2-1 overlay
  int _overlayCountdownValue = 3;

  // UI Read Getters
  WordModel? get currentWord => _currentWord;
  bool get isAutoGenerateActive => _isAutoGenerateActive;
  bool get isTimerRunning => _isTimerRunning;
  int get selectedSeconds => _selectedSeconds;
  int get secondsRemaining => _secondsRemaining;
  bool get showCountdownOverlay => _showCountdownOverlay;
  int get overlayCountdownValue => _overlayCountdownValue;

  /// Manually swaps to a new word immediately. 
  /// Resets active timing streams to prevent collision.
  void generateNextWord() {
    _currentWord = _repository.getRandomWord();
    if (_isTimerRunning) {
      _resetTimer();
    }
    notifyListeners();
  }

  /// Opens or closes the timer config panel above the action bar.
  void toggleAutoGenerateSettings() {
    _isAutoGenerateActive = !_isAutoGenerateActive;
    if (!_isAutoGenerateActive) {
      stopAutoGenerate();
    }
    notifyListeners();
  }

  /// Sets the automatic interval time with safety limits.
  void updateDuration(int seconds) {
    if (seconds < 5) {
      _selectedSeconds = 5; // Minimum threshold
    } else if (seconds > 3600) {
      _selectedSeconds = 3600; // Maximum threshold (1 hour)
    } else {
      _selectedSeconds = seconds;
    }
    _secondsRemaining = _selectedSeconds;
    notifyListeners();
  }

  /// Arm and launch the periodic countdown stream.
  void startAutoGenerate() {
    if (_isTimerRunning) return;
    _isTimerRunning = true;
    _secondsRemaining = _selectedSeconds;
    _showCountdownOverlay = false;
    _startTicker();
    notifyListeners();
  }

  /// Safe reset that closes and resets state without leaks.
  void stopAutoGenerate() {
    _isTimerRunning = false;
    _timer?.cancel();
    _timer = null;
    _showCountdownOverlay = false;
    _secondsRemaining = _selectedSeconds;
    notifyListeners();
  }

  void _resetTimer() {
    _timer?.cancel();
    _secondsRemaining = _selectedSeconds;
    _showCountdownOverlay = false;
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTimerRunning) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining > 1) {
        _secondsRemaining--;
        
        // At 3 seconds or fewer, throw up the transparent 3-2-1 countdown screen overlay
        if (_secondsRemaining <= 3) {
          _showCountdownOverlay = true;
          _overlayCountdownValue = _secondsRemaining;
        } else {
          _showCountdownOverlay = false;
        }
        notifyListeners();
      } else {
        // Time expired: rotate word, tear down the overlay, reset the loop clock
        _secondsRemaining = _selectedSeconds;
        _showCountdownOverlay = false;
        _currentWord = _repository.getRandomWord();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}