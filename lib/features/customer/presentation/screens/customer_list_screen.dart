import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/visit_status.dart';
import '../../../../core/di/app_dependency.dart';
import '../../../../core/network/internet_connection_checker.dart';
import '../cubit/customer_bloc.dart';
import '../cubit/customer_event.dart';
import '../cubit/sync_bloc.dart';
import '../cubit/sync_event.dart';
import '../widgets/customer_app_bar.dart';
import '../widgets/customer_filter_bar.dart';
import '../widgets/customer_list_widgets.dart';
import '../widgets/customer_search_bar.dart';
import '../widgets/sync_banner.dart';
import '../widgets/sync_fab.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final InternetConnectionChecker _connectionChecker =
      instance<InternetConnectionChecker>();

  VisitStatus? _filterStatus;
  late AnimationController _fabAnimationController;

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
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),
        body: CustomScrollView(
          slivers: [
            CustomerAppBar(connectionChecker: _connectionChecker),
            SliverToBoxAdapter(
              child: CustomerSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
              ),
            ),
            SliverToBoxAdapter(
              child: CustomerFilterBar(
                selectedStatus: _filterStatus,
                onStatusChanged: (status) =>
                    setState(() => _filterStatus = status),
              ),
            ),
            const SliverToBoxAdapter(child: SyncBanner()),
            const CustomerListSliver(),
          ],
        ),
        floatingActionButton: SyncFAB(
          animationController: _fabAnimationController,
        ),
      ),
    );
  }
}
