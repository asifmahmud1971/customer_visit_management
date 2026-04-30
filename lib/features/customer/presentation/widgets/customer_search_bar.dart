import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_strings.dart';
import '../cubit/customer_bloc.dart';
import '../cubit/customer_event.dart';

class CustomerSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const CustomerSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
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
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.grey.shade400, size: 20.sp),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: Colors.grey.shade400, size: 18.sp),
                    onPressed: () {
                      controller.clear();
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
            context.read<CustomerBloc>().add(SearchCustomers(value));
          },
        ),
      ),
    );
  }
}
