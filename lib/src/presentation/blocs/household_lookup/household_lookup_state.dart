import 'package:equatable/equatable.dart';
import '../../../domain/entities/household_lookup_result.dart';

abstract class HouseholdLookupState extends Equatable {
  const HouseholdLookupState();

  @override
  List<Object?> get props => [];
}

class HouseholdLookupInitial extends HouseholdLookupState {}

class HouseholdLookupLoading extends HouseholdLookupState {}

class HouseholdLookupSuccess extends HouseholdLookupState {
  final HouseholdLookupResult result;
  final bool isJoining;
  final bool joinSuccess;
  final String? joinError;

  const HouseholdLookupSuccess({
    required this.result,
    this.isJoining = false,
    this.joinSuccess = false,
    this.joinError,
  });

  HouseholdLookupSuccess copyWith({
    HouseholdLookupResult? result,
    bool? isJoining,
    bool? joinSuccess,
    String? joinError,
  }) {
    return HouseholdLookupSuccess(
      result: result ?? this.result,
      isJoining: isJoining ?? this.isJoining,
      joinSuccess: joinSuccess ?? this.joinSuccess,
      joinError: joinError,
    );
  }

  @override
  List<Object?> get props => [result, isJoining, joinSuccess, joinError];
}

class HouseholdLookupFailure extends HouseholdLookupState {
  final String error;

  const HouseholdLookupFailure(this.error);

  @override
  List<Object?> get props => [error];
}
