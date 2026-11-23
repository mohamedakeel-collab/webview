// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../../features/store/presentation/imports/store_imports.dart'
    as _i521;
import '../../network/auth/token_storage.dart' as _i235;
import '../cubits/base_url/base_url_cubit.dart' as _i200;
import '../cubits/user_cubit/user_cubit.dart' as _i996;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i200.BaseUrlCubit>(() => _i200.BaseUrlCubit());
    gh.factory<_i521.StoreTabCubit>(() => _i521.StoreTabCubit());
    gh.lazySingleton<_i996.UserCubit>(
      () => _i996.UserCubit(gh<_i235.TokenStorage>()),
    );
    return this;
  }
}
