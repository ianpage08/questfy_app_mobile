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
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/home/presentation/providers/user_provider.dart' as _i172;
import '../../features/missions/data/repositories/i_mission_repository.dart'
    as _i50;
import '../../features/missions/data/repositories/i_mission_repository_impl.dart'
    as _i436;
import '../../features/missions/data/repositories/mission_repository.dart'
    as _i117;
import '../../features/profile/domain/services/gamification_service.dart'
    as _i888;
import '../../features/profile/presentation/data/repositories/i_user_progress_repository.dart'
    as _i294;
import '../../features/profile/presentation/data/repositories/i_user_progress_repository_impl.dart'
    as _i683;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i50.IMissionRepository>(
      () => _i436.MissionRepositoryImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i294.IUserProgressRepository>(
      () => _i683.UserProgressRepositoryImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i117.IMissionRepository>(
      () => _i117.MissionRepository(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i888.GamificationService>(
      () => _i888.GamificationService(
        gh<_i294.IUserProgressRepository>(),
        gh<_i50.IMissionRepository>(),
      ),
    );
    gh.factory<_i172.UserProvider>(
      () => _i172.UserProvider(
        gh<_i888.GamificationService>(),
        gh<_i294.IUserProgressRepository>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
