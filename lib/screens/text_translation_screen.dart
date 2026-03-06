import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../services/sign_sense_provider.dart';
import '../widgets/neumorphic_card.dart';
import '../widgets/sign_display_card.dart';
import '../widgets/sign_sequence_view.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  static const routeName = '/text-translate';

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final _controller = TextEditingController();
  final _flutterTts = FlutterTts();

  @override
  void dispose() {
    _controller.dispose();
    _flutterTts.stop();
    super.dispose();
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
        title: const Text('Text Translation'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              NeumorphicCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: TextField(
                  controller: _controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type your message here...',
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    await provider.addFromText(text);
                    if (!mounted) return;
                    FocusScope.of(context).unfocus();
                  },
                  child: const Text('Translate to Sign'),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SignDisplayCard(
                  title: 'Sign translation',
                  subtitle: provider.currentText.isEmpty
                      ? 'Your translated sign sequence will appear here'
                      : provider.currentText,
                  signContent: SignSequenceView(
                    text: provider.currentText,
                  ),
                  primaryLabel: 'Speak',
                  secondaryLabel: 'Save',
                  onPrimaryPressed: () => _speak(provider.currentText),
                  onSecondaryPressed: () {
                    // Future: persist saved translations.
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

