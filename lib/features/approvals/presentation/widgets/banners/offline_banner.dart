import 'package:flutter/material.dart';
import 'package:shop_approval_app/core/app_styles.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0XFF1A1D21),
        
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_outlined, color: Colors.white, size: 16,),
          const SizedBox(width: 8,), 
          Text('لا يوجد اتصال · آخر تحديث 12:30 م' , style: AppStyles.badgeText.copyWith(
            color: Colors.white
          ),)
        ],
      ),
    );
  }
}