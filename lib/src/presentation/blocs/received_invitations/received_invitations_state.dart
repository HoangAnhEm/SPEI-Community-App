import 'package:equatable/equatable.dart';
import '../../../domain/entities/household_invitation.dart';

abstract class ReceivedInvitationsState extends Equatable {
  const ReceivedInvitationsState();

  @override
  List<Object?> get props => [];
}

class ReceivedInvitationsInitial extends ReceivedInvitationsState {}

class ReceivedInvitationsLoading extends ReceivedInvitationsState {}

class ReceivedInvitationsLoaded extends ReceivedInvitationsState {
  final List<HouseholdInvitation> invitations;
  final String? actionMessage;
  final bool isActionLoading;

  const ReceivedInvitationsLoaded({
    required this.invitations,
    this.actionMessage,
    this.isActionLoading = false,
  });

  ReceivedInvitationsLoaded copyWith({
    List<HouseholdInvitation>? invitations,
    String? actionMessage,
    bool? isActionLoading,
  }) {
    return ReceivedInvitationsLoaded(
      invitations: invitations ?? this.invitations,
      actionMessage: actionMessage,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [invitations, actionMessage, isActionLoading];
}

class ReceivedInvitationsFailure extends ReceivedInvitationsState {
  final String error;

  const ReceivedInvitationsFailure(this.error);

  @override
  List<Object?> get props => [error];
}
