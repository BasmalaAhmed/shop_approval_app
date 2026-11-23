import 'package:flutter/material.dart';

class ApprovalDetailRow extends StatelessWidget {
  const ApprovalDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.noteColor,
  });

  final String label, value;
  final Color? noteColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
