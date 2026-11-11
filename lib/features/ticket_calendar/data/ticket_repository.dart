import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/business_rules.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../domain/meal_ticket_model.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

class TicketRepository {
  Future<List<MealTicket>> fetchActiveUserTickets(String userId) async {
    // In production, queries firestore:
    // FirebaseFirestore.instance.collection('meal_tickets').where('userId', isEqualTo: userId).orderBy('deliveryDate')
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final now = DateTimeUtils.nowIst();
    final tomorrow = DateTime.utc(now.year, now.month, now.day + 1);

    return [
      MealTicket(
        ticketId: 't_001',
        passId: 'pass_7d_user1',
        userId: userId,
        clusterId: 'cluster_01',
        clusterName: 'Sri Sai Boys Hostel Gate',
        deliveryDate: tomorrow,
        comboSelection: 'A',
        addOns: const [BusinessRules.addonBoiledEggsId],
        slot: MealSlotType.morning,
        assignedVendorId: 'aunty_1',
        status: TicketStatusType.scheduled,
      ),
      MealTicket(
        ticketId: 't_002',
        passId: 'pass_7d_user1',
        userId: userId,
        clusterId: 'cluster_01',
        clusterName: 'Sri Sai Boys Hostel Gate',
        deliveryDate: tomorrow.add(const Duration(days: 1)),
        comboSelection: 'B',
        addOns: const [BusinessRules.addonFilterCoffeeId],
        slot: MealSlotType.morning,
        assignedVendorId: 'aunty_2',
        status: TicketStatusType.scheduled,
      ),
      MealTicket(
        ticketId: 't_003',
        passId: 'pass_7d_user1',
        userId: userId,
        clusterId: 'cluster_01',
        clusterName: 'Sri Sai Boys Hostel Gate',
        deliveryDate: tomorrow.add(const Duration(days: 2)),
        comboSelection: 'A',
        slot: MealSlotType.morning,
        assignedVendorId: 'aunty_1',
        status: TicketStatusType.scheduled,
      ),
      MealTicket(
        ticketId: 't_004',
        passId: 'pass_7d_user1',
        userId: userId,
        clusterId: 'cluster_01',
        clusterName: 'Sri Sai Boys Hostel Gate',
        deliveryDate: tomorrow.add(const Duration(days: 3)),
        comboSelection: 'B',
        slot: MealSlotType.morning,
        assignedVendorId: 'aunty_2',
        status: TicketStatusType.scheduled,
      ),
    ];
  }

  /// Enforces 9:00 PM cutoff and pass ceiling before skipping ticket
  Future<MealTicket> skipTomorrowTicket({
    required MealTicket ticketToSkip,
    required DateTime passHardExpiryDate,
    required DateTime currentQueueLastDate,
  }) async {
    // 1. Verify 9:00 PM Cutoff rule
    if (!DateTimeUtils.canModifyTomorrowMeal()) {
      throw Exception(
        '403_CUTOFF_PASSED: Cannot skip meal after 21:00:00 IST. Kitchen prep locked.',
      );
    }

    // 2. Check Pass Expiry Ceiling
    final newAppendedDate = currentQueueLastDate.add(const Duration(days: 1));
    if (newAppendedDate.isAfter(passHardExpiryDate)) {
      throw Exception(
        '403_EXPIRY_CEILING_REACHED: Cannot skip. Appending would exceed your pass validity ceiling (${passHardExpiryDate.day}/${passHardExpiryDate.month}).',
      );
    }

    // 3. Mark ticket as SKIPPED and create appended ticket
    final skippedTicket = ticketToSkip.copyWith(status: TicketStatusType.skipped);

    // In production, calls Cloud Function:
    // await FirebaseFunctions.instance.httpsCallable('skipMealTicket').call({...})

    return skippedTicket;
  }

  /// Switch Combo Selection before 9:00 PM cutoff
  Future<MealTicket> switchCombo({
    required MealTicket ticket,
    required String newCombo, // 'A' or 'B'
  }) async {
    if (!DateTimeUtils.canModifyTomorrowMeal()) {
      throw Exception('403_CUTOFF_PASSED: Cannot switch combo after 21:00:00 IST.');
    }
    return ticket.copyWith(comboSelection: newCombo);
  }
}
