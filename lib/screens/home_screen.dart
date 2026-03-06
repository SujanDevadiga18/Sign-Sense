import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../services/sign_sense_provider.dart';
import '../widgets/action_button.dart';
import '../widgets/sign_display_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignSenseProvider>();
    final lastPrediction = provider.lastPrediction;

    final translatedText = lastPrediction?.character.isNotEmpty == true
        ? 'Detected sign: ${lastPrediction!.character}'
        : (provider.currentText.isNotEmpty
            ? provider.currentText
            : 'Your translations will appear here');

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${provider.username} 👋'),
        actions: [
          IconButton(
            icon: Icon(
              provider.themeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () => context.read<SignSenseProvider>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SignSense AI Dashboard',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              SignDisplayCard(
                title: 'Live translation',
                subtitle: translatedText,
                primaryLabel: 'Speak',
                secondaryLabel: 'Save',
                signContent: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.accessibility_new_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                onPrimaryPressed: () {},
                onSecondaryPressed: () {},
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ActionButton(
                    icon: Icons.keyboard_rounded,
                    label: 'Text Input',
                    onTap: () => Navigator.of(context).pushNamed('/text-translate'),
                  ),
                  const SizedBox(height: 12),
                  ActionButton(
                    icon: Icons.mic_rounded,
                    label: 'Voice Input',
                    onTap: () => Navigator.of(context).pushNamed('/voice-input'),
                  ),
                  const SizedBox(height: 12),
                  ActionButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera Detect',
                    onTap: () => Navigator.of(context).pushNamed('/camera-sign'),
                  ),
                  const SizedBox(height: 12),
                  ActionButton(
                    icon: Icons.chat_bubble_rounded,
                    label: 'History',
                    onTap: () => Navigator.of(context).pushNamed('/history'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/emergency'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  shadowColor: Colors.red.withOpacity(0.5),
                ),
                icon: const Icon(Icons.warning_amber_rounded, size: 26),
                label: const Text(
                  'Emergency Assistance (SOS)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/profile'),
                icon: Icon(Icons.insights_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                label: Text(
                  'View Profile & Insights',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

