import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/models.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/home_providers.dart';

class QuotaCard extends ConsumerWidget {
  final String month;
  final int collected;
  final int total;
  final RationUser? user;
  final VoidCallback? onClaimTap;

  const QuotaCard({
    super.key,
    required this.month,
    required this.collected,
    required this.total,
    this.user,
    this.onClaimTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = total > 0 ? (collected / total) : 0.0;
    final remaining = (total - collected).clamp(0, 99);
    final activeUser = user ?? ref.watch(currentUserProfileProvider).valueOrNull ?? ref.watch(activeUserSessionProvider);
    final cardType = activeUser?.cardType ?? 'BPL';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF24553F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Tag ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: Color(0xFFDCEA94), size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '$cardType BENEFICIARY QUOTA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCEA94),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live Cloud',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Month Title ─────────────────────────────────────────────────
          Text(
            '$month Allocation',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // ── Stats Row ───────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collected Ration Items',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$collected ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: '/ $total Items (${(progress * 100).toStringAsFixed(0)}%)',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Quick action button
              ElevatedButton.icon(
                onPressed: () => _handleClaimOrPass(context, ref, activeUser),
                icon: const Icon(Icons.qr_code_rounded, size: 16),
                label: Text(remaining > 0 ? 'Claim / QR' : 'e-Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDCEA94),
                  foregroundColor: const Color(0xFF1B4332),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Progress Bar ─────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFDCEA94)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progress >= 1.0 ? '✓ 100% Fully Collected' : '$remaining items pending this month',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              Text(
                activeUser?.shopName ?? 'FPS Kendra #42',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleClaimOrPass(BuildContext context, WidgetRef ref, RationUser? activeUser) {
    final userToUse = activeUser ?? ref.read(currentUserProfileProvider).valueOrNull ?? ref.read(activeUserSessionProvider);
    if (userToUse == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DigitalPassSheet(user: userToUse),
    );
  }
}

class _DigitalPassSheet extends ConsumerWidget {
  final RationUser user;
  const _DigitalPassSheet({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(entitlementStatsProvider);

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
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF1B4332), size: 24),
              const SizedBox(width: 10),
              Text(
                'Digital e-POS Verification Pass',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B4332),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Present this QR code at Fair Price Shop #42 or authenticate with biometric fingerprint to collect monthly foodgrains.',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          // QR Code Container
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Column(
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 130, color: Color(0xFF1B4332)),
                        Text(
                          user.cardNumber,
                          style: GoogleFonts.robotoMono(fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Beneficiary: ${user.name}',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  'NFSA ID: ${user.nfsaId} • Scheme: ${user.cardType}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Instant Claim Button
          if (stats.pending > 0)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final tx = await ref.read(firebaseServiceProvider).claimAllPendingCommodities(user.uid);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 All Quota Collected! Receipt #${tx.receiptNo} generated.'),
                      backgroundColor: const Color(0xFF2D6A4F),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: Text('Simulate e-POS Claim All (${stats.pending} Items)'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                backgroundColor: const Color(0xFF1B4332),
                foregroundColor: Colors.white,
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 42)),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
