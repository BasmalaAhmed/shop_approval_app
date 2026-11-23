import 'package:flutter/material.dart';
import 'package:shop_approval_app/app/shop_approval_app.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final connectivity = ConnectivityPlusService();
  await connectivity.init();
  runApp(ShopApprovalApp(connectivity: connectivity));
}
