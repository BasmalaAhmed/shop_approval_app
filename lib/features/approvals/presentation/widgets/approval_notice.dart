import 'package:flutter/material.dart';

class ApprovalNotice extends StatelessWidget {
  const ApprovalNotice({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: colors.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(message, style: TextStyle(color: colors.onErrorContainer)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
