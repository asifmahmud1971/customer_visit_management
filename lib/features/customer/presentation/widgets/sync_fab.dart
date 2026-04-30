import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_strings.dart';
import '../cubit/sync_bloc.dart';
import '../cubit/sync_event.dart';
import '../cubit/sync_state.dart';

class SyncFAB extends StatelessWidget {
  final AnimationController animationController;

  static const Color _accent = Color(0xFF4C6EF5);

  const SyncFAB({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animationController,
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
              state.isSyncing ? AppStrings.syncing : AppStrings.syncNow,
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
