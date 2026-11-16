import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shop_approval_app/features/approvals/presentation/views/approval_requests_page.dart';

void main() {
  runApp(const ShopApprovalApp());
}

class ShopApprovalApp extends StatelessWidget {
  const ShopApprovalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'موافقة صاحب المحل',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ApprovalRequestsPage(),
    );
  }
}
