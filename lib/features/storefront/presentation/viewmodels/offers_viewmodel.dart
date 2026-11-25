import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../../domain/offer_model.dart';

final offersProvider = StateNotifierProvider<OffersViewModel, List<OfferModel>>((ref) {
  return OffersViewModel();
});

class OffersViewModel extends StateNotifier<List<OfferModel>> {
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  OffersViewModel() : super(OfferModel.defaultOffers) {
    _subscribeToLiveOffers();
  }

  void _subscribeToLiveOffers() {
    try {
      _subscription = FirebaseService.instance.streamOffers().listen(
        (rawList) {
          if (rawList.isNotEmpty) {
            final parsed = rawList
                .map((m) => OfferModel.fromMap(m, docId: m['id'] as String?))
                .where((o) => o.isActive && o.code.isNotEmpty)
                .toList();
            if (parsed.isNotEmpty) {
              state = parsed;
            }
          }
        },
        onError: (e) {
          debugPrint('⚠️ [OffersViewModel] Stream error: $e');
        },
      );
    } catch (e) {
      debugPrint('⚠️ [OffersViewModel] Init error: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
