part of 'register_cubit.dart';

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterInfoSuccess extends RegisterState {}

class RegisterOtpSuccess extends RegisterState {
  final User user;
  RegisterOtpSuccess(this.user);
}

class RegisterResendSuccess extends RegisterState {}

class RegisterFailure extends RegisterState {
  final String error;
  RegisterFailure(this.error);
}
