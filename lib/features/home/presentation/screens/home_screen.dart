import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../shell/presentation/shell_screen.dart';
import '../../providers/home_providers.dart';
import '../widgets/quota_card.dart';
import '../widgets/shop_info_card.dart';
import '../widgets/notice_preview_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showNotificationCenter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _NotificationCenterSheet(),
    );
  }

  void _showBeneficiaryProfile(BuildContext context, WidgetRef ref, RationUser? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _BeneficiaryProfileSheet(user: user),
    );
  }

  void _showGrievanceDialog(BuildContext context, WidgetRef ref, RationUser? user) {
    final formKey = GlobalKey<FormState>();
    final descCtrl = TextEditingController();
    String selectedCategory = 'Under-weighing / Quantity Shortage';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
              Text('Report a Grievance', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17)),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your grievance will be directly routed to the Taluk Food Supply Officer for Fair Price Shop #42.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Grievance Category'),
                  items: const [
                    DropdownMenuItem(value: 'Under-weighing / Quantity Shortage', child: Text('Quantity Shortage')),
                    DropdownMenuItem(value: 'Substandard Foodgrain Quality', child: Text('Quality Issue')),
                    DropdownMenuItem(value: 'Overcharging above NFSA Price', child: Text('Overcharging')),
                    DropdownMenuItem(value: 'Shop Closed during working hours', child: Text('Shop Closed')),
                    DropdownMenuItem(value: 'Biometric / e-POS Machine Failure', child: Text('Biometric Failure')),
                  ],
                  onChanged: (v) => setState(() => selectedCategory = v ?? selectedCategory),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Incident Description',
                    hintText: 'Describe what occurred (e.g. rice quantity was 2kg short)...',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please provide details' : null,
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
                final service = ref.read(firebaseServiceProvider);
                final u = user ?? ref.read(currentUserProfileProvider).valueOrNull ?? ref.read(activeUserSessionProvider);
                final userId = u?.uid ?? 'user_bpl_default';
                final userName = u?.name ?? 'Ramesh Kumar';
                final cardNum = u?.cardNumber ?? '4829-1092-8821';
                final shopId = u?.shopId ?? 'shop_42';
                final shopName = u?.shopName ?? 'Ganesh Fair Price Shop #42';

                final ticketId = await service.fileGrievance(
                  userId: userId,
                  userName: userName,
                  cardNumber: cardNum,
                  shopId: shopId,
                  shopName: shopName,
                  category: selectedCategory,
                  description: descCtrl.text.trim(),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Grievance ticket #${ticketId.substring(0, 8).toUpperCase()} lodged with Taluk Supply Office.'),
                      backgroundColor: AppColors.secondary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
              child: const Text('Submit Ticket'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionsDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _TransactionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final stats = ref.watch(entitlementStatsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black12,
            title: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: AppColors.onPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Civic Harvest',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Realtime PDS Portal',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Notification center
              IconButton(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  backgroundColor: AppColors.error,
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => _showNotificationCenter(context, ref),
              ),
              // Profile button
              IconButton(
                icon: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondaryContainer, width: 1.5),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppColors.onPrimary, size: 20),
                ),
                onPressed: () => _showBeneficiaryProfile(context, ref, userAsync.valueOrNull),
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 12),

                // ── Greeting Row ─────────────────────────────────────────
                userAsync.when(
                  data: (user) => _GreetingRow(user: user),
                  loading: () => const _GreetingRow(user: null),
                  error: (_, _) => const _GreetingRow(user: null),
                ),
                const SizedBox(height: 16),

                // ── Quick Action Buttons Row ─────────────────────────────
                Row(
                  children: [
                    _QuickActionTile(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Digital Pass',
                      color: AppColors.primary,
                      onTap: () {
                        final u = userAsync.valueOrNull ?? ref.read(currentUserProfileProvider).valueOrNull ?? ref.read(activeUserSessionProvider);
                        if (u != null) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => _DigitalPassSheetModal(user: u),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _QuickActionTile(
                      icon: Icons.inventory_2_rounded,
                      label: 'Shop Stock',
                      color: AppColors.secondary,
                      onTap: () {
                        // Switch to Shop Tab (index 2)
                        ref.read(shellSelectedIndexProvider.notifier).state = 2;
                      },
                    ),
                    const SizedBox(width: 8),
                    _QuickActionTile(
                      icon: Icons.support_agent_rounded,
                      label: 'Grievance',
                      color: const Color(0xFFD97706),
                      onTap: () => _showGrievanceDialog(context, ref, userAsync.valueOrNull),
                    ),
                    const SizedBox(width: 8),
                    _QuickActionTile(
                      icon: Icons.receipt_long_rounded,
                      label: 'Receipts',
                      color: const Color(0xFF6B21A8),
                      onTap: () => _showTransactionsDialog(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Quota Card ───────────────────────────────────────────
                QuotaCard(
                  month: DateFormat('MMMM yyyy').format(DateTime.now()),
                  collected: stats.collected,
                  total: stats.total,
                  user: userAsync.valueOrNull,
                ),
                const SizedBox(height: 16),

                // ── Shop Info Card ───────────────────────────────────────
                userAsync.when(
                  data: (user) => ShopInfoCard(user: user),
                  loading: () => const ShopInfoCard(user: null),
                  error: (_, _) => const ShopInfoCard(user: null),
                ),
                const SizedBox(height: 16),

                // ── Latest Notice Preview ─────────────────────────────────
                const NoticePreviewCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingRow extends StatelessWidget {
  final RationUser? user;
  const _GreetingRow({this.user});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: AppColors.secondary, size: 14),
            const SizedBox(width: 4),
            Text(
              user?.cardType != null ? '${user!.cardType} Beneficiary (NFSA)' : 'BPL Beneficiary (NFSA)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.statusAvailableBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'e-KYC Verified',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.statusAvailableText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '$greeting, ${user?.name ?? 'Ramesh Kumar'}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        Text(
          'Card No: ${user?.cardNumber ?? '4829-1092-8821'} • Family: ${user?.familySize ?? 4} Members',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineVariant, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Notification Center Sheet ───────────────────────────────────────────────

class _NotificationCenterSheet extends ConsumerWidget {
  const _NotificationCenterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final user = ref.watch(currentUserProfileProvider).valueOrNull ?? ref.watch(activeUserSessionProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      height: 480,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Notification Center',
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (user != null)
                TextButton(
                  onPressed: () {
                    ref.read(firebaseServiceProvider).markAllNotificationsRead(user.uid);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications marked as read.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Mark all read'),
                ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: notificationsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.outline),
                        const SizedBox(height: 8),
                        Text('No new notifications', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                        Text('You will receive quota alerts here.', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.isRead ? AppColors.surfaceContainerHigh : AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.type == 'quota' ? Icons.check_circle_rounded : Icons.notifications_rounded,
                          color: item.isRead ? AppColors.outline : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.body, style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('d MMM, h:mm a').format(item.timestamp),
                            style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline),
                          ),
                        ],
                      ),
                      onTap: () {
                        if (user != null && !item.isRead) {
                          ref.read(firebaseServiceProvider).markNotificationRead(user.uid, item.id);
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (_, _) => const Center(child: Text('Unable to load notifications')),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Beneficiary Profile Modal Sheet ─────────────────────────────────────────

class _BeneficiaryProfileSheet extends ConsumerWidget {
  final RationUser? user;
  const _BeneficiaryProfileSheet({this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeUser = user ?? ref.watch(currentUserProfileProvider).valueOrNull ?? ref.watch(activeUserSessionProvider);

    if (activeUser == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      height: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.badge_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activeUser.name, style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800)),
                    Text('NFSA ID: ${activeUser.nfsaId}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${activeUser.cardType} CARD',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Family Members (${activeUser.familyMembers.length})',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _showAddMemberDialog(context, ref, activeUser.uid),
                        icon: const Icon(Icons.person_add_rounded, size: 16),
                        label: const Text('Add Member'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (activeUser.familyMembers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
                      ),
                      child: Row(children: [
                        const Icon(Icons.group_outlined, size: 22, color: AppColors.outline),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No family members added yet.\nTap "Add Member" to register each family member.',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.5),
                          ),
                        ),
                      ]),
                    )
                  else
                    ...activeUser.familyMembers.asMap().entries.map(
                      (entry) {
                        final i = entry.key;
                        final m = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(children: [
                            const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(m.name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                                Text('${m.relation} • ${m.age} yrs', style: Theme.of(context).textTheme.bodySmall),
                              ]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: AppColors.error),
                              onPressed: () async {
                                await ref.read(firebaseServiceProvider).removeFamilyMember(activeUser.uid, i);
                              },
                              tooltip: 'Remove member',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ]),
                        );
                      },
                    ),

                  const SizedBox(height: 16),
                  Text('Database & Demo Tools', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),

                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(firebaseServiceProvider).resetMonthlyQuota(activeUser.uid);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('🔄 Quota reset to Available for testing.'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ));
                          }
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Reset Quota'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(firebaseServiceProvider).seedUserCommodities(activeUser.uid, activeUser.cardType, activeUser.familySize);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('🌾 Re-seeded commodities in Firestore.'),
                              backgroundColor: AppColors.secondary,
                              behavior: SnackBarBehavior.floating,
                            ));
                          }
                        },
                        icon: const Icon(Icons.cloud_download_rounded, size: 16),
                        label: const Text('Re-Seed DB'),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref, String uid) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String relation = 'Spouse';
    bool isAadhaarVerified = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_add_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Add Family Member',
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Member will be registered on your NFSA ration entitlement.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'e.g. Priya Sharma',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: relation,
                        decoration: const InputDecoration(
                          labelText: 'Relationship',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: ['Spouse', 'Son', 'Daughter', 'Mother', 'Father', 'Brother', 'Sister', 'Other']
                            .map((r) => DropdownMenuItem(value: r, child: Text(r, style: GoogleFonts.plusJakartaSans(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => relation = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          hintText: '25',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Aadhaar e-KYC Verified',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Enables biometric collection for this member',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                  value: isAadhaarVerified,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) => setDialogState(() => isAadhaarVerified = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final age = int.tryParse(ageController.text.trim()) ?? 0;
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter member name')),
                  );
                  return;
                }
                Navigator.pop(dialogCtx);
                final newMember = FamilyMember(
                  name: name,
                  age: age,
                  relation: relation,
                  isAadhaarVerified: isAadhaarVerified,
                );
                await ref.read(firebaseServiceProvider).addFamilyMember(uid, newMember);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ $name added to family ration card.'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Digital Pass Sheet Modal ────────────────────────────────────────────────

class _DigitalPassSheetModal extends StatelessWidget {
  final RationUser user;
  const _DigitalPassSheetModal({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(99)),
          ),
          const SizedBox(height: 16),
          Text(
            'Beneficiary Digital Pass',
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Scan on Fair Price Shop e-POS Biometric Reader',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 140, color: AppColors.primary),
                Text(user.cardNumber, style: GoogleFonts.robotoMono(fontSize: 13, fontWeight: FontWeight.w700)),
                Text('${user.name} (${user.cardType})', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// ─── Past Transactions Sheet ─────────────────────────────────────────────────

class _TransactionsSheet extends ConsumerWidget {
  const _TransactionsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(userTransactionsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      height: 480,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Ration Collection Receipts',
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          Expanded(
            child: txAsync.when(
              data: (txList) {
                if (txList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_outlined, size: 48, color: AppColors.outline),
                        const SizedBox(height: 8),
                        Text('No receipts logged yet', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
                        Text('Claim quota items to generate e-receipts.', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: txList.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final tx = txList[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.statusCollectedBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.check_rounded, color: Color(0xFF3B6B06), size: 22),
                      ),
                      title: Text(tx.receiptNo, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        '${tx.itemNames.join(", ")} • ${tx.totalQuantityKg.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${tx.totalAmount.toStringAsFixed(2)}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
                          Text(DateFormat('d MMM yyyy').format(tx.date), style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (_, _) => const Center(child: Text('Unable to load transactions')),
            ),
          ),
        ],
      ),
    );
  }
}
