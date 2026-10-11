import 'package:equatable/equatable.dart';
import '../../../domain/entities/household.dart';
import '../../../domain/entities/household_invitation.dart';
import '../../../domain/entities/household_join_request.dart';

enum HouseholdStatus { initial, loading, loaded, error }

class HouseholdState extends Equatable {
  final HouseholdStatus status;
  final Household? household;
  final String? currentUserId;
  final List<HouseholdInvitation> sentInvitations;
  final List<HouseholdInvitation> receivedInvitations;
  final List<HouseholdJoinRequest> incomingJoinRequests;
  final List<HouseholdJoinRequest> myJoinRequests;
  final String? errorMessage;
  final bool isActionLoading;

  const HouseholdState({
    this.status = HouseholdStatus.initial,
    this.household,
    this.currentUserId,
    this.sentInvitations = const [],
    this.receivedInvitations = const [],
    this.incomingJoinRequests = const [],
    this.myJoinRequests = const [],
    this.errorMessage,
    this.isActionLoading = false,
  });

  bool get hasHousehold => household != null;
  bool get isFreeUser => household == null;

  bool get isOwner {
    if (household == null || currentUserId == null) return false;
    return household!.members.any((m) => m.userId == currentUserId && m.isOwner);
  }

  bool get isMember {
    if (household == null || currentUserId == null) return false;
    return household!.members.any((m) => m.userId == currentUserId && m.isMember);
  }

  HouseholdMember? get myMembership {
    if (household == null || currentUserId == null) return null;
    for (final m in household!.members) {
      if (m.userId == currentUserId) return m;
    }
    return null;
  }

  HouseholdMember? get ownerMember => household?.owner;

  int get receivedInvitationsCount => receivedInvitations.length;
  int get sentInvitationsCount => sentInvitations.length;
  int get incomingJoinRequestsCount => incomingJoinRequests.length;
  int get myJoinRequestsCount => myJoinRequests.length;

  HouseholdState copyWith({
    HouseholdStatus? status,
    Household? Function()? household,
    String? currentUserId,
    List<HouseholdInvitation>? sentInvitations,
    List<HouseholdInvitation>? receivedInvitations,
    List<HouseholdJoinRequest>? incomingJoinRequests,
    List<HouseholdJoinRequest>? myJoinRequests,
    String? errorMessage,
    bool? isActionLoading,
  }) {
    return HouseholdState(
      status: status ?? this.status,
      household: household != null ? household() : this.household,
      currentUserId: currentUserId ?? this.currentUserId,
      sentInvitations: sentInvitations ?? this.sentInvitations,
      receivedInvitations: receivedInvitations ?? this.receivedInvitations,
      incomingJoinRequests: incomingJoinRequests ?? this.incomingJoinRequests,
      myJoinRequests: myJoinRequests ?? this.myJoinRequests,
      errorMessage: errorMessage,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        household,
        currentUserId,
        sentInvitations,
        receivedInvitations,
        incomingJoinRequests,
        myJoinRequests,
        errorMessage,
        isActionLoading,
      ];
}
