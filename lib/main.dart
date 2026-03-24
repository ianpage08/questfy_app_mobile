import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/providers/user_provider.dart';

void main() async {
  // 1. Garante que as chamadas nativas (SharedPreferences/Plugins) funcionem antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o GetIt + Injectable
  // Como usamos @preResolve no SharedPreferences, o app aguarda a conexão com o disco aqui.
  await configureDependencies();

  runApp(
    // 3. MultiProvider: Centraliza o estado. 
    // Usamos o getIt para injetar as instâncias que já têm os Repositories dentro delas.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<UserProvider>()..loadData(),
        ),
        // No futuro, adicione aqui o MissionProvider, FinanceProvider, etc.
      ],
      child: const QuestifyApp(),
    ),
  );
}

class QuestifyApp extends StatelessWidget {
  const QuestifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. MaterialApp.router: Necessário para o GoRouter funcionar
    return MaterialApp.router(
      title: 'Questify',
      debugShowCheckedModeBanner: false,
      
      // 5. Tema Dark / Linear Style que definimos
      theme: AppTheme.darkTheme,
      
      // 6. Configuração de rotas
      routerConfig: AppRouter.router,
    );
  }
}