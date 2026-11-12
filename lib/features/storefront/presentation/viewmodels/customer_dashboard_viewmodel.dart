import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/business_rules.dart';
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
  CustomerDashboardViewModel()
      : super(
          CustomerDashboardState(
            hasActivePass: true,
            activeTier: PassTierType.routine7Day,
            mealsRemaining: 5,
            totalMeals: 7,
            tomorrowCombo: 'A',
            activeAddons: {BusinessRules.addonBoiledEggsId},
            selectedCluster: const DeliveryCluster(
              id: 'cluster_01',
              name: 'Sri Sai Boys Hostel Gate',
              addressZone: 'Bypass Road, Khammam',
              landmark: 'Near Bus Stand, Khammam',
              currentSubscribers: 36,
              maxCapacity: 50,
              latitude: 17.2473,
              longitude: 80.1514,
            ),
            tickets: _generateInitialTickets(),
            isRenewAlertActive: false,
          ),
        ) {
    _loadPersistedState();
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

    final savedPass = await LocalStorageService.instance.getSavedPassState();
    if (savedPass != null) {
      PassTierType tier = PassTierType.routine7Day;
      if (savedPass['tier'] == 'trial3Day') tier = PassTierType.trial3Day;
      if (savedPass['tier'] == 'power15Day') tier = PassTierType.power15Day;

      state = state.copyWith(
        hasActivePass: savedPass['hasActivePass'] as bool,
        activeTier: tier,
        mealsRemaining: savedPass['mealsRemaining'] as int,
        totalMeals: savedPass['totalMeals'] as int,
        tomorrowCombo: savedPass['tomorrowCombo'] as String,
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

  static List<MealTicket> _generateInitialTickets() {
    final targetStart = DateTimeUtils.targetDeliveryDate();

    return List<MealTicket>.generate(5, (index) {
      final deliveryDate = targetStart.add(Duration(days: index));
      final specialty = khammamSpecialties[index % khammamSpecialties.length];
      final token = DateTimeUtils.generateBagToken('Sri Sai Boys Hostel Gate', index + 4);

      return MealTicket(
        ticketId: 't_00${index + 1}',
        passId: 'pass_7d_user1',
        userId: 'user_khammam_01',
        clusterId: 'cluster_01',
        clusterName: 'Sri Sai Boys Hostel Gate',
        deliveryDate: deliveryDate,
        comboSelection: index % 2 == 0 ? 'A' : 'B',
        addOns: index == 0 ? const [BusinessRules.addonBoiledEggsId] : const [],
        slot: MealSlotType.morning,
        status: TicketStatusType.scheduled,
        bagToken: token,
        specialtyName: specialty,
        companionMeals: 0,
      );
    });
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

    final generatedTickets = List<MealTicket>.generate(total, (index) {
      final deliveryDate = targetStart.add(Duration(days: index));
      final ticketCombo = (index % 2 == 0) ? combo : (combo == 'A' ? 'B' : 'A');
      final specialty = autoRotateSpecialties
          ? khammamSpecialties[index % khammamSpecialties.length]
          : (ticketCombo == 'A' ? 'Steaming Ghee Idli + Vada' : 'Crisp Masala Dosa');

      return MealTicket(
        ticketId: 't_${DateTime.now().millisecondsSinceEpoch}_$index',
        passId: 'pass_${tier.name}_user1',
        userId: 'user_khammam_01',
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
      final lastDate = updatedTickets.last.deliveryDate;
      final appendedDate = lastDate.add(const Duration(days: 1));

      final replacementTicket = MealTicket(
        ticketId: 't_rep_${DateTime.now().millisecondsSinceEpoch}',
        passId: target.passId,
        userId: target.userId,
        clusterId: target.clusterId,
        clusterName: target.clusterName,
        deliveryDate: appendedDate,
        comboSelection: target.comboSelection,
        addOns: target.addOns,
        slot: target.slot,
        status: TicketStatusType.scheduled,
      );
      updatedTickets.add(replacementTicket);
    } else if (target.status == TicketStatusType.skipped) {
      updatedTickets[index] = target.copyWith(status: TicketStatusType.scheduled);
      if (updatedTickets.length > state.totalMeals) {
        updatedTickets.removeLast();
      }
    }

    state = state.copyWith(tickets: updatedTickets);
    return true;
  }

  void switchTicketCombo(String ticketId, String newCombo) {
    final index = state.tickets.indexWhere((t) => t.ticketId == ticketId);
    if (index == -1) return;

    final updatedTickets = List<MealTicket>.from(state.tickets);
    updatedTickets[index] = updatedTickets[index].copyWith(comboSelection: newCombo);

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

    final updatedTickets = List<MealTicket>.from(state.tickets);
    if (updatedTickets.isNotEmpty) {
      updatedTickets[0] = updatedTickets[0].copyWith(comboSelection: newCombo);
    }

    state = state.copyWith(
      tomorrowCombo: newCombo,
      tickets: updatedTickets,
    );
  }

  bool skipTomorrow() {
    if (!DateTimeUtils.canModifyTomorrowMeal()) {
      return false; // Cutoff passed
    }

    if (state.tickets.isEmpty) return false;

    final updatedTickets = List<MealTicket>.from(state.tickets);
    final skipped = updatedTickets[0].copyWith(status: TicketStatusType.skipped);
    updatedTickets[0] = skipped;

    // Append new ticket at the tail
    final lastDate = updatedTickets.last.deliveryDate;
    final appendedDate = lastDate.add(const Duration(days: 1));

    final newTicket = MealTicket(
      ticketId: 't_${DateTime.now().millisecondsSinceEpoch}',
      passId: skipped.passId,
      userId: skipped.userId,
      clusterId: skipped.clusterId,
      clusterName: skipped.clusterName,
      deliveryDate: appendedDate,
      comboSelection: skipped.comboSelection,
      addOns: skipped.addOns,
      slot: skipped.slot,
      status: TicketStatusType.scheduled,
    );

    updatedTickets.add(newTicket);

    state = state.copyWith(
      tickets: updatedTickets,
    );
    return true;
  }

  void updateCluster(DeliveryCluster newCluster) {
    state = state.copyWith(selectedCluster: newCluster);
    LocalStorageService.instance.saveCluster(
      id: newCluster.id,
      name: newCluster.name,
      zone: newCluster.addressZone,
      landmark: newCluster.landmark,
    );
  }
}

final customerDashboardProvider =
    StateNotifierProvider<CustomerDashboardViewModel, CustomerDashboardState>((ref) {
  return CustomerDashboardViewModel();
});
