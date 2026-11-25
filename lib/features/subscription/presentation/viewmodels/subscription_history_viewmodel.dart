import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../storefront/presentation/widgets/pass_card_3d.dart';
import '../../domain/subscription_order_model.dart';

class SubscriptionHistoryState {
  final List<SubscriptionOrder> orders;
  final bool isLoading;

  const SubscriptionHistoryState({
    required this.orders,
    this.isLoading = false,
  });

  SubscriptionHistoryState copyWith({
    List<SubscriptionOrder>? orders,
    bool? isLoading,
  }) {
    return SubscriptionHistoryState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SubscriptionHistoryViewModel extends StateNotifier<SubscriptionHistoryState> {
  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<Map<String, dynamic>>>? _ordersSub;

  SubscriptionHistoryViewModel() : super(const SubscriptionHistoryState(orders: [], isLoading: false)) {
    _listenToOrders();
  }

  void _listenToOrders() {
    _authSub = FirebaseService.instance.authStateChanges.listen((user) {
      _ordersSub?.cancel();
      if (user == null) {
        state = const SubscriptionHistoryState(orders: [], isLoading: false);
        return;
      }

      state = state.copyWith(isLoading: true);
      _ordersSub = FirebaseService.instance.streamUserOrders(user.uid).listen((rawOrders) {
        final mapped = rawOrders.map((doc) {
          final isSingleDay = (doc['orderMode'] as String?) == 'singleDay';
          final createdAtMs = (doc['createdAtMs'] as num?)?.toInt();
          final purchaseDate = createdAtMs != null
              ? DateTime.fromMillisecondsSinceEpoch(createdAtMs)
              : DateTime.now();

          final days = (doc['days'] as num?)?.toInt() ?? 1;
          final rawItems = (doc['itemDetails'] as List<dynamic>?) ?? const [];
          final itemStrings = rawItems
              .map((e) => e is Map ? '${e['qty'] ?? 1}x ${e['name'] ?? 'Tiffin'}' : e.toString())
              .toList();

          final statusRaw = (doc['status'] as String?) ?? 'CONFIRMED';
          final status = (statusRaw == 'COMPLETED' || statusRaw == 'DELIVERED')
              ? SubscriptionStatus.completed
              : (statusRaw == 'PAUSED' ? SubscriptionStatus.paused : SubscriptionStatus.active);

          return SubscriptionOrder(
            id: (doc['orderId'] as String?) ?? 'HNG-ORD',
            passTitle: isSingleDay
                ? '${doc['kitchenName'] ?? 'Morning Tiffin'} • Single Drop'
                : (doc['tier'] as String?) ?? 'Morning Meal Pass',
            passType: isSingleDay ? 'singleDay' : ((doc['tierKey'] as String?) ?? 'routine7Day'),
            totalMeals: days,
            mealsRemaining: status == SubscriptionStatus.completed ? 0 : days,
            amountPaid: (doc['totalAmount'] as num?)?.toInt() ?? 0,
            purchaseDate: purchaseDate,
            startDate: purchaseDate,
            endDate: purchaseDate.add(Duration(days: days)),
            selectedCombo: isSingleDay
                ? (itemStrings.isNotEmpty ? itemStrings.join(', ') : 'Single-Day Tiffin Order')
                : 'Option ${doc['comboSelection'] ?? 'A'}',
            addons: itemStrings,
            clusterName: (doc['clusterName'] as String?) ?? 'Gate Drop',
            paymentMethod: (doc['paymentMethod'] as String?) ?? 'UPI Prepaid',
            transactionId: (doc['bagToken'] as String?) ?? (doc['orderId'] as String? ?? ''),
            status: status,
          );
        }).toList();

        state = SubscriptionHistoryState(orders: mapped, isLoading: false);
      });
    });
  }

  void addSubscription({
    required PassTierType tier,
    required String combo,
    required Set<String> addons,
    required int totalAmount,
    required String clusterName,
    String? orderId,
    String? bagToken,
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
      id: orderId ?? 'HNG-SUB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
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
      paymentMethod: 'UPI Prepaid',
      transactionId: bagToken ?? 'UPI/HNG/${DateTime.now().millisecondsSinceEpoch}',
      status: SubscriptionStatus.active,
    );

    if (!state.orders.any((o) => o.id == newOrder.id)) {
      state = state.copyWith(orders: [newOrder, ...state.orders]);
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }
}

final subscriptionHistoryProvider =
    StateNotifierProvider<SubscriptionHistoryViewModel, SubscriptionHistoryState>((ref) {
  return SubscriptionHistoryViewModel();
});
