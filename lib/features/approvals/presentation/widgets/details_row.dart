import 'package:flutter/material.dart';
import 'package:shop_approval_app/core/app_styles.dart';

class DetailsRow extends StatelessWidget {
  const DetailsRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppStyles.fieldLabel),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppStyles.fieldValue,
            ),
          ),
        ],
      ),
    );
  }
}
