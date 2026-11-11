import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/driver_repository.dart';
import '../../domain/manifest_stop_model.dart';

final driverManifestViewModelProvider =
    StateNotifierProvider<DriverManifestViewModel, AsyncValue<List<ManifestStop>>>((ref) {
  final repo = ref.watch(driverRepositoryProvider);
  return DriverManifestViewModel(repo);
});

class DriverManifestViewModel extends StateNotifier<AsyncValue<List<ManifestStop>>> {
  final DriverRepository _repository;

  DriverManifestViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadManifest();
  }

  Future<void> loadManifest({String driverId = 'driver_khammam_01'}) async {
    try {
      state = const AsyncValue.loading();
      final stops = await _repository.fetchTodayManifest(driverId);
      state = AsyncValue.data(stops);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> sendBatchBroadcast(String clusterId) async {
    final currentStops = state.value;
    if (currentStops == null) return false;

    final index = currentStops.indexWhere((s) => s.clusterId == clusterId);
    if (index == -1) return false;

    try {
      await _repository.broadcastBatchArrival(clusterId);
      final updatedList = List<ManifestStop>.from(currentStops);
      updatedList[index] = updatedList[index].copyWith(isBroadcastSent: true);
      state = AsyncValue.data(updatedList);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> completeStopWithProof({
    required String clusterId,
    required String proofPhotoUrl,
  }) async {
    final currentStops = state.value;
    if (currentStops == null) return false;

    final index = currentStops.indexWhere((s) => s.clusterId == clusterId);
    if (index == -1) return false;

    try {
      final updatedStop = await _repository.completeStopWithPhotoProof(
        stop: currentStops[index],
        photoUrl: proofPhotoUrl,
      );

      final updatedList = List<ManifestStop>.from(currentStops);
      updatedList[index] = updatedStop;
      state = AsyncValue.data(updatedList);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markOutForDelivery(String clusterId) async {
    final currentStops = state.value;
    if (currentStops == null) return false;

    final index = currentStops.indexWhere((s) => s.clusterId == clusterId);
    if (index == -1) return false;

    try {
      final updatedStop = await _repository.markOutForDelivery(currentStops[index]);
      final updatedList = List<ManifestStop>.from(currentStops);
      updatedList[index] = updatedStop;
      state = AsyncValue.data(updatedList);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markDeliveryFailed({
    required String clusterId,
    required DeliveryFailureReason reason,
  }) async {
    final currentStops = state.value;
    if (currentStops == null) return false;

    final index = currentStops.indexWhere((s) => s.clusterId == clusterId);
    if (index == -1) return false;

    try {
      final updatedStop = await _repository.markDeliveryFailed(
        stop: currentStops[index],
        reason: reason,
      );
      final updatedList = List<ManifestStop>.from(currentStops);
      updatedList[index] = updatedStop;
      state = AsyncValue.data(updatedList);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reAttemptDelivery(String clusterId) async {
    final currentStops = state.value;
    if (currentStops == null) return false;

    final index = currentStops.indexWhere((s) => s.clusterId == clusterId);
    if (index == -1) return false;

    try {
      final updatedStop = await _repository.reAttemptDelivery(currentStops[index]);
      final updatedList = List<ManifestStop>.from(currentStops);
      updatedList[index] = updatedStop;
      state = AsyncValue.data(updatedList);
      return true;
    } catch (_) {
      return false;
    }
  }
}
