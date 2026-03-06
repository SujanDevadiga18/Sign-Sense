import 'dart:io';

import 'package:flutter/material.dart';

import '../models/conversation_entry.dart';
import '../models/sign_prediction.dart';
import 'api_service.dart';

class SignSenseProvider extends ChangeNotifier {
  SignSenseProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  String _username = 'Guest User';
  String get username => _username;
  
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void setUsername(String name) {
    _username = name;
    notifyListeners();
  }
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  String _currentText = '';
  String get currentText => _currentText;

  SignPrediction? _lastPrediction;
  SignPrediction? get lastPrediction => _lastPrediction;

  final List<ConversationEntry> _history = [];
  List<ConversationEntry> get history => List.unmodifiable(_history);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setText(String text) {
    _currentText = text;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> addFromText(String text) async {
    if (text.trim().isEmpty) return;
    _currentText = text.trim();
    _history.insert(
      0,
      ConversationEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceText: _currentText,
        fromVoice: false,
        fromCamera: false,
      ),
    );
    notifyListeners();
  }

  Future<void> addFromVoice(String text) async {
    if (text.trim().isEmpty) return;
    _currentText = text.trim();
    _history.insert(
      0,
      ConversationEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceText: _currentText,
        fromVoice: true,
        fromCamera: false,
      ),
    );
    notifyListeners();
  }

  Future<void> detectFromImage(File imageFile) async {
    _setLoading(true);
    try {
      final prediction = await _apiService.predictSign(imageFile);
      _lastPrediction = prediction;
      _errorMessage = null;

      _history.insert(
        0,
        ConversationEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sourceText: prediction.character,
          detectedSign: prediction.character,
          fromCamera: true,
        ),
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

