import 'dart:async';

import 'package:flutter/material.dart';

/// Displays a looping sequence of sign images for the characters
/// in [text], e.g. "HELLO" -> H, E, L, L, O.
///
/// Images are expected at `assets/<CHAR>.jpeg` and an optional
/// `assets/idle.jpeg` for spaces / empty content.
class SignSequenceView extends StatefulWidget {
  const SignSequenceView({
    super.key,
    required this.text,
    this.frameDuration = const Duration(milliseconds: 800),
  });

  final String text;
  final Duration frameDuration;

  @override
  State<SignSequenceView> createState() => _SignSequenceViewState();
}

class _SignSequenceViewState extends State<SignSequenceView> {
  late List<String> _chars;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _rebuildChars();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant SignSequenceView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _rebuildChars();
      _restartTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _rebuildChars() {
    final cleaned = widget.text
        .toUpperCase()
        .replaceAll(RegExp('[^A-Z0-9 ]'), '')
        .trim();
    if (cleaned.isEmpty) {
      _chars = const [];
    } else {
      _chars = cleaned.split('');
    }
    _index = 0;
  }

  void _startTimer() {
    _timer ??= Timer.periodic(widget.frameDuration, (_) {
      if (!mounted || _chars.isEmpty) return;
      setState(() {
        _index = (_index + 1) % _chars.length;
      });
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = null;
    if (_chars.isNotEmpty) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_chars.isEmpty) {
      // Fallback placeholder when there is no text.
      return Container(
        color: Colors.transparent,
        child: const Center(
          child: Icon(
            Icons.accessibility_new_rounded,
            size: 72,
            color: Colors.white,
          ),
        ),
      );
    }

    final currentChar = _chars[_index];
    final isSpace = currentChar == ' ';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: Image.asset(
        isSpace ? 'assets/idle.jpeg' : 'assets/${currentChar}.jpeg',
        key: ValueKey(isSpace ? 'idle' : currentChar),
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) {
          // Fallback if the specific image is missing.
          return Container(
            color: Colors.black12,
            child: Center(
              child: Text(
                isSpace ? '' : currentChar,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

