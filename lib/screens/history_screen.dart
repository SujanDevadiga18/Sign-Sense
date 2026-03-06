import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/sign_sense_provider.dart';
import '../widgets/conversation_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const routeName = '/history';

  @override
  Widget build(BuildContext context) {
    final history = context.watch<SignSenseProvider>().history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: history.isEmpty
              ? Center(
                  child: Text(
                    'Your interactions will appear here.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    return ConversationBubble(entry: entry);
                  },
                ),
        ),
      ),
    );
  }
}

