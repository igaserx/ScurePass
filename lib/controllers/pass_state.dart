import 'package:scure_pass/models/password_model.dart';

abstract class PasswordState {}

class PasswordInitial extends PasswordState {}

class PasswordLoading extends PasswordState {}

class PasswordLoaded extends PasswordState {
  final List<PasswordModel> passwords;

  PasswordLoaded(this.passwords);
}

class PasswordError extends PasswordState {
  final String message;

  PasswordError(this.message);
}

class PasswordOperationSuccess extends PasswordState {
  final String message;
  final List<PasswordModel> passwords;

  PasswordOperationSuccess(this.message, this.passwords);
}