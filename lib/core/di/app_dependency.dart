import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'app_dependency.config.dart';
import '../database/hive_init.dart';

final instance = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Manual initialization of Hive and Boxes
  await HiveInit.init();

  // Initialize generated dependencies
  instance.init();
}
