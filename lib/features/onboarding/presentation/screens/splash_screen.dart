import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _navigateToNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Warm up and precache critical branding assets instantly
    precacheImage(const AssetImage('assets/icons/app_icon_512.png'), context);
  }

  Future<void> _navigateToNext() async {
    // 1100ms smooth breathing brand entrance
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    final isPersistedAuth = await LocalStorageService.instance.isAuthenticated();
    if (!mounted) return;
    if (isPersistedAuth) {
      await ref.read(authProvider.notifier).loadSavedSession();
      if (!mounted) return;
      context.go(RouteNames.storefront);
    } else {
      context.go(RouteNames.phoneAuth);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.15),
            radius: 1.15,
            colors: [
              Color(0xFFFFF1F2), // Sunset-Crimson gentle morning glow
              Color(0xFFF9FAFB), // Soft porcelain canvas
              Colors.white,      // Pure clean white
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Ambient Dynamic Breathing Glow Behind Icon
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.22);
                final opacity = 0.25 + (_pulseController.value * 0.25);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: size.width * 0.75,
                    height: size.width * 0.75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.zomatoRed.withOpacity(opacity),
                          AppColors.zomatoRedGlow.withOpacity(opacity * 0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // 2. Central Hero Branding Assembly
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Official Sunset-Red 'H' Emblem
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.zomatoRedGlow.withOpacity(0.7),
                          blurRadius: 36,
                          spreadRadius: 4,
                          offset: const Offset(0, 10),
                        ),
                        const BoxShadow(
                          color: Color(0x66FFC107),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/icons/app_icon_512.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      .animate()
                      .scale(duration: 500.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // Brand Moniker
                  Text(
                    'HUNGR',
                    style: AppTypography.displayLarge.copyWith(
                      letterSpacing: 6.0,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textCrispWhite,
                      shadows: const [
                        Shadow(
                          color: AppColors.zomatoRedGlow,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 450.ms)
                      .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

                  const SizedBox(height: 10),

                  // Minimal Tagline Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.zomatoRedSurface,
                      borderRadius: AppDimensions.radiusCircle,
                      border: Border.all(
                        color: AppColors.zomatoRedBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.zomatoRedLight,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'HOT MORNING TIFFIN • 07:30 AM DROP',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textCrispWhite,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 400.ms),
                ],
              ),
            ),

            // 3. Bottom Minimal Progress Pill
            Positioned(
              bottom: 44,
              child: Column(
                children: [
                  const SizedBox(
                    width: 130,
                    child: ClipRRect(
                      borderRadius: AppDimensions.radiusCircle,
                      child: LinearProgressIndicator(
                        backgroundColor: Color(0xFF1E0508),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.zomatoRed),
                        minHeight: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.neonMint,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonMint,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Khammam Route 01 Live',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMutedSlate,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}
