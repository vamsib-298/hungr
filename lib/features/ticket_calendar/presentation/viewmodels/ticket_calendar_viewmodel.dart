import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ticket_repository.dart';
import '../../domain/meal_ticket_model.dart';

final ticketCalendarViewModelProvider =
    StateNotifierProvider<TicketCalendarViewModel, AsyncValue<List<MealTicket>>>((ref) {
  final repo = ref.watch(ticketRepositoryProvider);
  return TicketCalendarViewModel(repo);
});

class TicketCalendarViewModel extends StateNotifier<AsyncValue<List<MealTicket>>> {
  final TicketRepository _repository;
  final DateTime _passHardExpiryDate = DateTime.now().add(const Duration(days: 10)); // 7-Day pass ceiling

  TicketCalendarViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadTickets();
  }

  Future<void> loadTickets({String userId = 'user_khammam_01'}) async {
    try {
      state = const AsyncValue.loading();
      final tickets = await _repository.fetchActiveUserTickets(userId);
      state = AsyncValue.data(tickets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<String?> skipTicket(String ticketId) async {
    final currentTickets = state.value;
    if (currentTickets == null || currentTickets.isEmpty) return 'No tickets available';

    final targetIndex = currentTickets.indexWhere((t) => t.ticketId == ticketId);
    if (targetIndex == -1) return 'Ticket not found';

    final targetTicket = currentTickets[targetIndex];
    final lastDate = currentTickets.last.deliveryDate;

    try {
      final updatedSkippedTicket = await _repository.skipTomorrowTicket(
        ticketToSkip: targetTicket,
        passHardExpiryDate: _passHardExpiryDate,
        currentQueueLastDate: lastDate,
      );

      // Create new appended ticket at the tail of the queue
      final newTailDate = lastDate.add(const Duration(days: 1));
      final appendedTicket = MealTicket(
        ticketId: 't_${DateTime.now().millisecondsSinceEpoch}',
        passId: targetTicket.passId,
        userId: targetTicket.userId,
        clusterId: targetTicket.clusterId,
        clusterName: targetTicket.clusterName,
        deliveryDate: newTailDate,
        comboSelection: targetTicket.comboSelection,
        addOns: targetTicket.addOns,
        slot: targetTicket.slot,
        status: TicketStatusType.scheduled,
      );

      final updatedList = List<MealTicket>.from(currentTickets);
      updatedList[targetIndex] = updatedSkippedTicket;
      updatedList.add(appendedTicket);

      state = AsyncValue.data(updatedList);
      return null; // Success (no error message)
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> switchTicketCombo(String ticketId, String newCombo) async {
    final currentTickets = state.value;
    if (currentTickets == null) return 'No tickets loaded';

    final index = currentTickets.indexWhere((t) => t.ticketId == ticketId);
    if (index == -1) return 'Ticket not found';

    try {
      final updated = await _repository.switchCombo(
        ticket: currentTickets[index],
        newCombo: newCombo,
      );
      final updatedList = List<MealTicket>.from(currentTickets);
      updatedList[index] = updated;
      state = AsyncValue.data(updatedList);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
