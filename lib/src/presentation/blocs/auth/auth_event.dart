abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthStatusChanged extends AuthEvent {}
