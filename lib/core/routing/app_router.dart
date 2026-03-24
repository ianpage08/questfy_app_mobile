import 'package:go_router/go_router.dart';
import 'package:questfy_app_mobile/features/home/presentation/screens/home.dart';


class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      // Exemplo de rota futura:
      // GoRoute(
      //   path: '/finance',
      //   builder: (context, state) => const FinanceScreen(),
      // ),
    ],
  );
}