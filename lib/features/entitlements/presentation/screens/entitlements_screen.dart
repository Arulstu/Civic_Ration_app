import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../home/providers/home_providers.dart';

class EntitlementsScreen extends ConsumerWidget {
  const EntitlementsScreen({super.key});

  void _showReceiptDialog(BuildContext context, RationTransaction tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 10),
            Text('Official e-PDS Receipt', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusAvailableBg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'GOVT. APPROVED DISTRIBUTION',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.statusAvailableText),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildReceiptRow('Receipt No', tx.receiptNo),
            _buildReceiptRow('Date & Time', DateFormat('d MMM yyyy, h:mm a').format(tx.date)),
            _buildReceiptRow('Fair Price Shop', tx.shopName),
            _buildReceiptRow('Auth Mode', tx.verificationType),
            const Divider(height: 20),
            Text('Collected Commodities:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            ...tx.itemNames.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(name, style: GoogleFonts.inter(fontSize: 12))),
                    ],
                  ),
                )),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Subsidized Amount:', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)),
                Text('₹${tx.totalAmount.toStringAsFixed(2)}', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
              ],
            ),
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

  static Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, WidgetRef ref, Commodity item, String uid) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_resolveIcon(item.icon), color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(item.localName, style: Theme.of(ctx).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Monthly Allocation', '${item.quantity} ${item.unit}'),
                  _buildReceiptRow('Subsidized Govt. Rate', '₹${item.pricePerUnit.toStringAsFixed(2)} / ${item.unit}'),
                  _buildReceiptRow('Total Price for Quota', '₹${(item.quantity * item.pricePerUnit).toStringAsFixed(2)}'),
                  _buildReceiptRow('NFSA Scheme', item.schemeNote),
                  _buildReceiptRow('Status', item.status == EntitlementStatus.collected ? 'COLLECTED' : 'AVAILABLE'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (item.status != EntitlementStatus.collected)
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref.read(firebaseServiceProvider).claimCommodity(uid, item.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ ${item.name} (${item.quantity} ${item.unit}) claimed in realtime!'),
                        backgroundColor: AppColors.secondary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Claim / Mark as Collected'),
              )
            else
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Already Collected (e-Receipt Verified)'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final commoditiesAsync = ref.watch(commoditiesProvider);
    final stats = ref.watch(entitlementStatsProvider);
    final user = userAsync.valueOrNull ?? ref.watch(activeUserSessionProvider);
    final uid = user?.uid ?? 'user_bpl_default';

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
                  child: const Icon(Icons.inventory_2_rounded, color: AppColors.onPrimary, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'My Quota & Entitlements',
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // ── Status Bar ───────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Realtime Firestore Sync: Active',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.onSurfaceVariant,
                      ),
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
                          const Icon(Icons.verified_rounded, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Aadhaar Linked',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Identity Card ────────────────────────────────────────
                _BplIdentityCard(user: user),

                const SizedBox(height: 14),

                // ── Summary Tiles ────────────────────────────────────────
                Row(
                  children: [
                    _SummaryTile(
                      icon: Icons.calendar_today_rounded,
                      label: 'CYCLE',
                      value: DateFormat('MMM yyyy').format(DateTime.now()),
                    ),
                    const SizedBox(width: 8),
                    _SummaryTile(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'CLAIMED',
                      value: '${stats.collected} of ${stats.total} Items',
                      valueColor: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    _SummaryTile(
                      icon: Icons.scale_rounded,
                      label: 'TOTAL WEIGHT',
                      value: '${stats.totalKg.toStringAsFixed(0)} kg',
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Commodity List Header ────────────────────────────────
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monthly Quota Entitlements', style: Theme.of(context).textTheme.titleLarge),
                        Text('Tap any commodity to claim or view details', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const Spacer(),
                    if (stats.pending > 0)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final tx = await ref.read(firebaseServiceProvider).claimAllPendingCommodities(uid);
                          if (context.mounted) {
                            _showReceiptDialog(context, tx);
                          }
                        },
                        icon: const Icon(Icons.done_all_rounded, size: 16),
                        label: const Text('Claim All'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Realtime Commodities List ────────────────────────────
                commoditiesAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return _buildEmptyState(context, ref, user, uid);
                    }
                    return Column(
                      children: items
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _showItemDetails(context, ref, c, uid),
                                  child: _CommodityTile(
                                    commodity: c,
                                    onClaim: () async {
                                      await ref.read(firebaseServiceProvider).claimCommodity(uid, c.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('✅ ${c.name} marked as collected in Firestore!'),
                                            backgroundColor: AppColors.secondary,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (e, _) => _buildEmptyState(context, ref, user, uid),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, RationUser? user, String uid) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'Monthly Quota Ready for Allocation',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'Click below to load authentic NFSA monthly quota commodities for this family card.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final cardType = user?.cardType ?? 'BPL';
              final famSize = user?.familySize ?? 4;
              await ref.read(firebaseServiceProvider).seedUserCommodities(uid, cardType, famSize);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🌾 Quota Commodities Loaded Successfully!'),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text('Seed Monthly Quota to Firestore'),
          ),
        ],
      ),
    );
  }
}

class _BplIdentityCard extends StatelessWidget {
  final RationUser? user;
  const _BplIdentityCard({this.user});

  @override
  Widget build(BuildContext context) {
    final cardType = user?.cardType ?? 'BPL';
    final isAay = cardType == 'AAY';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAay ? const [Color(0xFF5E3000), Color(0xFF8D4B00)] : const [Color(0xFF1B4332), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isAay ? const Color(0xFF5E3000) : const Color(0xFF1B4332)).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$cardType Smart Ration Card',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'National Food Security Act (NFSA)',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.qr_code_2_rounded, color: Colors.white70, size: 26),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARD NUMBER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.cardNumber ?? '4829-1092-8821',
                      style: GoogleFonts.robotoMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'FAMILY SIZE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.group_rounded, color: Color(0xFFDCEA94), size: 15),
                      const SizedBox(width: 4),
                      Text(
                        '${user?.familySize ?? 4} Members',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, color: Color(0xFFDCEA94), size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user?.shopName ?? 'Ganesh PDS Kendra #42',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                  ),
                ),
                Text(
                  'FPS Verified',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFDCEA94),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommodityTile extends StatelessWidget {
  final Commodity commodity;
  final VoidCallback? onClaim;

  const _CommodityTile({required this.commodity, this.onClaim});

  @override
  Widget build(BuildContext context) {
    final isCollected = commodity.status == EntitlementStatus.collected;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCollected ? const Color(0xFFC8E6C9) : AppColors.outlineVariant,
          width: isCollected ? 1.0 : 0.5,
        ),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isCollected ? AppColors.statusCollectedBg : AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _resolveIcon(commodity.icon),
              color: isCollected ? const Color(0xFF3B6B06) : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(commodity.name, style: Theme.of(context).textTheme.titleMedium),
                Text(commodity.localName, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  '₹${commodity.pricePerUnit.toStringAsFixed(commodity.pricePerUnit % 1 == 0 ? 0 : 2)}/${commodity.unit} • ${commodity.schemeNote}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${commodity.quantity.toStringAsFixed(commodity.quantity % 1 == 0 ? 0 : 1)} ${commodity.unit}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              _StatusChip(status: commodity.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final EntitlementStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case EntitlementStatus.collected:
        bg = AppColors.statusCollectedBg;
        fg = const Color(0xFF3B6B06);
        label = 'COLLECTED';
        icon = Icons.check_circle_rounded;
        break;
      case EntitlementStatus.pending:
        bg = AppColors.statusPendingBg;
        fg = AppColors.onSecondaryContainer;
        label = 'PENDING';
        icon = Icons.pending_rounded;
        break;
      case EntitlementStatus.available:
        bg = AppColors.statusAvailableBg;
        fg = AppColors.statusAvailableText;
        label = 'AVAILABLE';
        icon = Icons.inventory_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _resolveIcon(String name) {
  switch (name) {
    case 'grain':
      return Icons.grain_rounded;
    case 'grass':
      return Icons.grass_rounded;
    case 'nutrition':
      return Icons.restaurant_rounded;
    case 'cookie':
      return Icons.cookie_rounded;
    case 'spa':
      return Icons.spa_rounded;
    case 'water_drop':
      return Icons.water_drop_rounded;
    case 'science':
      return Icons.science_rounded;
    case 'oil_barrel':
      return Icons.propane_tank_rounded;
    default:
      return Icons.inventory_2_rounded;
  }
}
