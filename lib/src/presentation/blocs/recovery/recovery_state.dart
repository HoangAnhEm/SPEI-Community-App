part of 'recovery_cubit.dart';

abstract class RecoveryState {}

class RecoveryInitial extends RecoveryState {}

class RecoveryLoading extends RecoveryState {}

class RecoveryOtpRequested extends RecoveryState {}

class RecoveryOtpVerified extends RecoveryState {
  final User user;
  RecoveryOtpVerified(this.user);
}

class RecoveryResendSuccess extends RecoveryState {}

class RecoverySuccess extends RecoveryState {}

class RecoveryFailure extends RecoveryState {
  final String error;
  RecoveryFailure(this.error);
}
