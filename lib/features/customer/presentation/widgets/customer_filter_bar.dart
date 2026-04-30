import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/visit_status.dart';
import '../cubit/customer_bloc.dart';
import '../cubit/customer_event.dart';
import '../cubit/customer_state.dart';

class CustomerFilterBar extends StatelessWidget {
  final VisitStatus? selectedStatus;
  final ValueChanged<VisitStatus?> onStatusChanged;

  static const Color _accent = Color(0xFF4C6EF5);

  const CustomerFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = <VisitStatus?>[null, ...VisitStatus.values];

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // ClipRRect handles rounding; individual tabs must NOT use borderRadius
      // combined with non-uniform borders (Flutter restriction)
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            final all =
                state is CustomerLoaded ? state.customers : <dynamic>[];
            int countFor(VisitStatus? s) => s == null
                ? all.length
                : all.where((c) => c.visitStatus == s).length;

            return IntrinsicHeight(
              child: Row(
                children: filters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final status = entry.value;
                  final isSelected = selectedStatus == status;
                  final (label, icon) = switch (status) {
                    null => (AppStrings.filterAll, Icons.list_rounded),
                    VisitStatus.visited => (
                        AppStrings.filterVisited,
                        Icons.check_circle_outline_rounded
                      ),
                    VisitStatus.notAvailable => (
                        AppStrings.filterNotAvailable,
                        Icons.cancel_outlined
                      ),
                    VisitStatus.pending => (
                        AppStrings.filterPending,
                        Icons.schedule_rounded
                      ),
                  };
                  final count = countFor(status);
                  final tabColor =
                      isSelected ? _accent : Colors.grey.shade500;

                  return Expanded(
                    child: _FilterTab(
                      label: label,
                      icon: icon,
                      count: count,
                      isSelected: isSelected,
                      isLast: index == filters.length - 1,
                      tabColor: tabColor,
                      onTap: () {
                        onStatusChanged(status);
                        context
                            .read<CustomerBloc>()
                            .add(FilterCustomers(status));
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Individual Filter Tab ────────────────────────────────────────────────────
class _FilterTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final bool isLast;
  final Color tabColor;
  final VoidCallback onTap;

  static const Color _accent = Color(0xFF4C6EF5);

  const _FilterTab({
    required this.label,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.isLast,
    required this.tabColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            color: isSelected
                ? _accent.withValues(alpha: 0.05)
                : Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 13.sp, color: tabColor),
                    SizedBox(width: 3.w),
                    if (count > 0) _CountBadge(count: count, isSelected: isSelected),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: tabColor,
                  ),
                ),
              ],
            ),
          ),
          // Bottom selected indicator
          if (isSelected)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(height: 2.5, color: _accent),
            ),
          // Right divider (not for last tab)
          if (!isLast)
            Positioned(
              top: 8.h,
              bottom: 8.h,
              right: 0,
              child: Container(width: 1, color: Colors.grey.shade100),
            ),
        ],
      ),
    );
  }
}

// ── Count Badge ──────────────────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  final bool isSelected;

  static const Color _accent = Color(0xFF4C6EF5);

  const _CountBadge({required this.count, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isSelected ? _accent : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }
}
