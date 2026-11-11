import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/obsidian_card.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
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
    final cleanPhone = '+91 ${_phoneController.text.trim()}';
    final name = _nameController.text.trim();
    context.push(RouteNames.otpVerify, extra: {
      'phone': cleanPhone,
      'name': name.isNotEmpty ? name : 'Vamsi Krishna',
    });
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

              const SizedBox(height: 32),

              // Phone Input Card
              ObsidianCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                borderColor: _isValidPhone
                    ? AppColors.zomatoRed.withOpacity(0.8)
                    : AppColors.charcoalBorder,
                borderWidth: _isValidPhone ? 1.5 : 1.0,
                child: Row(
                  children: [
                    // India Flag + Code Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: AppDimensions.radius8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '+91',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textCrispWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Phone Number Field
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: AppTypography.titleLarge.copyWith(
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: '98765 43210',
                          hintStyle: AppTypography.titleLarge.copyWith(
                            color: AppColors.textSubtle.withOpacity(0.4),
                            letterSpacing: 2.0,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onSubmitted: (_) => _submitPhone(),
                      ),
                    ),
                    if (_isValidPhone)
                      const Icon(Icons.check_circle_rounded, color: AppColors.neonMint, size: 20)
                          .animate()
                          .scale(duration: 200.ms),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 12),

              // Name Input Card (Login & Register)
              ObsidianCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, color: AppColors.textMutedSlate, size: 20),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: AppTypography.titleMedium,
                        decoration: InputDecoration(
                          hintText: 'Your Name (e.g. Vamsi Krishna)',
                          hintStyle: AppTypography.titleMedium.copyWith(
                            color: AppColors.textSubtle.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 220.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Primary CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValidPhone ? AppColors.zomatoRed : const Color(0xFFE5E7EB),
                    foregroundColor: _isValidPhone ? Colors.white : AppColors.textSubtle,
                    elevation: _isValidPhone ? 4 : 0,
                    shadowColor: AppColors.zomatoRedGlow,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.radius16,
                    ),
                  ),
                  onPressed: _isValidPhone ? _submitPhone : null,
                  child: Row(
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
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms),

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
