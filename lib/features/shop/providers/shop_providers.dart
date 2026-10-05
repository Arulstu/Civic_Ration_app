import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../auth/providers/auth_provider.dart';

// ─── Selected shop identifier ────────────────────────────────────────────────
final selectedShopIdProvider = StateProvider<String>((ref) => 'shop_42');

// ─── Selected Fair Price Shop Details ────────────────────────────────────────
final currentShopProvider = StreamProvider<Shop?>((ref) {
  final shopId = ref.watch(selectedShopIdProvider);
  final service = ref.watch(firebaseServiceProvider);
  return service.shopStream(shopId);
});

// ─── Shop Live Stock Commodities ─────────────────────────────────────────────
final shopCommoditiesProvider = StreamProvider<List<ShopCommodity>>((ref) {
  final shopId = ref.watch(selectedShopIdProvider);
  final service = ref.watch(firebaseServiceProvider);
  return service.shopStockStream(shopId);
});

// ─── Search and Category Filters ─────────────────────────────────────────────
final stockSearchQueryProvider = StateProvider<String>((ref) => '');
final stockCategoryFilterProvider = StateProvider<String>((ref) => 'All');

// ─── Filtered Stock Provider ─────────────────────────────────────────────────
final filteredShopCommoditiesProvider =
    Provider<AsyncValue<List<ShopCommodity>>>((ref) {
  final stockAsync = ref.watch(shopCommoditiesProvider);
  final query = ref.watch(stockSearchQueryProvider).toLowerCase().trim();
  final category = ref.watch(stockCategoryFilterProvider);

  return stockAsync.whenData((items) {
    return items.where((item) {
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.localName.toLowerCase().contains(query);
      final matchesCategory =
          category == 'All' || item.category.toLowerCase() == category.toLowerCase();
      return matchesQuery && matchesCategory;
    }).toList();
  });
});
