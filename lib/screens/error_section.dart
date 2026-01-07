import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';

class ErrorSection extends StatelessWidget {
  const ErrorSection({this.title, this.retry, super.key});

  final VoidCallback? retry;
  final String? title;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 100, color: Colors.red),
          const SizedBox(height: 20),
          const DefaultTextView(
            text: 'Error in fetching data',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 10),
          if (title != null)
            DefaultTextView(
              maxlines: 3,
              text: title!,
              textAlign: TextAlign.center,
              fontSize: 14,
            ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: retry, child: const Text('retry')),
        ],
      ),
    );
  }
}
