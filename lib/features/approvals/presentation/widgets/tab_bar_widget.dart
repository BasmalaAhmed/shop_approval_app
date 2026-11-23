import 'package:flutter/material.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/tab_bar_item.dart';

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.pendingCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: TabBarItem(
              title: 'قيد المراجعة',
              isSelected: selectedIndex == 0,
              badgeCount: pendingCount,
              onTap: () => onTabSelected(0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TabBarItem(
              title: 'منتهي',
              isSelected: selectedIndex == 1,
              onTap: () => onTabSelected(1),
            ),
          ),
        ],
      ),
    );
  }
}
