import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/sync_status.dart';
import '../../../../core/constants/visit_status.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/customer.dart';
import '../cubit/customer_bloc.dart';
import '../cubit/customer_event.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;
  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen>
    with SingleTickerProviderStateMixin {
  late VisitStatus _currentStatus;
  late TextEditingController _notesController;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _primaryDark = Color(0xFF0F1629);
  static const Color _primaryMid = Color(0xFF1A2744);
  static const Color _accent = Color(0xFF4C6EF5);

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.customer.visitStatus;
    _notesController =
        TextEditingController(text: widget.customer.notes ?? '');

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (_currentStatus) {
      case VisitStatus.visited:
        return const Color(0xFF4C6EF5);
      case VisitStatus.notAvailable:
        return const Color(0xFFFA5252);
      case VisitStatus.pending:
        return const Color(0xFFFFAB00);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isSynced = widget.customer.syncStatus == SyncStatus.synced;
    final initials = widget.customer.name.isNotEmpty
        ? widget.customer.name.trim().split(' ').map((e) => e[0]).take(2).join()
        : AppStrings.unknownInitial;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            elevation: 0,
            backgroundColor: _primaryDark,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
              onPressed: () => Navigator.pop(context),
            ),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10.h),
                      // Avatar
                      Container(
                        width: 72.w,
                        height: 72.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _statusColor.withValues(alpha: 0.8),
                              _statusColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _statusColor.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        widget.customer.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Sync pill
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSynced
                              ? Colors.greenAccent.withValues(alpha: 0.15)
                              : Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSynced
                                ? Colors.greenAccent.shade400
                                : Colors.orange.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSynced
                                  ? Icons.cloud_done_rounded
                                  : Icons.cloud_upload_rounded,
                              size: 12.sp,
                              color: isSynced
                                  ? Colors.greenAccent.shade400
                                  : Colors.orange.shade300,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              isSynced ? AppStrings.synced : AppStrings.pendingSync,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: isSynced
                                    ? Colors.greenAccent.shade400
                                    : Colors.orange.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact info card
                      _SectionCard(
                        title: AppStrings.sectionContactInfo,
                        icon: Icons.person_outline_rounded,
                        children: [
                          _InfoRow(
                              icon: Icons.phone_outlined,
                              label: AppStrings.labelPhone,
                              value: widget.customer.phone),
                          _divider(),
                          _InfoRow(
                              icon: Icons.email_outlined,
                              label: AppStrings.labelEmail,
                              value: widget.customer.email),
                          _divider(),
                          _InfoRow(
                              icon: Icons.location_on_outlined,
                              label: AppStrings.labelAddress,
                              value: widget.customer.address),
                          if (widget.customer.lastVisitDate != null) ...[
                            _divider(),
                            _InfoRow(
                                icon: Icons.calendar_today_outlined,
                                label: AppStrings.labelLastVisit,
                                value: widget.customer.lastVisitDate!),
                          ],
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Visit Status card
                      _SectionCard(
                        title: AppStrings.sectionVisitStatus,
                        icon: Icons.flag_outlined,
                        children: [
                          SizedBox(height: 4.h),
                          // Status selector chips
                          Row(
                            children: VisitStatus.values.map((s) {
                              final isSelected = _currentStatus == s;
                              final color = _visitStatusColor(s);
                              final label = _visitStatusLabel(s);
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _currentStatus = s),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    margin: EdgeInsets.only(
                                        right: s != VisitStatus.values.last
                                            ? 8.w
                                            : 0),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.h),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? color
                                          : color.withValues(alpha: 0.08),
                                      borderRadius:
                                          BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? color
                                            : Colors.transparent,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color:
                                                    color.withValues(alpha: 0.35),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              )
                                            ]
                                          : [],
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          _visitStatusIcon(s),
                                          color: isSelected
                                              ? Colors.white
                                              : color,
                                          size: 18.sp,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          label,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : color,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Notes card
                      _SectionCard(
                        title: AppStrings.sectionVisitNotes,
                        icon: Icons.notes_rounded,
                        children: [
                          SizedBox(height: 4.h),
                          TextField(
                            controller: _notesController,
                            maxLines: 4,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF1A1F36),
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  AppStrings.notesHint,
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13.sp,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8F9FF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(
                                    color: _accent, width: 1.5),
                              ),
                              contentPadding: EdgeInsets.all(14.w),
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),

                      SizedBox(height: 28.h),

                      // Action buttons row
                      Row(
                        children: [
                          // Log New Visit button
                          Expanded(
                            child: SizedBox(
                              height: 52.h,
                              child: OutlinedButton(
                                onPressed: _logNewVisit,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _accent,
                                  side: const BorderSide(color: _accent, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline_rounded, size: 16.sp),
                                    SizedBox(height: 2.h),
                                    Text(
                                      AppStrings.btnLogVisit,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Save Changes button
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 52.h,
                              child: ElevatedButton(
                                onPressed: _saveChanges,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: Colors.white,
                                  elevation: 6,
                                  shadowColor: _accent.withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_rounded, size: 18.sp),
                                    SizedBox(width: 8.w),
                                    Text(
                                      AppStrings.btnSaveChanges,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade100,
        indent: 36.w,
      );

  Color _visitStatusColor(VisitStatus s) {
    switch (s) {
      case VisitStatus.visited:
        return const Color(0xFF4C6EF5);
      case VisitStatus.notAvailable:
        return const Color(0xFFFA5252);
      case VisitStatus.pending:
        return const Color(0xFFFFAB00);
    }
  }

  String _visitStatusLabel(VisitStatus s) {
    switch (s) {
      case VisitStatus.visited:
        return AppStrings.statusVisited;
      case VisitStatus.notAvailable:
        return AppStrings.statusNotAvailable;
      case VisitStatus.pending:
        return AppStrings.statusPending;
    }
  }

  IconData _visitStatusIcon(VisitStatus s) {
    switch (s) {
      case VisitStatus.visited:
        return Icons.check_circle_rounded;
      case VisitStatus.notAvailable:
        return Icons.cancel_rounded;
      case VisitStatus.pending:
        return Icons.schedule_rounded;
    }
  }

  void _saveChanges() {
    context.read<CustomerBloc>().add(UpdateVisitStatus(
          customerId: widget.customer.id,
          status: _currentStatus,
          notes: _notesController.text,
        ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_upload_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            const Text(AppStrings.snackSavedLocally),
          ],
        ),
        backgroundColor: const Color(0xFF4C6EF5),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _logNewVisit() {
    context.read<CustomerBloc>().add(CreateVisit(
          customerId: widget.customer.id,
          status: _currentStatus,
          notes: _notesController.text,
        ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.add_location_alt_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            const Text(AppStrings.snackVisitLogged),
          ],
        ),
        backgroundColor: const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable Section Card
// ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard(
      {required this.title,
      required this.icon,
      required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C6EF5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon,
                      color: const Color(0xFF4C6EF5), size: 14.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1F36),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Info Row
// ─────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey.shade400),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    fontSize: 11.sp, color: Colors.grey.shade400),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1F36),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
