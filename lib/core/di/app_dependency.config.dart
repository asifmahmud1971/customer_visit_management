// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:pridesys_task/core/network/api_client.dart' as _i302;
import 'package:pridesys_task/core/network/api_request.dart' as _i862;
import 'package:pridesys_task/core/network/dio_module.dart' as _i1025;
import 'package:pridesys_task/core/network/internet_connection_checker.dart'
    as _i174;
import 'package:pridesys_task/core/utils/app_preference.dart' as _i89;
import 'package:pridesys_task/features/customer/data/datasource/local/customer_local_data_source.dart'
    as _i700;
import 'package:pridesys_task/features/customer/data/datasource/remote/customer_remote_data_source.dart'
    as _i807;
import 'package:pridesys_task/features/customer/data/repositories/customer_repository_impl.dart'
    as _i747;
import 'package:pridesys_task/features/customer/domain/repositories/customer_repository.dart'
    as _i804;
import 'package:pridesys_task/features/customer/presentation/cubit/customer_bloc.dart'
    as _i627;
import 'package:pridesys_task/features/customer/presentation/cubit/sync_bloc.dart'
    as _i926;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final dioModule = _$DioModule();
    gh.factory<_i862.ApiRequest>(() => _i862.ApiRequest());
    gh.factory<_i89.AppPreferences>(() => _i89.AppPreferences());
    gh.lazySingleton<_i174.InternetConnectionChecker>(
        () => _i174.InternetConnectionChecker());
    gh.lazySingleton<_i361.Dio>(() => dioModule.dio);
    gh.lazySingleton<_i700.CustomerLocalDataSource>(
        () => _i700.CustomerLocalDataSourceImpl());
    gh.lazySingleton<_i302.ApiClient>(() => _i302.ApiClient(
          gh<_i361.Dio>(),
          gh<_i89.AppPreferences>(),
          gh<_i174.InternetConnectionChecker>(),
        ));
    gh.lazySingleton<_i807.CustomerRemoteDataSource>(
        () => _i807.CustomerRemoteDataSourceImpl(gh<_i302.ApiClient>()));
    gh.lazySingleton<_i804.CustomerRepository>(
        () => _i747.CustomerRepositoryImpl(
              gh<_i700.CustomerLocalDataSource>(),
              gh<_i807.CustomerRemoteDataSource>(),
              gh<_i174.InternetConnectionChecker>(),
            ));
    gh.factory<_i926.SyncBloc>(
        () => _i926.SyncBloc(gh<_i804.CustomerRepository>()));
    gh.factory<_i627.CustomerBloc>(
        () => _i627.CustomerBloc(gh<_i804.CustomerRepository>()));
    return this;
  }
}

class _$DioModule extends _i1025.DioModule {}
