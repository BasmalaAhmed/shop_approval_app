import 'package:flutter/material.dart';
import 'package:shop_approval_app/app/shop_approval_app.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_service.dart';

// لتجربة تعديل الطلب و هو مفتوح flutter run --dart-define=EXTERNAL_CHANGE=true
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final connectivity = ConnectivityPlusService();
  await connectivity.init();
  runApp(ShopApprovalApp(connectivity: connectivity));
}
