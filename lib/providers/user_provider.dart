import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A provider to manage the current user state
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  // Set the current user
  void setUser(User? user) {
    state = user;
  }

  // Clear the current user (e.g., on logout)
  void clearUser() {
    state = null;
  }
}
