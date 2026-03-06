import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../core/constants/app_colors.dart';
import '../services/sign_sense_provider.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/sign_display_card.dart';
import '../widgets/sign_sequence_view.dart';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  static const routeName = '/voice-input';

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  late final stt.SpeechToText _speech;
  final _flutterTts = FlutterTts();
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _toggleListening(SignSenseProvider provider) async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      if (_recognizedText.isNotEmpty) {
        await provider.addFromVoice(_recognizedText);
      }
      return;
    }

    final available = await _speech.initialize();
    if (!available) return;

    setState(() {
      _recognizedText = '';
      _isListening = true;
    });

    _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 8),
    );
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignSenseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Input'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: () => _toggleListening(provider),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.secondaryBlue,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowDark.withOpacity(0.7),
                          offset: const Offset(8, 8),
                          blurRadius: 18,
                        ),
                        const BoxShadow(
                          color: AppColors.shadowLight,
                          offset: Offset(-6, -6),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isListening ? 'Listening...' : 'Tap to start listening',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              NeumorphicCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    _recognizedText.isEmpty
                        ? 'Recognized text will appear here'
                        : _recognizedText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SignDisplayCard(
                  title: 'Sign translation',
                  subtitle: _recognizedText.isEmpty
                      ? 'Your translated sign sequence will appear here'
                      : _recognizedText,
                  signContent: SignSequenceView(
                    text: _recognizedText,
                  ),
                  primaryLabel: 'Speak',
                  secondaryLabel: 'Save',
                  onPrimaryPressed: () => _speak(_recognizedText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

