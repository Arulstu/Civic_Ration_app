import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/shell/presentation/shell_screen.dart';
import 'features/shell/presentation/shopkeeper_shell.dart';

class CivicHarvestApp extends ConsumerWidget {
  const CivicHarvestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Civic Harvest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user == null) return const LoginScreen();
          // Route by role
          if (user.isShopkeeper) return const ShopkeeperShell();
          return const ShellScreen();
        },
        loading: () => const Scaffold(
          backgroundColor: AppColors.surface,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        error: (error, stack) => const LoginScreen(),
      ),
    );
  }
}
