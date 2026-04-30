import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/constants/app_strings.dart';
import 'core/di/app_dependency.dart';
import 'features/customer/presentation/cubit/customer_bloc.dart';
import 'features/customer/presentation/cubit/sync_bloc.dart';
import 'features/customer/presentation/screens/customer_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CustomerBloc>(
          create: (context) => instance<CustomerBloc>(),
        ),
        BlocProvider<SyncBloc>(
          create: (context) => instance<SyncBloc>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppStrings.appTitle,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4C6EF5),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFF5F7FF),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0F1629),
                foregroundColor: Colors.white,
                centerTitle: true,
                elevation: 0,
              ),
              snackBarTheme: SnackBarThemeData(
                backgroundColor: const Color(0xFF4C6EF5),
                contentTextStyle: const TextStyle(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            ),
            home: const CustomerListScreen(),
          );
        },
      ),
    );
  }
}
