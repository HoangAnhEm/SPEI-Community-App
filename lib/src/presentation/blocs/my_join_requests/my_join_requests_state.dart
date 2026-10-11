import 'package:equatable/equatable.dart';
import '../../../domain/entities/household_join_request.dart';

abstract class MyJoinRequestsState extends Equatable {
  const MyJoinRequestsState();

  @override
  List<Object?> get props => [];
}

class MyJoinRequestsInitial extends MyJoinRequestsState {}

class MyJoinRequestsLoading extends MyJoinRequestsState {}

class MyJoinRequestsLoaded extends MyJoinRequestsState {
  final List<HouseholdJoinRequest> requests;
  final String? actionMessage;
  final bool isActionLoading;

  const MyJoinRequestsLoaded({
    required this.requests,
    this.actionMessage,
    this.isActionLoading = false,
  });

  MyJoinRequestsLoaded copyWith({
    List<HouseholdJoinRequest>? requests,
    String? actionMessage,
    bool? isActionLoading,
  }) {
    return MyJoinRequestsLoaded(
      requests: requests ?? this.requests,
      actionMessage: actionMessage,
      isActionLoading: isActionLoading ?? this.isActionLoading,
    );
  }

  @override
  List<Object?> get props => [requests, actionMessage, isActionLoading];
}

class MyJoinRequestsFailure extends MyJoinRequestsState {
  final String error;

  const MyJoinRequestsFailure(this.error);

  @override
  List<Object?> get props => [error];
}
