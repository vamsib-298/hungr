import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../onboarding/domain/cluster_model.dart';
import '../../../ticket_calendar/domain/meal_ticket_model.dart';
import '../widgets/pass_card_3d.dart';

class CustomerDashboardState {
  final bool hasActivePass;
  final PassTierType activeTier;
  final int mealsRemaining;
  final int totalMeals;
  final String tomorrowCombo; // 'A' or 'B'
  final Set<String> activeAddons;
  final DeliveryCluster selectedCluster;
  final List<MealTicket> tickets;
  final bool isRenewAlertActive;

  const CustomerDashboardState({
    required this.hasActivePass,
    required this.activeTier,
    required this.mealsRemaining,
    required this.totalMeals,
    required this.tomorrowCombo,
    required this.activeAddons,
    required this.selectedCluster,
    required this.tickets,
    required this.isRenewAlertActive,
  });

  bool get hasUpcomingMeal =>
      tickets.any((t) => t.status == TicketStatusType.scheduled || t.status == TicketStatusType.delivered);

  MealTicket? get nextScheduledTicket {
    for (final t in tickets) {
      if (t.status == TicketStatusType.scheduled || t.status == TicketStatusType.delivered) {
        return t;
      }
    }
    return tickets.isNotEmpty ? tickets.first : null;
  }

  CustomerDashboardState copyWith({
    bool? hasActivePass,
    PassTierType? activeTier,
    int? mealsRemaining,
    int? totalMeals,
    String? tomorrowCombo,
    Set<String>? activeAddons,
    DeliveryCluster? selectedCluster,
    List<MealTicket>? tickets,
    bool? isRenewAlertActive,
  }) {
    return CustomerDashboardState(
      hasActivePass: hasActivePass ?? this.hasActivePass,
      activeTier: activeTier ?? this.activeTier,
      mealsRemaining: mealsRemaining ?? this.mealsRemaining,
      totalMeals: totalMeals ?? this.totalMeals,
      tomorrowCombo: tomorrowCombo ?? this.tomorrowCombo,
      activeAddons: activeAddons ?? this.activeAddons,
      selectedCluster: selectedCluster ?? this.selectedCluster,
      tickets: tickets ?? this.tickets,
      isRenewAlertActive: isRenewAlertActive ?? this.isRenewAlertActive,
    );
  }
}

class CustomerDashboardViewModel extends StateNotifier<CustomerDashboardState> {
  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<Map<String, dynamic>>>? _passesSub;
  StreamSubscription<List<Map<String, dynamic>>>? _ticketsSub;

  CustomerDashboardViewModel()
      : super(
          const CustomerDashboardState(
            hasActivePass: false,
            activeTier: PassTierType.routine7Day,
            mealsRemaining: 0,
            totalMeals: 0,
            tomorrowCombo: 'A',
            activeAddons: {},
            selectedCluster: DeliveryCluster(
              id: 'cluster_01',
              name: 'Sri Sai Boys Hostel Main Gate',
              addressZone: 'Bypass Road, Khammam',
              landmark: 'Near New Collectorate Arch',
              currentSubscribers: 38,
              maxCapacity: 50,
              latitude: 17.2473,
              longitude: 80.1514,
            ),
            tickets: [],
            isRenewAlertActive: false,
          ),
        ) {
    _loadPersistedState();
    _listenToUserStreams();
  }

  void _listenToUserStreams() {
    _authSub = FirebaseService.instance.authStateChanges.listen((user) {
      _passesSub?.cancel();
      _ticketsSub?.cancel();

      if (user == null) {
        state = state.copyWith(
          hasActivePass: false,
          mealsRemaining: 0,
          totalMeals: 0,
          tickets: const [],
        );
        return;
      }

      _passesSub = FirebaseService.instance.streamUserPasses(user.uid).listen((passes) {
        if (passes.isEmpty) return;
        final activePasses = passes.where((p) => (p['status'] as String?) == 'ACTIVE').toList();
        if (activePasses.isEmpty) {
          state = state.copyWith(hasActivePass: false, mealsRemaining: 0, totalMeals: 0);
          return;
        }
        final latest = activePasses.first;
        final tierKey = latest['tierKey'] as String? ?? 'routine7Day';
        PassTierType tier = PassTierType.routine7Day;
        if (tierKey == 'trial3Day') tier = PassTierType.trial3Day;
        if (tierKey == 'power15Day') tier = PassTierType.power15Day;

        state = state.copyWith(
          hasActivePass: true,
          activeTier: tier,
          totalMeals: (latest['totalDays'] as num?)?.toInt() ?? 7,
          mealsRemaining: (latest['remainingDays'] as num?)?.toInt() ?? 0,
          tomorrowCombo: latest['comboSelection'] as String? ?? state.tomorrowCombo,
        );
      });

      _ticketsSub = FirebaseService.instance.streamUserTickets(user.uid).listen((rawTickets) {
        if (rawTickets.isEmpty) return;
        final parsed = rawTickets.map((doc) {
          final statusStr = (doc['status'] as String?) ?? 'SCHEDULED';
          TicketStatusType status = TicketStatusType.scheduled;
          if (statusStr == 'SKIPPED' || statusStr == 'EXPIRED') status = TicketStatusType.skipped;
          if (statusStr == 'DELIVERED') status = TicketStatusType.delivered;
          if (statusStr == 'LOCKED') status = TicketStatusType.locked;

          final iso = doc['deliveryDateIso'] as String?;
          final deliveryDate = iso != null ? (DateTime.tryParse(iso) ?? DateTimeUtils.targetDeliveryDate()) : DateTimeUtils.targetDeliveryDate();
          final deliveredIso = doc['deliveredAtIso'] as String?;
          final deliveredAt = deliveredIso != null ? DateTime.tryParse(deliveredIso) : null;

          return MealTicket(
            ticketId: (doc['ticketId'] as String?) ?? '',
            passId: (doc['passId'] as String?) ?? '',
            userId: (doc['userId'] as String?) ?? user.uid,
            clusterId: (doc['clusterId'] as String?) ?? state.selectedCluster.id,
            clusterName: (doc['clusterName'] as String?) ?? state.selectedCluster.name,
            deliveryDate: deliveryDate,
            comboSelection: (doc['comboSelection'] as String?) ?? 'A',
            addOns: (doc['addOns'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
            slot: (doc['slot'] as String?)?.contains('0800') == true ? MealSlotType.morning : MealSlotType.morning,
            status: status,
            bagToken: (doc['bagToken'] as String?) ?? '#HNG-01',
            specialtyName: doc['specialtyName'] as String?,
            companionMeals: (doc['companionMeals'] as num?)?.toInt() ?? 0,
            dropProofImageUrl: doc['dropProofImageUrl'] as String?,
            deliveredAt: deliveredAt,
          );
        }).toList();

        state = state.copyWith(tickets: parsed);
      });
    });
  }

  Future<void> _loadPersistedState() async {
    final savedCluster = await LocalStorageService.instance.getSavedCluster();
    if (savedCluster != null) {
      state = state.copyWith(
        selectedCluster: DeliveryCluster(
          id: savedCluster['id']!,
          name: savedCluster['name']!,
          addressZone: savedCluster['zone']!,
          landmark: savedCluster['landmark']!,
          currentSubscribers: 36,
          maxCapacity: 50,
          latitude: 17.2473,
          longitude: 80.1514,
        ),
      );
    }
  }

  static const List<String> khammamSpecialties = [
    'Rayalaseema Set Dosa & Coconut Chutney',
    'Steaming Ghee Thatte Idlis + Medu Vada',
    'Homestyle Poori Masala (Amma Chethi Vanta)',
    'MLA Pesarattu Upma & Ginger Pachadi',
    'Crisp Mysore Bonda & Drumstick Sambar',
    'Karnataka Udupi Ghee Roast Dosa',
  ];

  /// Records a single-day morning tiffin order (creates 1 meal ticket, no pass)
  void recordSingleDayOrder({
    required String summaryName,
    required Set<String> items,
    int companionMeals = 0,
    required String bagToken,
  }) {
    final targetDate = DateTimeUtils.targetDeliveryDate();
    final uid = FirebaseService.instance.currentUser?.uid ?? 'customer';
    final ticket = MealTicket(
      ticketId: 'single_${DateTime.now().millisecondsSinceEpoch}',
      passId: 'single_order',
      userId: uid,
      clusterId: state.selectedCluster.id,
      clusterName: state.selectedCluster.name,
      deliveryDate: targetDate,
      comboSelection: 'A',
      addOns: items.toList(),
      slot: MealSlotType.morning,
      status: TicketStatusType.scheduled,
      bagToken: bagToken,
      specialtyName: summaryName,
      companionMeals: companionMeals,
    );

    state = state.copyWith(
      tickets: [ticket, ...state.tickets],
    );
  }

  void activateNewPass({
    required PassTierType tier,
    required String combo,
    required Set<String> addons,
    bool autoRotateSpecialties = true,
    int companionMeals = 0,
    String? bagToken,
  }) {
    int total = 7;
    if (tier == PassTierType.trial3Day) total = 3;
    if (tier == PassTierType.power15Day) total = 15;

    final targetStart = DateTimeUtils.targetDeliveryDate();
    final baseToken = bagToken ?? DateTimeUtils.generateBagToken(state.selectedCluster.name, 7);
    final uid = FirebaseService.instance.currentUser?.uid ?? 'customer';

    final generatedTickets = List<MealTicket>.generate(total, (index) {
      final deliveryDate = targetStart.add(Duration(days: index));
      final ticketCombo = (index % 2 == 0) ? combo : (combo == 'A' ? 'B' : 'A');
      final specialty = autoRotateSpecialties
          ? khammamSpecialties[index % khammamSpecialties.length]
          : (ticketCombo == 'A' ? 'Steaming Ghee Idli + Vada' : 'Crisp Masala Dosa');

      return MealTicket(
        ticketId: 't_${DateTime.now().millisecondsSinceEpoch}_$index',
        passId: 'pass_${tier.name}_$uid',
        userId: uid,
        clusterId: state.selectedCluster.id,
        clusterName: state.selectedCluster.name,
        deliveryDate: deliveryDate,
        comboSelection: ticketCombo,
        addOns: addons.toList(),
        slot: MealSlotType.morning,
        status: TicketStatusType.scheduled,
        bagToken: baseToken,
        specialtyName: specialty,
        companionMeals: index == 0 ? companionMeals : 0,
      );
    });

    state = state.copyWith(
      hasActivePass: true,
      activeTier: tier,
      totalMeals: total,
      mealsRemaining: total,
      tomorrowCombo: combo,
      activeAddons: addons,
      tickets: generatedTickets,
      isRenewAlertActive: false,
    );

    LocalStorageService.instance.savePassState(
      hasActivePass: true,
      tier: tier.name,
      mealsRemaining: total,
      totalMeals: total,
      tomorrowCombo: combo,
    );
  }

  bool togglePauseTicket(String ticketId) {
    final index = state.tickets.indexWhere((t) => t.ticketId == ticketId);
    if (index == -1) return false;

    final updatedTickets = List<MealTicket>.from(state.tickets);
    final target = updatedTickets[index];

    if (target.status == TicketStatusType.scheduled) {
      updatedTickets[index] = target.copyWith(status: TicketStatusType.skipped);
      FirebaseService.instance.updateTicketStatus(ticketId: ticketId, status: 'SKIPPED');
    } else if (target.status == TicketStatusType.skipped) {
      updatedTickets[index] = target.copyWith(status: TicketStatusType.scheduled);
      FirebaseService.instance.updateTicketStatus(ticketId: ticketId, status: 'SCHEDULED');
    }

    state = state.copyWith(tickets: updatedTickets);
    return true;
  }

  void switchTicketCombo(String ticketId, String newCombo) {
    final index = state.tickets.indexWhere((t) => t.ticketId == ticketId);
    if (index == -1) return;

    final updatedTickets = List<MealTicket>.from(state.tickets);
    updatedTickets[index] = updatedTickets[index].copyWith(comboSelection: newCombo);

    FirebaseService.instance.updateTicketCombo(ticketId: ticketId, comboSelection: newCombo);

    if (index == 0) {
      state = state.copyWith(tomorrowCombo: newCombo, tickets: updatedTickets);
    } else {
      state = state.copyWith(tickets: updatedTickets);
    }
  }

  void switchTomorrowCombo(String newCombo) {
    if (!DateTimeUtils.canModifyTomorrowMeal()) {
      throw Exception('403_CUTOFF_PASSED: Cannot switch meal after 9:00 PM IST.');
    }
    if (state.tickets.isNotEmpty) {
      switchTicketCombo(state.tickets.first.ticketId, newCombo);
    } else {
      state = state.copyWith(tomorrowCombo: newCombo);
    }
  }

  bool skipTomorrow() {
    if (!DateTimeUtils.canModifyTomorrowMeal() || state.tickets.isEmpty) {
      return false;
    }
    return togglePauseTicket(state.tickets.first.ticketId);
  }

  void updateCluster(DeliveryCluster newCluster) {
    state = state.copyWith(selectedCluster: newCluster);
    LocalStorageService.instance.saveCluster(
      id: newCluster.id,
      name: newCluster.name,
      zone: newCluster.addressZone,
      landmark: newCluster.landmark,
    );
    final user = FirebaseService.instance.currentUser;
    if (user != null) {
      FirebaseService.instance.syncUserProfile(
        uid: user.uid,
        name: user.displayName ?? 'Hungr Foodie',
        phone: user.phoneNumber ?? '',
        dropGate: newCluster.name,
      );
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _passesSub?.cancel();
    _ticketsSub?.cancel();
    super.dispose();
  }
}

final customerDashboardProvider =
    StateNotifierProvider<CustomerDashboardViewModel, CustomerDashboardState>((ref) {
  return CustomerDashboardViewModel();
});
