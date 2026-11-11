import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  ReferralFriend copyWith({
    String? name,
    String? cluster,
    String? status,
    bool? hasOrdered,
  }) {
    return ReferralFriend(
      name: name ?? this.name,
      cluster: cluster ?? this.cluster,
      status: status ?? this.status,
      hasOrdered: hasOrdered ?? this.hasOrdered,
    );
  }
}

class ReferralState {
  final String referralCode;
  final int targetCount; // Always 3 members
  final bool isRewardClaimed;
  final List<ReferralFriend> friends;

  const ReferralState({
    required this.referralCode,
    this.targetCount = 3,
    required this.isRewardClaimed,
    required this.friends,
  });

  /// Qualified referrals count strictly requires the friend to complete their 1st order
  int get qualifiedOrderCount => friends.where((f) => f.hasOrdered).length;

  /// Total friends who signed up with user's link
  int get totalInvitedCount => friends.length;

  /// Friends who registered but haven't placed their first morning drop yet
  int get pendingOrdersCount => friends.where((f) => !f.hasOrdered).length;

  bool get isRewardUnlocked => qualifiedOrderCount >= targetCount;
  int get remainingOrdersNeeded => (targetCount - qualifiedOrderCount).clamp(0, targetCount);
  double get progressRatio => (qualifiedOrderCount / targetCount).clamp(0.0, 1.0);

  ReferralState copyWith({
    String? referralCode,
    int? targetCount,
    bool? isRewardClaimed,
    List<ReferralFriend>? friends,
  }) {
    return ReferralState(
      referralCode: referralCode ?? this.referralCode,
      targetCount: targetCount ?? this.targetCount,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
      friends: friends ?? this.friends,
    );
  }
}

class ReferralViewModel extends StateNotifier<ReferralState> {
  ReferralViewModel()
      : super(
          const ReferralState(
            referralCode: 'HUNGR-VK3',
            targetCount: 3,
            isRewardClaimed: false,
            friends: [
              ReferralFriend(name: 'Rahul M.', cluster: 'Sri Sai Boys Hostel Gate', status: '1st Morning Drop Delivered', hasOrdered: true),
              ReferralFriend(name: 'Sneha K.', cluster: 'Hostel Block B Gate', status: '1st Morning Drop Delivered', hasOrdered: true),
              ReferralFriend(name: 'Karthik V.', cluster: 'Bypass Road Gate', status: 'Signed Up • Waiting for 1st Order', hasOrdered: false),
            ],
          ),
        ) {
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final stateData = await LocalStorageService.instance.getReferralState();
    final count = stateData['count'] as int? ?? 2;
    final isClaimed = stateData['isClaimed'] as bool? ?? false;

    final baseFriends = [
      const ReferralFriend(name: 'Rahul M.', cluster: 'Sri Sai Boys Hostel Gate', status: '1st Morning Drop Delivered', hasOrdered: true),
      const ReferralFriend(name: 'Sneha K.', cluster: 'Hostel Block B Gate', status: '1st Morning Drop Delivered', hasOrdered: true),
      ReferralFriend(
        name: 'Karthik V.',
        cluster: 'Bypass Road Gate',
        status: count >= 3 ? '1st Morning Drop Delivered' : 'Signed Up • Waiting for 1st Order',
        hasOrdered: count >= 3,
      ),
    ];

    state = state.copyWith(
      isRewardClaimed: isClaimed,
      friends: baseFriends,
    );
  }

  /// Demo helper: Simulates pending friend completing their first morning order
  void simulateFriendFirstOrder() {
    final pendingIndex = state.friends.indexWhere((f) => !f.hasOrdered);
    if (pendingIndex != -1) {
      final updatedFriends = List<ReferralFriend>.from(state.friends);
      final target = updatedFriends[pendingIndex];
      updatedFriends[pendingIndex] = target.copyWith(
        status: '1st Morning Drop Delivered',
        hasOrdered: true,
      );

      state = state.copyWith(friends: updatedFriends);
      LocalStorageService.instance.saveReferralState(
        count: state.qualifiedOrderCount,
        isClaimed: state.isRewardClaimed,
      );
      HapticFeedback.heavyImpact();
    } else if (state.friends.length < 5) {
      // If all current friends ordered, add a new one who completed 1st order
      const newFriend = ReferralFriend(
        name: 'Pooja T.',
        cluster: 'Main Campus Gate',
        status: '1st Morning Drop Delivered',
        hasOrdered: true,
      );
      final updated = List<ReferralFriend>.from(state.friends)..add(newFriend);
      state = state.copyWith(friends: updated);
      LocalStorageService.instance.saveReferralState(
        count: state.qualifiedOrderCount,
        isClaimed: state.isRewardClaimed,
      );
      HapticFeedback.heavyImpact();
    }
  }

  /// Demo helper: Simulates a friend signing up with referral code
  void simulateFriendSignUp() {
    const newFriend = ReferralFriend(
      name: 'Abhishek R.',
      cluster: 'Near Bus Stand Gate',
      status: 'Signed Up • Waiting for 1st Order',
      hasOrdered: false,
    );
    final updated = List<ReferralFriend>.from(state.friends)..add(newFriend);
    state = state.copyWith(friends: updated);
    HapticFeedback.mediumImpact();
  }

  Future<bool> claimFree3DayPass({
    required CustomerDashboardViewModel dashboardNotifier,
    required SubscriptionHistoryViewModel historyNotifier,
    required String clusterName,
  }) async {
    if (!state.isRewardUnlocked || state.isRewardClaimed) return false;

    // 1. Activate 3-Day Starter Pass for ₹0 in Dashboard
    dashboardNotifier.activateNewPass(
      tier: PassTierType.trial3Day,
      combo: 'A',
      addons: {},
    );

    // 2. Record ₹0 Free Referral Pass in Subscription History
    historyNotifier.addSubscription(
      tier: PassTierType.trial3Day,
      combo: 'A',
      addons: {},
      totalAmount: 0,
      clusterName: clusterName,
    );

    // 3. Mark as Claimed
    state = state.copyWith(isRewardClaimed: true);
    await LocalStorageService.instance.saveReferralState(
      count: state.qualifiedOrderCount,
      isClaimed: true,
    );

    HapticFeedback.heavyImpact();
    return true;
  }
}

final referralProvider = StateNotifierProvider<ReferralViewModel, ReferralState>((ref) {
  return ReferralViewModel();
});
