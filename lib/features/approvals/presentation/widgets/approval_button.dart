import 'package:flutter/material.dart';

class ApprovalButton extends StatelessWidget {
  const ApprovalButton({
    super.key,
    required this.label,
    this.buttonColor,
    required this.onTap,
  });
  final String label;
  final Color? buttonColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor ?? Color(0XFFB3C0A4),
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      child: Text(label),
    );
  }
}
