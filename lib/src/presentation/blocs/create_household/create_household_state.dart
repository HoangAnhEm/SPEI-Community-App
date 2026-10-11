import 'package:equatable/equatable.dart';
import '../../../domain/entities/household.dart';

abstract class CreateHouseholdState extends Equatable {
  const CreateHouseholdState();

  @override
  List<Object?> get props => [];
}

class CreateHouseholdInitial extends CreateHouseholdState {}

class CreateHouseholdLoading extends CreateHouseholdState {}

class CreateHouseholdSuccess extends CreateHouseholdState {
  final Household household;

  const CreateHouseholdSuccess(this.household);

  @override
  List<Object?> get props => [household];
}

class CreateHouseholdFailure extends CreateHouseholdState {
  final String error;

  const CreateHouseholdFailure(this.error);

  @override
  List<Object?> get props => [error];
}
