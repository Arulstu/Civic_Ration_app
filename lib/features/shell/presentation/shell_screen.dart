import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/presentation/screens/home_screen.dart';
import '../../entitlements/presentation/screens/entitlements_screen.dart';
import '../../shop/presentation/screens/shop_screen.dart';
import '../../notices/presentation/screens/notices_screen.dart';
import '../../home/providers/home_providers.dart';
import '../../../core/theme/app_theme.dart';

final shellSelectedIndexProvider = StateProvider<int>((ref) => 0);

class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(shellSelectedIndexProvider);
    final stats = ref.watch(entitlementStatsProvider);

    const screens = [
      HomeScreen(),
      EntitlementsScreen(),
      ShopScreen(),
      NoticesScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) =>
            ref.read(shellSelectedIndexProvider.notifier).state = i,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: stats.pending > 0,
              label: Text('${stats.pending}'),
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.inventory_2_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: stats.pending > 0,
              label: Text('${stats.pending}'),
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.inventory_2_rounded),
            ),
            label: 'My Quota',
          ),
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Shop Stock',
          ),
          const NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign_rounded),
            label: 'Notices',
          ),
        ],
      ),
    );
  }
}
