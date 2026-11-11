enum SubscriptionStatus {
  active,
  completed,
  paused,
}

class SubscriptionOrder {
  final String id;
  final String passTitle;
  final String passType; // 'routine7Day', 'power15Day', 'trial3Day'
  final int totalMeals;
  final int mealsRemaining;
  final int amountPaid;
  final DateTime purchaseDate;
  final DateTime startDate;
  final DateTime endDate;
  final String selectedCombo;
  final List<String> addons;
  final String clusterName;
  final String paymentMethod;
  final String transactionId;
  final SubscriptionStatus status;

  const SubscriptionOrder({
    required this.id,
    required this.passTitle,
    required this.passType,
    required this.totalMeals,
    required this.mealsRemaining,
    required this.amountPaid,
    required this.purchaseDate,
    required this.startDate,
    required this.endDate,
    required this.selectedCombo,
    required this.addons,
    required this.clusterName,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
  });

  SubscriptionOrder copyWith({
    String? id,
    String? passTitle,
    String? passType,
    int? totalMeals,
    int? mealsRemaining,
    int? amountPaid,
    DateTime? purchaseDate,
    DateTime? startDate,
    DateTime? endDate,
    String? selectedCombo,
    List<String>? addons,
    String? clusterName,
    String? paymentMethod,
    String? transactionId,
    SubscriptionStatus? status,
  }) {
    return SubscriptionOrder(
      id: id ?? this.id,
      passTitle: passTitle ?? this.passTitle,
      passType: passType ?? this.passType,
      totalMeals: totalMeals ?? this.totalMeals,
      mealsRemaining: mealsRemaining ?? this.mealsRemaining,
      amountPaid: amountPaid ?? this.amountPaid,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedCombo: selectedCombo ?? this.selectedCombo,
      addons: addons ?? this.addons,
      clusterName: clusterName ?? this.clusterName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
    );
  }
}
