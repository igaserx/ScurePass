import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scure_pass/controllers/pass_state.dart';

import 'package:scure_pass/data/repo/passwords_repo.dart';
import 'package:scure_pass/models/password_model.dart';

class PasswordCubit extends Cubit<PasswordState> {
  final PasswordsRepo passRepo;
  final int userId;

  PasswordCubit({
    required this.passRepo,
    required this.userId,
  }) : super(PasswordInitial());

  // Load all passwords
  Future<void> getPasswords() async {
    try {
      emit(PasswordLoading());
      
      final passwords = await passRepo.getPasswords(userId);
      
      emit(PasswordLoaded(passwords));
    } catch (e) {
      emit(PasswordError("Failed to load passwords: ${e.toString()}"));
    }
  }

  // Add new password
  Future<void> addPassword(PasswordModel password) async {
    try {
      await passRepo.addPassword(password);
      await getPasswords();
      
      if (state is PasswordLoaded) {
        final passwords = (state as PasswordLoaded).passwords;
        emit(PasswordOperationSuccess("Password added successfully", passwords));
        
        await Future.delayed(const Duration(milliseconds: 100));
        emit(PasswordLoaded(passwords));
      }
    } catch (e) {
      emit(PasswordError("Failed to add password: ${e.toString()}"));
      await getPasswords();
    }
  }

  // Update password
  Future<void> updatePassword(PasswordModel password) async {
    try {
      await passRepo.updatePassword(password);
      await getPasswords();
      
      if (state is PasswordLoaded) {
        final passwords = (state as PasswordLoaded).passwords;
        emit(PasswordOperationSuccess("Password updated successfully", passwords));
        
        await Future.delayed(const Duration(milliseconds: 100));
        emit(PasswordLoaded(passwords));
      }
    } catch (e) {
      emit(PasswordError("Failed to update password: ${e.toString()}"));
      await getPasswords();
    }
  }

  // Delete password
  Future<void> deletePassword(int passwordId) async {
    try {
      await passRepo.deletePassword(passwordId);
      await getPasswords();
      
      if (state is PasswordLoaded) {
        final passwords = (state as PasswordLoaded).passwords;
        emit(PasswordOperationSuccess("Password deleted successfully", passwords));
        
        await Future.delayed(const Duration(milliseconds: 100));
        emit(PasswordLoaded(passwords));
      }
    } catch (e) {
      emit(PasswordError("Failed to delete password: ${e.toString()}"));
      await getPasswords();
    }
  }

  // Refresh passwords
  Future<void> refresh() async {
    await getPasswords();
  }
}
