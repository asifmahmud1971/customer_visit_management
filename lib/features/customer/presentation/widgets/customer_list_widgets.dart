import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/visit_status.dart';
import '../../domain/entities/customer.dart';
import '../cubit/customer_bloc.dart';
import '../cubit/customer_event.dart';
import '../cubit/customer_state.dart';
import '../screens/customer_detail_screen.dart';

// ── Color helpers (shared across card widgets) ───────────────────────────────
Color visitStatusColor(VisitStatus status) {
  switch (status) {
    case VisitStatus.visited:
      return const Color(0xFF4C6EF5);
    case VisitStatus.notAvailable:
      return const Color(0xFFFA5252);
    case VisitStatus.pending:
      return const Color(0xFFFFAB00);
  }
}

// ── Customer List Sliver ─────────────────────────────────────────────────────
class CustomerListSliver extends StatelessWidget {
  const CustomerListSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) return const _LoadingSliver();
        if (state is CustomerError) return _ErrorSliver(message: state.message);
        if (state is CustomerLoaded) {
          final customers = state.filteredCustomers;
          if (customers.isEmpty) return const _EmptySliver();
          return _CustomerListView(customers: customers);
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

// ── Loading State ────────────────────────────────────────────────────────────
class _LoadingSliver extends StatelessWidget {
  static const Color _accent = Color(0xFF4C6EF5);
  const _LoadingSliver();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40.w,
              height: 40.w,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(_accent),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              AppStrings.loadingCustomers,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error State ──────────────────────────────────────────────────────────────
class _ErrorSliver extends StatelessWidget {
  final String message;
  const _ErrorSliver({required this.message});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 48.sp),
            SizedBox(height: 12.h),
            Text(message,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────
class _EmptySliver extends StatelessWidget {
  const _EmptySliver();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded,
                color: Colors.grey.shade300, size: 64.sp),
            SizedBox(height: 16.h),
            Text(
              AppStrings.noCustomersFound,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              AppStrings.noCustomersSubtitle,
              style: TextStyle(
                  color: Colors.grey.shade400, fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Populated List ───────────────────────────────────────────────────────────
class _CustomerListView extends StatelessWidget {
  final List<Customer> customers;
  const _CustomerListView({required this.customers});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final customer = customers[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: CustomerCard(
                customer: customer,
                index: index,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CustomerDetailScreen(customer: customer),
                    ),
                  ).then((_) {
                    if (context.mounted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      });
                      context
                          .read<CustomerBloc>()
                          .add(const LoadCustomers());
                    }
                  });
                },
              ),
            );
          },
          childCount: customers.length,
        ),
      ),
    );
  }
}

// ── Customer Card ────────────────────────────────────────────────────────────
class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final int index;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isSynced = customer.syncStatus.name.toLowerCase() == 'synced';
    final statusColor = visitStatusColor(customer.visitStatus);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Row(
            children: [
              // Left accent bar
              Container(width: 4.w, height: 90.h, color: statusColor),
              SizedBox(width: 14.w),
              // Avatar
              _CustomerAvatar(
                  name: customer.name, statusColor: statusColor),
              SizedBox(width: 14.w),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1F36),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        text: customer.phone,
                      ),
                      SizedBox(height: 3.h),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: customer.address,
                        maxLines: 1,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          StatusBadge(status: customer.visitStatus),
                          SizedBox(width: 8.w),
                          Text(
                            customer.lastVisitDate != null
                                ? '· ${customer.lastVisitDate}'
                                : AppStrings.noVisitYet,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Sync + chevron
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSynced
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_upload_rounded,
                      color: isSynced
                          ? Colors.greenAccent.shade700
                          : Colors.orange.shade400,
                      size: 20.sp,
                    ),
                    SizedBox(height: 2.h),
                    Icon(Icons.chevron_right_rounded,
                        color: Colors.grey.shade300, size: 18.sp),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Customer Avatar ──────────────────────────────────────────────────────────
class _CustomerAvatar extends StatelessWidget {
  final String name;
  final Color statusColor;

  const _CustomerAvatar({required this.name, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withValues(alpha: 0.8), statusColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : AppStrings.unknownInitial,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── Info Row (icon + text) ───────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final int? maxLines;

  const _InfoRow({required this.icon, required this.text, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 11.sp, color: Colors.grey.shade400),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
            style:
                TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }
}

// ── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final VisitStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      VisitStatus.visited => (
          AppStrings.filterVisited,
          const Color(0xFF4C6EF5),
          const Color(0xFFEEF2FF)
        ),
      VisitStatus.notAvailable => (
          AppStrings.filterNotAvailable,
          const Color(0xFFFA5252),
          const Color(0xFFFFF5F5)
        ),
      VisitStatus.pending => (
          AppStrings.filterPending,
          const Color(0xFFFFAB00),
          const Color(0xFFFFF8E1)
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
