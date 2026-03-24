import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/providers/user_provider.dart';
// ADICIONE ESTE IMPORT (Verifique se o caminho está exato conforme seu projeto)
import 'features/missions/data/providers/mission_provider.dart'; 

void main() async {
  // 1. Garante que as chamadas nativas funcionem antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o GetIt + Injectable
  await configureDependencies();

  runApp(
    // 3. MultiProvider: Agora com os dois Providers registrados
    MultiProvider(
      providers: [
        // Provider do Usuário (XP/Streak)
        ChangeNotifierProvider(
          create: (_) => getIt<UserProvider>()..loadData(),
        ),
        
        // ADICIONE ESTE AQUI: Provider de Missões
        // O "..loadMissions()" garante que a lista seja buscada do banco assim que o app abrir
        ChangeNotifierProvider(
          create: (_) => getIt<MissionProvider>()..loadMissions(),
        ),
      ],
      child: const QuestifyApp(),
    ),
  );
}

class QuestifyApp extends StatelessWidget {
  const QuestifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Questify',
      debugShowCheckedModeBanner: false,
      
      // Tema Dark / Linear Style
      theme: AppTheme.darkTheme,
      
      // Configuração de rotas (GoRouter)
      routerConfig: AppRouter.router,
    );
  }
}