import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/tiffin_item_model.dart';
import '../viewmodels/cart_viewmodel.dart';

/// Adds [item] to cart, showing a Swiggy-style "Replace cart item?" confirmation dialog
/// if the cart already contains items from a different partner kitchen.
Future<void> addTiffinItemWithKitchenCheck(
  BuildContext context,
  WidgetRef ref,
  TiffinItem item,
) async {
  final cartNotifier = ref.read(cartViewModelProvider.notifier);
  final cartState = ref.read(cartProvider);

  if (cartState.orderMode != OrderMode.singleDay) {
    cartNotifier.setOrderMode(OrderMode.singleDay);
  }

  if (!cartNotifier.hasKitchenConflict(item)) {
    HapticFeedback.lightImpact();
    cartNotifier.addTiffinItem(item);
    return;
  }

  final existingKitchen = cartState.activeKitchenName ?? 'another kitchen';
  final incomingKitchen = item.shopName ?? 'this kitchen';

  final shouldReplace = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Replace cart item?',
        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      ),
      content: Text(
        'Your cart contains dishes from $existingKitchen. Do you want to discard the selection and add dishes from $incomingKitchen?',
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('No', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.zomatoRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Replace'),
        ),
      ],
    ),
  );

  if (shouldReplace == true) {
    HapticFeedback.mediumImpact();
    cartNotifier.replaceCartWithItem(item);
  }
}
