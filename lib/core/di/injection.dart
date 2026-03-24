import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:questfy_app_mobile/core/di/injection.config.dart';


final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // nome do método gerado
  preferRelativeImports: true, // evita imports longos
  asExtension: true, // permite usar getIt.init()
)
Future<void> configureDependencies() async => getIt.init();