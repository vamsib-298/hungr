import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../storefront/presentation/viewmodels/customer_dashboard_viewmodel.dart';
import '../../../storefront/presentation/widgets/pass_card_3d.dart';
import 'subscription_history_viewmodel.dart';

class ReferralFriend {
  final String name;
  final String cluster;
  final String status;
  final bool hasOrdered;

  const ReferralFriend({
    required this.name,
    required this.cluster,
    required this.status,
    required this.hasOrdered,
  });
}

class ReferralState {
  final String referralCode;
  final int targetCount;
  final bool isRewardClaimed;
  final int qualifiedCount;
  final List<ReferralFriend> friends;

  const ReferralState({
    required this.referralCode,
    this.targetCount = 3,
    required this.isRewardClaimed,
    required this.qualifiedCount,
    required this.friends,
  });

  int get qualifiedOrderCount => friends.isNotEmpty ? friends.where((f) => f.hasOrdered).length : qualifiedCount;
  int get totalInvitedCount => friends.length;
  bool get isRewardUnlocked => qualifiedOrderCount >= targetCount;
  int get remainingOrdersNeeded => (targetCount - qualifiedOrderCount).clamp(0, targetCount);
  double get progressRatio => (qualifiedOrderCount / targetCount).clamp(0.0, 1.0);

  ReferralState copyWith({
    String? referralCode,
    int? targetCount,
    bool? isRewardClaimed,
    int? qualifiedCount,
    List<ReferralFriend>? friends,
  }) {
    return ReferralState(
      referralCode: referralCode ?? this.referralCode,
      targetCount: targetCount ?? this.targetCount,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
      qualifiedCount: qualifiedCount ?? this.qualifiedCount,
      friends: friends ?? this.friends,
    );
  }
}

class ReferralViewModel extends StateNotifier<ReferralState> {
  StreamSubscription<User?>? _authSub;

  ReferralViewModel()
      : super(
          const ReferralState(
            referralCode: 'HUNGR-REF',
            targetCount: 3,
            isRewardClaimed: false,
            qualifiedCount: 0,
            friends: [],
          ),
        ) {
    _listenAuth();
  }

  void _listenAuth() {
    _authSub = FirebaseService.instance.authStateChanges.listen((user) async {
      if (user == null) {
        state = const ReferralState(
          referralCode: 'SIGN-IN',
          targetCount: 3,
          isRewardClaimed: false,
          qualifiedCount: 0,
          friends: [],
        );
        return;
      }

      final data = await FirebaseService.instance.fetchUserReferralData(user.uid);
      final rawFriends = (data['friends'] as List<dynamic>?) ?? const [];
      final parsedFriends = rawFriends
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => ReferralFriend(
                name: (m['name'] as String?) ?? 'Friend',
                cluster: (m['cluster'] as String?) ?? 'Khammam',
                status: (m['hasOrdered'] == true) ? '1st Order Completed' : 'Signed Up • Pending Order',
                hasOrdered: m['hasOrdered'] == true,
              ))
          .toList();

      state = state.copyWith(
        referralCode: (data['referralCode'] as String?) ?? 'HUNGR-REF',
        qualifiedCount: (data['qualifiedOrderCount'] as num?)?.toInt() ?? 0,
        isRewardClaimed: data['isRewardClaimed'] as bool? ?? false,
        friends: parsedFriends,
      );
    });
  }

  Future<bool> claimFree3DayPass({
    required CustomerDashboardViewModel dashboardNotifier,
    required SubscriptionHistoryViewModel historyNotifier,
    required String clusterName,
  }) async {
    if (!state.isRewardUnlocked || state.isRewardClaimed) return false;

    dashboardNotifier.activateNewPass(
      tier: PassTierType.trial3Day,
      combo: 'A',
      addons: {},
    );

    historyNotifier.addSubscription(
      tier: PassTierType.trial3Day,
      combo: 'A',
      addons: {},
      totalAmount: 0,
      clusterName: clusterName,
    );

    state = state.copyWith(isRewardClaimed: true);
    await LocalStorageService.instance.saveReferralState(
      count: state.qualifiedOrderCount,
      isClaimed: true,
    );

    HapticFeedback.heavyImpact();
    return true;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final referralProvider = StateNotifierProvider<ReferralViewModel, ReferralState>((ref) {
  return ReferralViewModel();
});
