import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModule {
  @preResolve // Faz o app esperar o SharedPreferences carregar antes de abrir a tela
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}