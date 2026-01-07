import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorScreen extends ConsumerWidget {
  const ErrorScreen({this.retry, this.errorText, super.key});

  final VoidCallback? retry;
  final String? errorText;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            DefaultTextView(
              text: errorText ?? 'Error in fetching data',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            const DefaultTextView(
              text: 'try again',
              textAlign: TextAlign.center,
              fontSize: 16,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: retry, child: const Text('retry')),
          ],
        ),
      ),
    );
  }
}
