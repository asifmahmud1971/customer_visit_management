import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/app_dependency.dart';
import '../../../../core/constants/visit_status.dart';
import '../../../../core/network/internet_connection_checker.dart';
import '../../domain/entities/customer.dart';
import '../cubit/customer_bloc.dart';
import '../cubit/customer_event.dart';
import '../cubit/customer_state.dart';
import '../cubit/sync_bloc.dart';
import '../cubit/sync_event.dart';
import '../cubit/sync_state.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  VisitStatus? _filterStatus;
  final InternetConnectionChecker _connectionChecker =
      instance<InternetConnectionChecker>();
  late AnimationController _fabAnimationController;

  // Color palette
  static const Color _primaryDark = Color(0xFF0F1629);
  static const Color _primaryMid = Color(0xFF1A2744);
  static const Color _accent = Color(0xFF4C6EF5);

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    context.read<CustomerBloc>().add(const LoadCustomers());
    context.read<SyncBloc>().add(StartSyncPolling());
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildFilterBar()),
          SliverToBoxAdapter(child: _buildSyncBanner()),
          _buildCustomerList(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140.h,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryDark, _primaryMid, Color(0xFF1E3A5F)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Visits',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          BlocBuilder<CustomerBloc, CustomerState>(
                            builder: (context, state) {
                              final count = state is CustomerLoaded
                                  ? state.customers.length
                                  : 0;
                              return Text(
                                '$count customers total',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12.sp,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      StreamBuilder<bool>(
                        stream: Stream.periodic(const Duration(seconds: 3))
                            .asyncMap(
                                (_) => _connectionChecker.hasInternetConnection()),
                        builder: (context, snapshot) {
                          final isOnline = snapshot.data ?? false;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? Colors.greenAccent.withValues(alpha: 0.2)
                                  : Colors.redAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isOnline
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7.w,
                                  height: 7.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isOnline
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  isOnline ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    color: isOnline
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: _primaryDark,
      title: Text(
        'Customer Visits',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Search by name or phone…',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.grey.shade400, size: 20.sp),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: Colors.grey.shade400, size: 18.sp),
                    onPressed: () {
                      _searchController.clear();
                      context
                          .read<CustomerBloc>()
                          .add(const SearchCustomers(''));
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          ),
          onChanged: (value) {
            setState(() {});
            context.read<CustomerBloc>().add(SearchCustomers(value));
          },
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
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
      // with non-uniform borders (Flutter restriction)
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            final all = state is CustomerLoaded ? state.customers : <dynamic>[];
            int countFor(VisitStatus? s) => s == null
                ? all.length
                : all.where((c) => c.visitStatus == s).length;

            return IntrinsicHeight(
              child: Row(
                children: filters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final status = entry.value;
                  final isSelected = _filterStatus == status;
                  final (label, icon) = switch (status) {
                    null => ('All', Icons.list_rounded),
                    VisitStatus.visited =>
                      ('Visited', Icons.check_circle_outline_rounded),
                    VisitStatus.notAvailable =>
                      ('N/A', Icons.cancel_outlined),
                    VisitStatus.pending =>
                      ('Pending', Icons.schedule_rounded),
                  };
                  final count = countFor(status);
                  final tabColor =
                      isSelected ? _accent : Colors.grey.shade500;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() => _filterStatus = status);
                        context
                            .read<CustomerBloc>()
                            .add(FilterCustomers(status));
                      },
                      child: Stack(
                        children: [
                          // Tab background + bottom indicator via Stack
                          // Use uniform-only borders to avoid Flutter crash
                          Container(
                            color: isSelected
                                ? _accent.withValues(alpha: 0.05)
                                : Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(icon,
                                        size: 13.sp, color: tabColor),
                                    SizedBox(width: 3.w),
                                    if (count > 0)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5.w, vertical: 1.h),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? _accent
                                              : Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          '$count',
                                          style: TextStyle(
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: tabColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Bottom indicator line (uniform border = no crash)
                          if (isSelected)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2.5,
                                color: _accent,
                              ),
                            ),
                          // Right divider (not for last tab)
                          if (index < filters.length - 1)
                            Positioned(
                              top: 8.h,
                              bottom: 8.h,
                              right: 0,
                              child: Container(
                                width: 1,
                                color: Colors.grey.shade100,
                              ),
                            ),
                        ],
                      ),
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

  Widget _buildSyncBanner() {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        if (state.pendingCount == 0) return const SizedBox(height: 8);
        return Container(
          margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFF3CD),
                Colors.orange.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border:
                Border.all(color: Colors.orange.shade200, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_upload_outlined,
                    color: Colors.orange.shade700, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${state.pendingCount} pending sync',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Will sync when connection is restored',
                      style: TextStyle(
                        color: Colors.orange.shade600,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerList() {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40.w,
                    height: 40.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_accent),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading customers…',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is CustomerError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: Colors.redAccent, size: 48.sp),
                  SizedBox(height: 12.h),
                  Text(state.message,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 14.sp)),
                ],
              ),
            ),
          );
        }

        if (state is CustomerLoaded) {
          final customers = state.filteredCustomers;
          if (customers.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search_rounded,
                        color: Colors.grey.shade300, size: 64.sp),
                    SizedBox(height: 16.h),
                    Text(
                      'No customers found',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Try adjusting your search or filter',
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final customer = customers[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _CustomerCard(
                      customer: customer,
                      index: index,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CustomerDetailScreen(customer: customer),
                          ),
                        ).then((_) {
                          if (context.mounted) {
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

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildFAB() {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.elasticOut,
          ),
          child: FloatingActionButton.extended(
            onPressed: state.isSyncing
                ? null
                : () => context.read<SyncBloc>().add(ManualSyncNow()),
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            elevation: 6,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: state.isSyncing
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(Icons.cloud_sync_rounded,
                      key: const ValueKey('icon'), size: 20.sp),
            ),
            label: Text(
              state.isSyncing ? 'Syncing…' : 'Sync Now',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        );
      },
    );
  }


}

// ─────────────────────────────────────────────
// Customer Card
// ─────────────────────────────────────────────
class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final int index;

  const _CustomerCard({
    required this.customer,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isSynced = customer.syncStatus.name == 'synced';
    final statusColor = _statusColor(customer.visitStatus);

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
              Container(
                width: 4.w,
                height: 90.h,
                color: statusColor,
              ),
              SizedBox(width: 14.w),
              // Avatar
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withValues(alpha: 0.8),
                      statusColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
                      Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 11.sp, color: Colors.grey.shade400),
                          SizedBox(width: 4.w),
                          Text(
                            customer.phone,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 11.sp, color: Colors.grey.shade400),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              customer.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _StatusBadge(status: customer.visitStatus),
                          SizedBox(width: 8.w),
                          Text(
                            customer.lastVisitDate != null
                                ? '· ${customer.lastVisitDate}'
                                : '· No visit yet',
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
              // Sync icon
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

  Color _statusColor(VisitStatus status) {
    switch (status) {
      case VisitStatus.visited:
        return const Color(0xFF4C6EF5);
      case VisitStatus.notAvailable:
        return const Color(0xFFFA5252);
      case VisitStatus.pending:
        return const Color(0xFFFFAB00);
    }
  }
}

// ─────────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final VisitStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      VisitStatus.visited => ('Visited', const Color(0xFF4C6EF5), const Color(0xFFEEF2FF)),
      VisitStatus.notAvailable => ('Not Available', const Color(0xFFFA5252), const Color(0xFFFFF5F5)),
      VisitStatus.pending => ('Pending', const Color(0xFFFFAB00), const Color(0xFFFFF8E1)),
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
