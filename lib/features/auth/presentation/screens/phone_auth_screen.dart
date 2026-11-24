import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/obsidian_card.dart';
import '../viewmodels/auth_viewmodel.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isValidPhone = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    final text = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final isValid = text.length == 10;
    if (isValid != _isValidPhone) {
      setState(() => _isValidPhone = isValid);
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitPhone() {
    if (!_isValidPhone) return;
    HapticFeedback.lightImpact();
    final cleanPhone = '+91${_phoneController.text.trim()}';
    final name = _nameController.text.trim();
    final displayName = name.isNotEmpty ? name : 'Hungr Foodie';

    ref.read(authProvider.notifier).requestOtp(
      phone: cleanPhone,
      name: displayName,
      onSuccess: () {
        if (!mounted) return;
        context.push(RouteNames.otpVerify, extra: {
          'phone': cleanPhone,
          'name': displayName,
        });
      },
      onError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1F2937),
            content: Text(
              '$error (Proceeding to verification screen)',
              style: AppTypography.labelLarge.copyWith(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );

        // Fail-safe transition so user or Play Store reviewer is never blocked
        context.push(RouteNames.otpVerify, extra: {
          'phone': cleanPhone,
          'name': displayName,
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textCrispWhite, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Official Sunset-Red 'H' Emblem
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.zomatoRedGlow.withOpacity(0.6),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/icons/app_icon_512.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 450.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // Title & Welcome Copy
              Text(
                'Welcome to Hungr',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 8),

              Text(
                'Fresh, piping-hot tiffin delivered straight to your hostel or apartment gate every morning.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMutedSlate,
                  height: 1.45,
                ),
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms),

              const SizedBox(height: 28),

              // Unified Modern Credentials Card (Zero nested box clutter)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isValidPhone ? AppColors.zomatoRed.withOpacity(0.5) : const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isValidPhone
                          ? AppColors.zomatoRedGlow.withOpacity(0.12)
                          : const Color(0x08000000),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1: Full Name
                    Text(
                      'FULL NAME',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your name',
                                hintStyle: AppTypography.titleMedium.copyWith(
                                  color: AppColors.textSubtle.withOpacity(0.6),
                                  fontWeight: FontWeight.normal,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Field 2: Mobile Number
                    Text(
                      'MOBILE NUMBER',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isValidPhone ? AppColors.zomatoRed : const Color(0xFFE5E7EB),
                          width: _isValidPhone ? 1.5 : 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          // Country Flag + Code
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 6),
                              Text(
                                '+91',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 24,
                            width: 1,
                            color: const Color(0xFFD1D5DB),
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          // Phone Number Input
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: AppTypography.titleLarge.copyWith(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: '10-digit number',
                                hintStyle: AppTypography.titleMedium.copyWith(
                                  color: AppColors.textSubtle.withOpacity(0.6),
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.normal,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onSubmitted: (_) => _submitPhone(),
                            ),
                          ),
                          if (_isValidPhone)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded, color: Color(0xFF16A34A), size: 16),
                            ).animate().scale(duration: 200.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.08, end: 0),

              const SizedBox(height: 20),

              // Primary CTA Button
              Consumer(
                builder: (context, ref, _) {
                  final authState = ref.watch(authProvider);
                  final isBusy = authState.isLoading;

                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_isValidPhone && !isBusy) ? AppColors.zomatoRed : const Color(0xFFE5E7EB),
                        foregroundColor: (_isValidPhone && !isBusy) ? Colors.white : AppColors.textSubtle,
                        elevation: (_isValidPhone && !isBusy) ? 4 : 0,
                        shadowColor: AppColors.zomatoRedGlow,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppDimensions.radius16,
                        ),
                      ),
                      onPressed: (_isValidPhone && !isBusy) ? _submitPhone : null,
                      child: isBusy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Get Verification Code',
                                  style: AppTypography.labelLarge.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                    color: _isValidPhone ? Colors.white : AppColors.textSubtle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: _isValidPhone ? Colors.white : AppColors.textSubtle,
                                ),
                              ],
                            ),
                    ),
                  );
                },
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms),

              const SizedBox(height: 14),

              // Instant Preview for Testers & Fast Exploration
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    final name = _nameController.text.trim();
                    ref.read(authProvider.notifier).login(
                          phone: '+91 98765 43210',
                          name: name.isNotEmpty ? name : 'Hungr Foodie',
                        );
                    context.go(RouteNames.storefront);
                  },
                  icon: const Icon(Icons.bolt_rounded, size: 18, color: AppColors.goldenAmber),
                  label: Text(
                    'Instant Preview • Explore Live Kitchens',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Micro Trust Badges
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: AppColors.textMutedSlate, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Instant OTP verification • Zero spam guarantee',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMutedSlate,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 48),

              // Legal Policy Footnote
              Center(
                child: InkWell(
                  onTap: () => context.push(RouteNames.legalPolicy),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to Hungr’s ',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSubtle,
                          fontSize: 11,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Terms & Privacy Policy',
                            style: TextStyle(
                              color: AppColors.textMutedSlate,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
