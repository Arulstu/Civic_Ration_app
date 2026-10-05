import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ── Beneficiary Sign In ──────────────────────────────────────────────────────
  final _signInFormKey = GlobalKey<FormState>();
  final _signInEmailCtrl =
      TextEditingController(text: 'bpl.beneficiary@ration.gov.in');
  final _signInPassCtrl = TextEditingController(text: 'PdsDemo@2026');
  bool _obscureSignInPass = true;

  // ── Beneficiary Sign Up ──────────────────────────────────────────────────────
  final _signUpFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _signUpEmailCtrl = TextEditingController();
  final _signUpPassCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  int _familySize = 1;
  String _selectedCardType = 'BPL';
  bool _obscureSignUpPass = true;

  // ── Shopkeeper ───────────────────────────────────────────────────────────────
  final _shopFormKey = GlobalKey<FormState>();
  final _shopCodeCtrl = TextEditingController();
  final _shopPinCtrl = TextEditingController();
  bool _obscureShopPin = true;

  // 0 = beneficiary, 1 = shopkeeper
  int _portalIndex = 0;
  // 0 = sign in, 1 = register
  int _authMode = 0;

  @override
  void dispose() {
    _signInEmailCtrl.dispose();
    _signInPassCtrl.dispose();
    _nameCtrl.dispose();
    _signUpEmailCtrl.dispose();
    _signUpPassCtrl.dispose();
    _cardNumberCtrl.dispose();
    _phoneCtrl.dispose();
    _shopCodeCtrl.dispose();
    _shopPinCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_signInFormKey.currentState!.validate()) return;
    final success = await ref.read(authControllerProvider.notifier).signIn(
          _signInEmailCtrl.text.trim(),
          _signInPassCtrl.text,
        );
    if (!success && mounted) {
      final error = ref.read(authControllerProvider).errorMessage;
      if (error != null) _showError(error);
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;
    final success = await ref.read(authControllerProvider.notifier).signUp(
          email: _signUpEmailCtrl.text.trim(),
          password: _signUpPassCtrl.text,
          name: _nameCtrl.text.trim(),
          cardType: _selectedCardType,
          cardNumber: _cardNumberCtrl.text.trim().isNotEmpty
              ? _cardNumberCtrl.text.trim()
              : '4829-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}-8821',
          familySize: _familySize,
          phone: _phoneCtrl.text.trim(),
        );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Account created! Welcome to Civic Harvest.'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ));
    } else if (mounted) {
      final error = ref.read(authControllerProvider).errorMessage;
      if (error != null) _showError(error);
    }
  }

  Future<void> _handleShopkeeperSignIn() async {
    if (!_shopFormKey.currentState!.validate()) return;
    final success =
        await ref.read(authControllerProvider.notifier).shopkeeperSignIn(
              _shopCodeCtrl.text.trim(),
              _shopPinCtrl.text,
            );
    if (!success && mounted) {
      final error = ref.read(authControllerProvider).errorMessage;
      if (error != null) _showError(error);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController(text: _signInEmailCtrl.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Reset Password',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700, fontSize: 18)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Enter your registered email and we will send a reset link.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Beneficiary Email',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(authControllerProvider.notifier)
                  .sendPasswordReset(emailCtrl.text);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 44)),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: AppColors.onPrimary, size: 28),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Civic Harvest',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface),
                  ),
                  Text(
                    'National Food Security Digital Portal',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500),
                  ),
                ]),
              ]),
              const SizedBox(height: 20),

              // ── Portal Switcher ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  _PortalTab(
                    label: 'Beneficiary',
                    icon: Icons.person_rounded,
                    isActive: _portalIndex == 0,
                    onTap: () => setState(() => _portalIndex = 0),
                  ),
                  _PortalTab(
                    label: 'Shopkeeper',
                    icon: Icons.storefront_rounded,
                    isActive: _portalIndex == 1,
                    onTap: () => setState(() => _portalIndex = 1),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // ── Error Banner ─────────────────────────────────────────────────
              if (authState.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(authState.errorMessage!,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w500)),
                    ),
                  ]),
                ),

              // ── Portal Content ───────────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _portalIndex == 0
                    ? _buildBeneficiaryPortal(authState, screenHeight)
                    : _buildShopkeeperPortal(authState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // BENEFICIARY PORTAL
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildBeneficiaryPortal(AuthState authState, double screenHeight) {
    return Column(
      key: const ValueKey('beneficiary'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trust banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.verified_user_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('e-PDS Beneficiary Portal',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text('Manage your monthly quota & entitlements',
                        style:
                            GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // Quick Demo buttons
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineVariant, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 6),
                Text('Quick Demo Login',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref
                            .read(authControllerProvider.notifier)
                            .quickDemoLogin(cardType: 'BPL'),
                    icon: const Icon(Icons.person_rounded, size: 15),
                    label: const Text('BPL – Ramesh'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref
                            .read(authControllerProvider.notifier)
                            .quickDemoLogin(cardType: 'AAY'),
                    icon: const Icon(Icons.stars_rounded,
                        size: 15, color: Color(0xFFD97706)),
                    label: const Text('AAY – Shanti'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Sign In / Register tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            _PortalTab(
              label: 'Sign In',
              icon: Icons.login_rounded,
              isActive: _authMode == 0,
              onTap: () => setState(() => _authMode = 0),
            ),
            _PortalTab(
              label: 'Register',
              icon: Icons.person_add_rounded,
              isActive: _authMode == 1,
              onTap: () => setState(() => _authMode = 1),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _authMode == 0
              ? _buildSignInTab(authState)
              : _buildSignUpTab(authState),
        ),
      ],
    );
  }

  Widget _buildSignInTab(AuthState authState) {
    return Form(
      key: _signInFormKey,
      child: Column(
        key: const ValueKey('sign_in_tab'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          TextFormField(
            controller: _signInEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email or NFSA ID',
              hintText: 'e.g. bpl.beneficiary@ration.gov.in',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter email' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _signInPassCtrl,
            obscureText: _obscureSignInPass,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscureSignInPass
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded),
                onPressed: () =>
                    setState(() => _obscureSignInPass = !_obscureSignInPass),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text('Forgot Password?',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
          ),
          authState.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : ElevatedButton(
                  onPressed: _handleSignIn,
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Sign In to Dashboard'),
                      ]),
                ),
          const SizedBox(height: 20),
          Center(
            child: Text('Govt. of India • Public Distribution System (e-PDS)',
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.outline)),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpTab(AuthState authState) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        key: const ValueKey('sign_up_tab'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Head of Family Name',
              hintText: 'e.g. Ramesh Kumar',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter name' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _signUpEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Enter valid email' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _signUpPassCtrl,
            obscureText: _obscureSignUpPass,
            decoration: InputDecoration(
              labelText: 'Create Password (min 6 chars)',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(_obscureSignUpPass
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded),
                onPressed: () =>
                    setState(() => _obscureSignUpPass = !_obscureSignUpPass),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCardType,
                decoration: const InputDecoration(
                  labelText: 'Card Scheme',
                  prefixIcon: Icon(Icons.card_membership_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'BPL', child: Text('BPL (Yellow)')),
                  DropdownMenuItem(
                      value: 'AAY', child: Text('AAY (Antyodaya)')),
                  DropdownMenuItem(
                      value: 'PHH', child: Text('PHH (Priority)')),
                  DropdownMenuItem(value: 'APL', child: Text('APL (White)')),
                ],
                onChanged: (v) =>
                    setState(() => _selectedCardType = v ?? 'BPL'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<int>(
                initialValue: _familySize,
                decoration: const InputDecoration(
                  labelText: 'Family',
                  prefixIcon: Icon(Icons.group_rounded),
                ),
                items: List.generate(
                    8, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                onChanged: (v) => setState(() => _familySize = v ?? 1),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          TextFormField(
            controller: _cardNumberCtrl,
            decoration: const InputDecoration(
              labelText: 'Ration Card Number (Optional)',
              hintText: 'e.g. 4829-1092-8821',
              prefixIcon: Icon(Icons.credit_card_rounded),
            ),
          ),
          const SizedBox(height: 4),
          // Family size note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Family members can be added individually from the Home screen after registration.',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          authState.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : ElevatedButton(
                  onPressed: _handleSignUp,
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.how_to_reg_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Register & Create Account'),
                      ]),
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SHOPKEEPER PORTAL
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildShopkeeperPortal(AuthState authState) {
    return Column(
      key: const ValueKey('shopkeeper'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shopkeeper banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF283593)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.store_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FPS Dealer / Shopkeeper Portal',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(
                        'Post notices & announcements for your assigned beneficiaries',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.white70)),
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // Permissions info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBCBFF), width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shopkeeper Access',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A237E))),
              const SizedBox(height: 6),
              _PermissionRow(icon: Icons.check_circle_rounded,
                  color: const Color(0xFF2E7D32), text: 'Post stock & scheme notices'),
              _PermissionRow(icon: Icons.check_circle_rounded,
                  color: const Color(0xFF2E7D32), text: 'Publish urgent alerts'),
              _PermissionRow(icon: Icons.cancel_rounded,
                  color: AppColors.error, text: 'Cannot view beneficiary quota'),
              _PermissionRow(icon: Icons.cancel_rounded,
                  color: AppColors.error, text: 'Cannot access entitlement data'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Form(
          key: _shopFormKey,
          child: Column(children: [
            const SizedBox(height: 4),
            TextFormField(
              controller: _shopCodeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Shop Code / FPS ID',
                hintText: 'e.g. FPS-429',
                prefixIcon: Icon(Icons.storefront_rounded),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your FPS shop code' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _shopPinCtrl,
              obscureText: _obscureShopPin,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Shop PIN (min 4 digits)',
                hintText: 'e.g. 1234',
                prefixIcon: const Icon(Icons.pin_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_obscureShopPin
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded),
                  onPressed: () =>
                      setState(() => _obscureShopPin = !_obscureShopPin),
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 4) ? 'PIN must be at least 4 digits' : null,
            ),
            const SizedBox(height: 20),
            authState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : ElevatedButton(
                    onPressed: _handleShopkeeperSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                    ),
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Access Notice Board'),
                        ]),
                  ),
            const SizedBox(height: 10),
            // Quick demo
            OutlinedButton.icon(
              onPressed: authState.isLoading
                  ? null
                  : () {
                      _shopCodeCtrl.text = 'FPS-429';
                      _shopPinCtrl.text = '1234';
                      _handleShopkeeperSignIn();
                    },
              icon: const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFD97706)),
              label: const Text('Demo: FPS-429 Shop Login'),
              style: OutlinedButton.styleFrom(
                textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _PortalTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _PortalTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                size: 16,
                color: isActive ? Colors.white : AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _PermissionRow(
      {required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(text,
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.onSurfaceVariant)),
      ]),
    );
  }
}
