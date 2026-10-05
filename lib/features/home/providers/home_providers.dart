import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../auth/providers/auth_provider.dart';

// ─── User Profile Stream Provider ─────────────────────────────────────────────

final userProfileProvider = StreamProvider<RationUser?>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final activeUser = authAsync.valueOrNull ?? ref.watch(activeUserSessionProvider);
  final service = ref.watch(firebaseServiceProvider);

  final uid = activeUser?.uid ?? 'user_bpl_default';
  return service.userStream(uid);
});

// ─── User Realtime Commodities Quota Provider ─────────────────────────────────

final commoditiesProvider = StreamProvider<List<Commodity>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final activeUser = authAsync.valueOrNull ?? ref.watch(activeUserSessionProvider);
  final service = ref.watch(firebaseServiceProvider);

  final uid = activeUser?.uid ?? 'user_bpl_default';
  return service.commoditiesStream(uid);
});

// ─── Entitlement Calculation Stats ───────────────────────────────────────────

final entitlementStatsProvider = Provider<({
  int total,
  int collected,
  int pending,
  double progress,
  double totalKg,
  double collectedKg,
})>((ref) {
  final commodities = ref.watch(commoditiesProvider).valueOrNull ?? [];
  final total = commodities.length;
  final collectedItems = commodities
      .where((c) => c.status == EntitlementStatus.collected)
      .toList();
  final collected = collectedItems.length;
  final pending = total - collected;
  final progress = total > 0 ? (collected / total) : 0.0;

  double totalKg = 0;
  double collectedKg = 0;
  for (final c in commodities) {
    if (c.unit.toLowerCase().contains('kg')) {
      totalKg += c.quantity;
      if (c.status == EntitlementStatus.collected) {
        collectedKg += c.quantity;
      }
    }
  }

  return (
    total: total,
    collected: collected,
    pending: pending,
    progress: progress,
    totalKg: totalKg,
    collectedKg: collectedKg,
  );
});

// ─── User Assigned Fair Price Shop Stream ────────────────────────────────────

final assignedShopProvider = StreamProvider<Shop?>((ref) {
  final user = ref.watch(userProfileProvider).valueOrNull;
  final shopId = user?.shopId ?? 'shop_42';
  final service = ref.watch(firebaseServiceProvider);

  return service.shopStream(shopId);
});

// ─── User Realtime Notifications Provider ────────────────────────────────────

final userNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final activeUser = authAsync.valueOrNull ?? ref.watch(activeUserSessionProvider);
  final service = ref.watch(firebaseServiceProvider);

  final uid = activeUser?.uid ?? 'user_bpl_default';
  return service.notificationsStream(uid);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(userNotificationsProvider).valueOrNull ?? [];
  return list.where((n) => !n.isRead).length;
});

// ─── Recent Ration Transactions Provider ─────────────────────────────────────

final userTransactionsProvider = StreamProvider<List<RationTransaction>>((ref) {
  final authAsync = ref.watch(authStateProvider);
  final activeUser = authAsync.valueOrNull ?? ref.watch(activeUserSessionProvider);
  final service = ref.watch(firebaseServiceProvider);

  final uid = activeUser?.uid ?? 'user_bpl_default';
  return service.transactionsStream(uid);
});
