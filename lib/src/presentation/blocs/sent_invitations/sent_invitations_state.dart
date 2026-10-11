import 'package:equatable/equatable.dart';
import '../../../domain/entities/household_invitation.dart';

abstract class SentInvitationsState extends Equatable {
  const SentInvitationsState();

  @override
  List<Object?> get props => [];
}

class SentInvitationsInitial extends SentInvitationsState {}

class SentInvitationsLoading extends SentInvitationsState {}

class SentInvitationsLoaded extends SentInvitationsState {
  final List<HouseholdInvitation> invitations;
  final String? actionMessage;
  final bool isActionLoading;

  const SentInvitationsLoaded({
    required this.invitations,
    this.actionMessage,
    this.isActionLoading = false,
  });

  SentInvitationsLoaded copyWith({
    List<HouseholdInvitation>? invitations,
    String? actionMessage,
    bool? isActionLoading,
  }) {
    return SentInvitationsLoaded(
      invitations: invitations ?? this.invitations,
      actionMessage: actionMessage,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [invitations, actionMessage, isActionLoading];
}

class SentInvitationsFailure extends SentInvitationsState {
  final String error;

  const SentInvitationsFailure(this.error);

  @override
  List<Object?> get props => [error];
}
