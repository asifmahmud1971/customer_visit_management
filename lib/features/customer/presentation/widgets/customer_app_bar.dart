import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/network/internet_connection_checker.dart';
import '../cubit/customer_bloc.dart';
import '../cubit/customer_state.dart';

class CustomerAppBar extends StatelessWidget {
  final InternetConnectionChecker connectionChecker;

  static const Color _primaryDark = Color(0xFF0F1629);
  static const Color _primaryMid = Color(0xFF1A2744);

  const CustomerAppBar({super.key, required this.connectionChecker});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: _primaryDark,
      title: Text(
        AppStrings.customerVisits,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TitleSection(),
                      _ConnectivityBadge(connectionChecker: connectionChecker),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Title + Customer Count ───────────────────────────────────────────────────
class _TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.customerVisits,
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
            final count =
                (state is CustomerLoaded) ? state.customers.length : 0;
            return Text(
              '$count ${AppStrings.customersTotal}',
              style: TextStyle(color: Colors.white54, fontSize: 12.sp),
            );
          },
        ),
      ],
    );
  }
}

// ── Online / Offline Badge ───────────────────────────────────────────────────
class _ConnectivityBadge extends StatelessWidget {
  final InternetConnectionChecker connectionChecker;

  const _ConnectivityBadge({required this.connectionChecker});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: Stream.periodic(const Duration(seconds: 3))
          .asyncMap((_) => connectionChecker.hasInternetConnection()),
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? false;
        final color = isOnline ? Colors.greenAccent : Colors.redAccent;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7.w,
                height: 7.w,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              SizedBox(width: 6.w),
              Text(
                isOnline ? AppStrings.online : AppStrings.offline,
                style: TextStyle(
                  color: color,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
