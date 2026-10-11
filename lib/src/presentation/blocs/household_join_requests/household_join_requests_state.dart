import 'package:equatable/equatable.dart';
import '../../../domain/entities/household_join_request.dart';

abstract class HouseholdJoinRequestsState extends Equatable {
  const HouseholdJoinRequestsState();

  @override
  List<Object?> get props => [];
}

class HouseholdJoinRequestsInitial extends HouseholdJoinRequestsState {}

class HouseholdJoinRequestsLoading extends HouseholdJoinRequestsState {}

class HouseholdJoinRequestsLoaded extends HouseholdJoinRequestsState {
  final List<HouseholdJoinRequest> requests;
  final String? actionMessage;
  final bool isActionLoading;

  const HouseholdJoinRequestsLoaded({
    required this.requests,
    this.actionMessage,
    this.isActionLoading = false,
  });

  HouseholdJoinRequestsLoaded copyWith({
    List<HouseholdJoinRequest>? requests,
    String? actionMessage,
    bool? isActionLoading,
  }) {
    return HouseholdJoinRequestsLoaded(
      requests: requests ?? this.requests,
      actionMessage: actionMessage,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [requests, actionMessage, isActionLoading];
}

class HouseholdJoinRequestsFailure extends HouseholdJoinRequestsState {
  final String error;

  const HouseholdJoinRequestsFailure(this.error);

  @override
  List<Object?> get props => [error];
}
