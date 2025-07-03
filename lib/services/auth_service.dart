import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theloanapp/providers/user_provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:theloanapp/widgets/scaffold.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmail(
      String email,
      String password,
      String role,
      BuildContext context,
      WidgetRef ref,
      ) async {
    try {
      email = email.trim();
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).set({
          'email': email,
          'role': role,
          'walletBalance': 0.0,
        });

        ref.read(userProvider.notifier).setUser(user);
      }
      return user;
    } catch (e) {
      print("SIGNUP ERROR: ${e.toString()}");
      scaffold(e.toString(), context);
      return null;
    }
  }

  Future<User?> signInWithEmail(
      String email,
      String password,
      BuildContext context,
      WidgetRef ref,
      ) async {
    try {
      email = email.trim();
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        ref.read(userProvider.notifier).setUser(user);
        return user;
      }

    } catch (e) {
      print("SIGNIN ERROR: ${e.toString()}");
      scaffold(e.toString(), context);
      return null;
    }
  }

  String? getCurrentUserId() {
    return firebaseAuth.currentUser?.uid;
  }

  Future<void> logout(BuildContext context, WidgetRef ref) async {
    try {
      await firebaseAuth.signOut();
      ref.read(userProvider.notifier).clearUser();
      print('User logged out successfully');
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
