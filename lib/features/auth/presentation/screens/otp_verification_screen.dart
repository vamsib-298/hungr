import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../viewmodels/auth_viewmodel.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String userName;

  const OtpVerificationScreen({
    super.key,
    this.phoneNumber = '+91 98765 43210',
    this.userName = 'Vamsi Krishna',
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<FocusNode> _keyboardFocusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 30;
  Timer? _timer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendCountdown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final k in _keyboardFocusNodes) {
      k.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      setState(() => _isSubmitting = true);
      HapticFeedback.mediumImpact();
      ref.read(authProvider.notifier).login(
            phone: widget.phoneNumber,
            name: widget.userName,
          );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        context.go(RouteNames.clusterSelection);
      });
    } else {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.urgentCrimson,
          content: Text(
            'Please enter the full 6-digit verification code',
            style: AppTypography.labelLarge,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOtpComplete = _controllers.every((c) => c.text.isNotEmpty);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RouteNames.phoneAuth);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.obsidianBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.phoneAuth);
              }
            },
          ),
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
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.zomatoRedGlow.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/icons/app_icon_512.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 350.ms),

              const SizedBox(height: 24),

              Text(
                'Enter Verification Code',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 8),

              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Sent to ${widget.phoneNumber}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textMutedSlate,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: AppDimensions.radius8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Change',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.zomatoRedLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms),

              const SizedBox(height: 36),

              // 6-Digit OTP Cells
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  final isCurrentFilled = _controllers[index].text.isNotEmpty;
                  return Expanded(
                    child: Container(
                      height: 56,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 3,
                        right: index == 5 ? 0 : 3,
                      ),
                      child: RawKeyboardListener(
                        focusNode: _keyboardFocusNodes[index],
                        onKey: (event) {
                          if (event is RawKeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.backspace &&
                              _controllers[index].text.isEmpty &&
                              index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          autofocus: index == 0,
                          style: AppTypography.monoPrice.copyWith(
                            fontSize: 20,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: isCurrentFilled
                                ? AppColors.zomatoRedSurface
                                : Colors.white,
                            border: const OutlineInputBorder(
                              borderRadius: AppDimensions.radius12,
                              borderSide: BorderSide(color: AppColors.charcoalBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppDimensions.radius12,
                              borderSide: BorderSide(
                                color: isCurrentFilled
                                    ? AppColors.zomatoRed.withOpacity(0.6)
                                    : AppColors.charcoalBorder,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: AppDimensions.radius12,
                              borderSide: BorderSide(color: AppColors.zomatoRed, width: 2),
                            ),
                          ),
                          onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          setState(() {});
                          if (index == 5 && value.isNotEmpty) {
                            _verifyOtp();
                          }
                        },
                        ),
                      ),
                    ),
                  );
                }),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 28),

              // Resend Action
              Center(
                child: _resendCountdown > 0
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, color: AppColors.textSubtle, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Resend code in ${_resendCountdown}s',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSubtle,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : TextButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.zomatoRedLight),
                        label: Text(
                          'Resend OTP Code',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.zomatoRedLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _startTimer();
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF1F2937),
                              content: Text(
                                'A new 6-digit OTP has been sent via SMS.',
                                style: AppTypography.labelLarge.copyWith(color: Colors.white),
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                      ),
              )
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms),

              const SizedBox(height: 36),

              // Verify & Continue Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOtpComplete ? AppColors.zomatoRed : const Color(0xFFE5E7EB),
                    foregroundColor: isOtpComplete ? Colors.white : AppColors.textSubtle,
                    elevation: isOtpComplete ? 4 : 0,
                    shadowColor: AppColors.zomatoRedGlow,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.radius16,
                    ),
                  ),
                  onPressed: isOtpComplete && !_isSubmitting ? _verifyOtp : null,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Verify & Continue',
                          style: AppTypography.labelLarge.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: isOtpComplete ? Colors.white : AppColors.textSubtle,
                          ),
                        ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    ),
  );
}
}
