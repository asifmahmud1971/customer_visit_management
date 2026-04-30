import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_strings.dart';
import '../cubit/sync_bloc.dart';
import '../cubit/sync_state.dart';

class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        if (state.pendingCount == 0) return const SizedBox(height: 8);
        return Container(
          margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFFFF3CD), Colors.orange.shade50],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.orange.shade200, width: 1),
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
                      '${state.pendingCount} ${AppStrings.pendingSyncTitle}',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppStrings.pendingSyncSubtitle,
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
}
