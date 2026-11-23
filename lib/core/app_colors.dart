import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Teal Shades
  static const Color primaryTeal = Color(0xFF0F5156);
  static const Color primaryTealDark = Color(0xFF0A3C40);
  static const Color primaryTealLight = Color(0xFFE8F3F4);
  static const Color primaryTealSubtle = Color(0xFFF0F7F7);

  // Backgrounds & Surface
  static const Color scaffoldBackground = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE4E7EC);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Status: Pending (قيد المراجعة)
  static const Color pendingBg = Color(0xFFEFF6FF);
  static const Color pendingText = Color(0xFF1D4ED8);
  static const Color pendingDot = Color(0xFF2563EB);

  // Status: Needs Attention / Limit Exceeded (يحتاج انتباه)
  static const Color warningBg = Color(0xFFFEF2F2);
  static const Color warningText = Color(0xFFDC2626);
  static const Color warningBorder = Color(0xFFFCA5A5);
  static const Color warningBorderStrong = Color(0xFFDC2626);

  // Status: Approved (تمت الموافقة)
  static const Color approvedBg = Color(0xFFECFDF5);
  static const Color approvedText = Color(0xFF047857);
  static const Color approvedBorder = Color(0xFFA7F3D0);
  static const Color approvedIcon = Color(0xFF059669);

  // Status: Rejected (مرفوض)
  static const Color rejectedBg = Color(0xFFFEF2F2);
  static const Color rejectedText = Color(0xFFDC2626);
  static const Color rejectedBorder = Color(0xFFFCA5A5);
  static const Color rejectButtonBg = Color(0xFFB91C1C);

  // Status: Syncing / Offline / Alert
  static const Color syncWarningBg = Color(0xFFFFF7ED);
  static const Color syncWarningBorder = Color(0xFFFED7AA);
  static const Color syncWarningText = Color(0xFFC2410C);

  static const Color updatedNoticeBg = Color(0xFFEFF6FF);
  static const Color updatedNoticeBorder = Color(0xFFBFDBFE);
  static const Color updatedNoticeText = Color(0xFF1E40AF);

  static const Color offlineDarkBanner = Color(0xFF1E293B);
  static const Color offlineGreyBox = Color(0xFFF1F5F9);
  static const Color offlineGreyBorder = Color(0xFFCBD5E1);

  // Actions
  static const Color buttonDisabled = Color(0xFF8B9CA7);
  static const Color modalOverlay = Color(0x66000000);
}
