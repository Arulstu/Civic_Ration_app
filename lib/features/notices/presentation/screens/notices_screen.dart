import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../shell/presentation/shell_screen.dart';
import '../../providers/notices_provider.dart';

class NoticesScreen extends ConsumerWidget {
  /// When [isShopkeeper] is true the FAB to post notices is always shown
  /// and the bottom-nav "Jump to Quota" action is hidden.
  final bool isShopkeeper;

  const NoticesScreen({super.key, this.isShopkeeper = false});

  void _showCreateNoticeDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final extraLabelCtrl = TextEditingController();
    final extraValCtrl = TextEditingController();
    String category = 'stock';
    bool isUrgent = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.campaign_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Text('Publish Notice',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, fontSize: 17)),
          ]),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notice Title',
                    hintText: 'e.g. Fresh Wheat Consignment Arrived',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter title' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration:
                      const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(
                        value: 'stock', child: Text('Stock Arrival')),
                    DropdownMenuItem(
                        value: 'timings',
                        child: Text('Shop Timings / Holiday')),
                    DropdownMenuItem(
                        value: 'schemes',
                        child: Text('Government Scheme')),
                    DropdownMenuItem(
                        value: 'alerts', child: Text('Urgent Alert')),
                  ],
                  onChanged: (v) =>
                      setModalState(() => category = v ?? 'stock'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: bodyCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Announcement Details'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter details' : null,
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: extraLabelCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Tag Label',
                          hintText: 'e.g. Quantity'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: extraValCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Tag Value',
                          hintText: 'e.g. 500 Bags'),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Priority / Urgent Announcement',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  value: isUrgent,
                  onChanged: (v) => setModalState(() => isUrgent = v),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                final notice = CommunityNotice(
                  id: 'n_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  body: bodyCtrl.text.trim(),
                  category: category,
                  date: DateTime.now(),
                  isUrgent: isUrgent,
                  extraLabel: extraLabelCtrl.text.trim().isNotEmpty
                      ? extraLabelCtrl.text.trim()
                      : null,
                  extraValue: extraValCtrl.text.trim().isNotEmpty
                      ? extraValCtrl.text.trim()
                      : null,
                  actionLabel: category == 'stock'
                      ? 'View Details'
                      : (category == 'timings'
                          ? 'Set Reminder'
                          : 'Read Directive'),
                  actionType: category == 'stock'
                      ? 'directive'
                      : (category == 'timings' ? 'reminder' : 'directive'),
                );

                await ref.read(firebaseServiceProvider).postNotice(notice);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('📢 Notice published to community feed!'),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
              child: const Text('Publish Live'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDirectiveDialog(BuildContext context, CommunityNotice notice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.account_balance_rounded,
              color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text('Govt Directive Memo',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notice.title,
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              Text(notice.body,
                  style: Theme.of(ctx)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.4)),
              const Divider(height: 20),
              Row(children: [
                const Icon(Icons.verified_rounded,
                    color: Color(0xFF2E7D32), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                      'Verified by Ministry of Consumer Affairs & PDS',
                      style: GoogleFonts.inter(
                          fontSize: 10, color: AppColors.outline)),
                ),
              ]),
            ]),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Understood')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(noticeFilterProvider);
    final filteredAsync = ref.watch(filteredNoticesProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      // Only shopkeepers can post notices
      floatingActionButton: isShopkeeper
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateNoticeDialog(context, ref),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_comment_rounded),
              label: Text('Post Notice',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700)),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            title: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.campaign_rounded,
                    color: AppColors.onPrimary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                isShopkeeper
                    ? 'Notice Board – Post Announcements'
                    : 'Community Notice Board',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface),
              ),
            ]),
          ),

          // ── Status row ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'FPS Kendra #42 • Live Feed',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.onSurfaceVariant),
                ),
                const Spacer(),
                if (isShopkeeper)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(children: [
                      const Icon(Icons.store_rounded,
                          size: 12, color: Color(0xFF1A237E)),
                      const SizedBox(width: 4),
                      Text('Shopkeeper Mode',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A237E))),
                    ]),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(children: [
                      const Icon(Icons.verified_rounded,
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Official Feed',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ),
              ]),
            ),
          ),

          // ── Filter pills ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _FilterPill(
                      label: 'All',
                      icon: Icons.all_inbox_rounded,
                      value: 'all',
                      selected: filter,
                      onTap: () => ref
                          .read(noticeFilterProvider.notifier)
                          .state = 'all'),
                  const SizedBox(width: 6),
                  _FilterPill(
                      label: 'Stock',
                      icon: Icons.inventory_rounded,
                      value: 'stock',
                      selected: filter,
                      onTap: () => ref
                          .read(noticeFilterProvider.notifier)
                          .state = 'stock'),
                  const SizedBox(width: 6),
                  _FilterPill(
                      label: 'Timings',
                      icon: Icons.schedule_rounded,
                      value: 'timings',
                      selected: filter,
                      onTap: () => ref
                          .read(noticeFilterProvider.notifier)
                          .state = 'timings'),
                  const SizedBox(width: 6),
                  _FilterPill(
                      label: 'Govt Schemes',
                      icon: Icons.account_balance_rounded,
                      value: 'schemes',
                      selected: filter,
                      onTap: () => ref
                          .read(noticeFilterProvider.notifier)
                          .state = 'schemes'),
                  const SizedBox(width: 6),
                  _FilterPill(
                      label: 'Priority',
                      icon: Icons.warning_rounded,
                      value: 'urgent',
                      selected: filter,
                      onTap: () => ref
                          .read(noticeFilterProvider.notifier)
                          .state = 'urgent'),
                ]),
              ),
            ),
          ),

          // ── Notice cards ─────────────────────────────────────────────────
          filteredAsync.when(
            data: (notices) {
              if (notices.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Column(children: [
                        const Icon(Icons.campaign_outlined,
                            size: 48, color: AppColors.outline),
                        const SizedBox(height: 10),
                        Text('No announcements in this category',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700)),
                        if (isShopkeeper) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showCreateNoticeDialog(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('Post First Notice'),
                          ),
                        ],
                      ]),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(16, 4, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final notice = notices[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _NoticeCard(
                          notice: notice,
                          isShopkeeper: isShopkeeper,
                          onActionTap: isShopkeeper
                              ? null
                              : () {
                                  if (notice.actionType == 'reminder' ||
                                      notice.category == 'timings') {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          '⏰ Reminder saved!'),
                                      behavior:
                                          SnackBarBehavior.floating,
                                    ));
                                  } else if (notice.actionType ==
                                          'quota' ||
                                      notice.category == 'stock') {
                                    ref
                                        .read(shellSelectedIndexProvider
                                            .notifier)
                                        .state = 1;
                                  } else {
                                    _showDirectiveDialog(
                                        context, notice);
                                  }
                                },
                        ),
                      );
                    },
                    childCount: notices.length,
                  ),
                ),
              );
            },
            loading: () => const SliverPadding(
              padding: EdgeInsets.all(32),
              sliver: SliverToBoxAdapter(
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary)),
              ),
            ),
            error: (e, _) => const SliverPadding(
              padding: EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Center(child: Text('Notice feed active')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Pill ─────────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(children: [
          Icon(icon,
              size: 14,
              color: isActive
                  ? AppColors.onPrimary
                  : AppColors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? AppColors.onPrimary
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Notice Card (no audio) ───────────────────────────────────────────────────
class _NoticeCard extends StatelessWidget {
  final CommunityNotice notice;
  final bool isShopkeeper;
  final VoidCallback? onActionTap;

  const _NoticeCard({
    required this.notice,
    required this.isShopkeeper,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final (chipBg, chipFg, chipLabel) = _categoryStyle(notice.category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: chipBg, borderRadius: BorderRadius.circular(99)),
            child: Row(children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                    color: chipFg, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(chipLabel,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: chipFg)),
            ]),
          ),
          if (notice.isUrgent) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.statusLowStockBg,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text('URGENT',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.statusLowStockText)),
            ),
          ],
          const Spacer(),
          Row(children: [
            const Icon(Icons.calendar_today_rounded,
                size: 12, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 3),
            Text(DateFormat('d MMM yyyy').format(notice.date),
                style: Theme.of(context).textTheme.labelSmall),
          ]),
        ]),

        const SizedBox(height: 10),

        // Title & body
        Text(notice.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(notice.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant, height: 1.5)),

        // Extra tag
        if (notice.extraLabel != null && notice.extraValue != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Text(notice.extraLabel!,
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                Text(notice.extraValue!,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface)),
              ]),
            ),
          ),

        const SizedBox(height: 12),

        // Footer — beneficiaries get an action button, shopkeepers see "Posted by FPS"
        if (!isShopkeeper && onActionTap != null)
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onActionTap,
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                minimumSize: Size.zero,
                foregroundColor: AppColors.primary,
                textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(notice.actionLabel),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 13),
              ]),
            ),
          )
        else if (isShopkeeper)
          Row(children: [
            const Icon(Icons.store_rounded,
                size: 13, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text('Posted by FPS Dealer',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.onSurfaceVariant)),
          ]),
      ]),
    );
  }
}

(Color, Color, String) _categoryStyle(String category) {
  switch (category.toLowerCase()) {
    case 'stock':
      return (AppColors.statusAvailableBg, AppColors.statusAvailableText,
          'STOCK ARRIVAL');
    case 'timings':
      return (const Color(0xFFEDE7F6), const Color(0xFF5E35B1),
          'TIMINGS / HOLIDAY');
    case 'schemes':
      return (AppColors.secondaryContainer, AppColors.primary, 'GOVT SCHEME');
    case 'alerts':
    case 'urgent':
      return (AppColors.statusLowStockBg, AppColors.statusLowStockText,
          'PRIORITY ALERT');
    default:
      return (AppColors.surfaceContainerHigh, AppColors.onSurfaceVariant,
          'ANNOUNCEMENT');
  }
}
