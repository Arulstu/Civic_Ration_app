import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../shell/presentation/shell_screen.dart';
import '../../providers/shop_providers.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showGrievanceDialog(BuildContext context, Shop? shop) {
    final formKey = GlobalKey<FormState>();
    final descCtrl = TextEditingController();
    String selectedCategory = 'Under-weighing / Shortage';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.support_agent_rounded, color: Color(0xFFEF6C00), size: 24),
              ),
              const SizedBox(width: 10),
              Text('Report FPS Issue', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17)),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lodge an official complaint against ${shop?.name ?? "Fair Price Shop #42"} with the District Civil Supplies Officer.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Issue Category'),
                  items: const [
                    DropdownMenuItem(value: 'Under-weighing / Shortage', child: Text('Quantity Shortage')),
                    DropdownMenuItem(value: 'Stock Diversion / Refusal to Sell', child: Text('Stock Refusal / Diversion')),
                    DropdownMenuItem(value: 'Overcharging Subsidized Rate', child: Text('Overcharging')),
                    DropdownMenuItem(value: 'Shop Kept Closed Unauthorized', child: Text('Shop Closed Unauthorized')),
                    DropdownMenuItem(value: 'Biometric Machine Issues', child: Text('Biometric Failure')),
                  ],
                  onChanged: (v) => setModalState(() => selectedCategory = v ?? selectedCategory),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Details of Issue',
                    hintText: 'Enter specific details...',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe the issue' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                final user = ref.read(currentUserProfileProvider).valueOrNull ?? ref.read(activeUserSessionProvider);
                final userId = user?.uid ?? 'user_bpl_default';
                final userName = user?.name ?? 'Ramesh Kumar';
                final cardNum = user?.cardNumber ?? '4829-1092-8821';

                final ticketId = await ref.read(firebaseServiceProvider).fileGrievance(
                  userId: userId,
                  userName: userName,
                  cardNumber: cardNum,
                  shopId: shop?.id ?? 'shop_42',
                  shopName: shop?.name ?? 'Fair Price Shop #42',
                  category: selectedCategory,
                  description: descCtrl.text.trim(),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Complaint #${ticketId.substring(0, 8).toUpperCase()} forwarded to Civil Supplies Dept.'),
                      backgroundColor: AppColors.secondary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
              child: const Text('Submit Complaint'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNavigationModal(BuildContext context, Shop? shop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.map_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text('Shop Locator Map', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_pin, color: AppColors.primary, size: 40),
                    const SizedBox(height: 4),
                    Text(
                      shop?.name ?? 'Ganesh PDS Kendra #42',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Text('Lat: ${shop?.lat ?? 13.0827} • Lng: ${shop?.lng ?? 80.2707}', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Address:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12)),
            Text(shop?.address ?? 'Ward No. 12, Near Gram Panchayat, Rampur', style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text('Timings: ${shop?.timing ?? "7:00 AM – 1:00 PM (Tue-Sun)"}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCallDealerModal(BuildContext context, Shop? shop) {
    final dealerName = shop?.dealerName ?? 'Ganesh Verma';
    final dealerPhone = shop?.phone ?? '+91 98765 43210';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Fair Price Dealer', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.secondaryContainer,
                child: Icon(Icons.person_rounded, color: AppColors.primary),
              ),
              title: Text(dealerName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              subtitle: Text('Authorized Dealer • $dealerPhone'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Calling $dealerName ($dealerPhone)...'),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.call_rounded),
              label: const Text('Call Now'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stockFilteredAsync = ref.watch(filteredShopCommoditiesProvider);
    final currentShopAsync = ref.watch(currentShopProvider);
    final selectedCategory = ref.watch(stockCategoryFilterProvider);
    final shop = currentShopAsync.valueOrNull;

    final categories = ['All', 'Grains', 'Sugar & Essentials', 'Pulses', 'Oils', 'Fuel'];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AppColors.onPrimary, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'Shop Locator & Live Stock',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Freshness & Dashboard Return ─────────────────────
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Switch to Home tab (index 0)
                        ref.read(shellSelectedIndexProvider.notifier).state = 0;
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.onSurfaceVariant),
                      label: Text('Dashboard', style: Theme.of(context).textTheme.labelLarge),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            shop?.stockUpdateAgo ?? 'Live Stock: 15 mins ago',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Shop Hero Card ────────────────────────────────────
                _ShopHeroCard(
                  shop: shop,
                  onViewMap: () => _showNavigationModal(context, shop),
                  onCallDealer: () => _showCallDealerModal(context, shop),
                ),

                const SizedBox(height: 16),

                // ── Search & Filter Bar ───────────────────────────────
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search commodities (e.g. Rice, Wheat, Oil)...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref.read(stockSearchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onChanged: (val) => ref.read(stockSearchQueryProvider.notifier).state = val,
                ),
                const SizedBox(height: 10),

                // ── Category Filter Pills ─────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = selectedCategory.toLowerCase() == cat.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            ref.read(stockCategoryFilterProvider.notifier).state = cat;
                          },
                          backgroundColor: AppColors.surfaceContainerHigh,
                          selectedColor: AppColors.primary,
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Stock Header ──────────────────────────────────────
                Row(
                  children: [
                    Text('Ration Stock Inventory', style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    Text('Subsidized Pricing', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Realtime Stock List ───────────────────────────────
                stockFilteredAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.search_off_rounded, size: 40, color: AppColors.outline),
                              const SizedBox(height: 8),
                              Text('No commodities match your search', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: items
                          .map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _StockTile(commodity: item),
                              ))
                          .toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text('Error loading live stock: $e'),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Grievance Banner ──────────────────────────────────
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showGrievanceDialog(context, shop),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFE082), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE082),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.support_agent_rounded, size: 22, color: AppColors.onSurface),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Report a Grievance to Taluk Supply Officer', style: Theme.of(context).textTheme.labelLarge),
                              Text(
                                'Quantity shortage, poor foodgrain quality, or overcharging? File ticket.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopHeroCard extends StatelessWidget {
  final Shop? shop;
  final VoidCallback onViewMap;
  final VoidCallback onCallDealer;

  const _ShopHeroCard({
    this.shop,
    required this.onViewMap,
    required this.onCallDealer,
  });

  @override
  Widget build(BuildContext context) {
    final name = shop?.name ?? 'Ganesh Fair Price Shop #42';
    final address = shop?.address ?? 'Ward No. 12, Near Gram Panchayat, Rampur';
    final timings = shop?.timing ?? '7:00 AM – 1:00 PM • Tue - Sun (Mon Closed)';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 11, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Authorized Fair Price Kendra',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 13, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            address,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 26),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Timings box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: AppColors.secondary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STORE TIMINGS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.outline,
                        ),
                      ),
                      Text(
                        timings,
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewMap,
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: const Text('View on Map'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    textStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCallDealer,
                  icon: const Icon(Icons.call_rounded, size: 16),
                  label: const Text('Call Dealer'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    textStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockTile extends StatelessWidget {
  final ShopCommodity commodity;
  const _StockTile({required this.commodity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: commodity.stockStatus == StockStatus.outOfStock
                  ? AppColors.surfaceContainerHigh
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _resolveShopIcon(commodity.icon),
              color: commodity.stockStatus == StockStatus.outOfStock ? AppColors.outline : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(commodity.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '(${commodity.localName})',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                if (commodity.replenishmentNote != null)
                  Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        size: 12,
                        color: commodity.stockStatus == StockStatus.outOfStock ? AppColors.error : const Color(0xFFEF6C00),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          commodity.replenishmentNote!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: commodity.stockStatus == StockStatus.outOfStock ? AppColors.error : const Color(0xFFEF6C00),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '${commodity.cap} • Live Stock: ${commodity.stockKg.toStringAsFixed(0)} ${commodity.unit}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '₹${commodity.pricePerUnit.toStringAsFixed(commodity.pricePerUnit % 1 == 0 ? 0 : 2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: commodity.stockStatus == StockStatus.outOfStock ? AppColors.outline : AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: '/${commodity.unit}',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              _StockChip(status: commodity.stockStatus),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  final StockStatus status;
  const _StockChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case StockStatus.available:
        bg = AppColors.statusAvailableBg;
        fg = AppColors.statusAvailableText;
        label = 'AVAILABLE';
        break;
      case StockStatus.lowStock:
        bg = AppColors.statusLowStockBg;
        fg = AppColors.statusLowStockText;
        label = 'LOW STOCK';
        break;
      case StockStatus.outOfStock:
        bg = AppColors.statusOutBg;
        fg = AppColors.statusOutText;
        label = 'OUT OF STOCK';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

IconData _resolveShopIcon(String name) {
  switch (name) {
    case 'grain':
      return Icons.grain_rounded;
    case 'grass':
      return Icons.grass_rounded;
    case 'cookie':
      return Icons.cookie_rounded;
    case 'spa':
      return Icons.spa_rounded;
    case 'water_drop':
      return Icons.water_drop_rounded;
    case 'oil_barrel':
      return Icons.local_gas_station_rounded;
    default:
      return Icons.inventory_2_rounded;
  }
}
