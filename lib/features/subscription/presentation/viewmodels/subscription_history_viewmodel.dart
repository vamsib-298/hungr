import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/subscription_order_model.dart';
import '../../../storefront/presentation/widgets/pass_card_3d.dart';

class SubscriptionHistoryState {
  final List<SubscriptionOrder> orders;

  const SubscriptionHistoryState({required this.orders});

  SubscriptionHistoryState copyWith({List<SubscriptionOrder>? orders}) {
    return SubscriptionHistoryState(orders: orders ?? this.orders);
  }
}

class SubscriptionHistoryViewModel extends StateNotifier<SubscriptionHistoryState> {
  SubscriptionHistoryViewModel()
      : super(
          SubscriptionHistoryState(
            orders: [
              SubscriptionOrder(
                id: 'HNG-SUB-894102',
                passTitle: '7-Day Routine Pass',
                passType: 'routine7Day',
                totalMeals: 7,
                mealsRemaining: 5,
                amountPaid: 370,
                purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
                startDate: DateTime.now().subtract(const Duration(days: 2)),
                endDate: DateTime.now().add(const Duration(days: 5)),
                selectedCombo: 'Option A (Set Dosa)',
                addons: const ['Farm-Fresh Boiled Eggs (2 pcs)'],
                clusterName: 'Sri Sai Boys Hostel Gate',
                paymentMethod: 'Google Pay (UPI)',
                transactionId: 'UPI/RAZOR/987410284',
                status: SubscriptionStatus.active,
              ),
              SubscriptionOrder(
                id: 'HNG-SUB-823901',
                passTitle: '3-Day Starter Trial Pass',
                passType: 'trial3Day',
                totalMeals: 3,
                mealsRemaining: 0,
                amountPaid: 165,
                purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
                startDate: DateTime.now().subtract(const Duration(days: 10)),
                endDate: DateTime.now().subtract(const Duration(days: 7)),
                selectedCombo: 'Option B (Idli & Vada)',
                addons: const [],
                clusterName: 'Sri Sai Boys Hostel Gate',
                paymentMethod: 'PhonePe (UPI)',
                transactionId: 'UPI/RAZOR/764910283',
                status: SubscriptionStatus.completed,
              ),
            ],
          ),
        );

  void addSubscription({
    required PassTierType tier,
    required String combo,
    required Set<String> addons,
    required int totalAmount,
    required String clusterName,
  }) {
    String passTitle = '7-Day Routine Pass';
    int total = 7;
    String tierType = 'routine7Day';

    if (tier == PassTierType.trial3Day) {
      passTitle = '3-Day Starter Pass';
      total = 3;
      tierType = 'trial3Day';
    } else if (tier == PassTierType.power15Day) {
      passTitle = '15-Day Power Pass';
      total = 15;
      tierType = 'power15Day';
    }

    final newOrder = SubscriptionOrder(
      id: 'HNG-SUB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      passTitle: passTitle,
      passType: tierType,
      totalMeals: total,
      mealsRemaining: total,
      amountPaid: totalAmount,
      purchaseDate: DateTime.now(),
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(Duration(days: total + 1)),
      selectedCombo: combo == 'A' ? 'Option A (Set Dosa)' : 'Option B (Idli & Vada)',
      addons: addons.toList(),
      clusterName: clusterName,
      paymentMethod: 'Instant UPI (Auto-Confirmed)',
      transactionId: 'UPI/HNG/${DateTime.now().millisecondsSinceEpoch}',
      status: SubscriptionStatus.active,
    );

    state = state.copyWith(orders: [newOrder, ...state.orders]);
  }
}

final subscriptionHistoryProvider =
    StateNotifierProvider<SubscriptionHistoryViewModel, SubscriptionHistoryState>((ref) {
  return SubscriptionHistoryViewModel();
});
