import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theloanapp/screens/borrower_screens/BorrowerNavigation.dart';
import 'package:theloanapp/screens/investor_screens/InvestorNavigation.dart';
import 'package:theloanapp/screens/signin_page.dart';
import 'package:theloanapp/screens/start_screen.dart';

class AuthGate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return StartScreen();
        }
        // User is signed in, fetch role
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return StartScreen();
            }
            final role = userSnapshot.data!['role'];
            if (role == 'Investor') {
              return InvestorNavigation();
            } else if (role == 'Borrower') {
              return BorrowerNavigation();
            } else {
              return StartScreen();
            }
          },
        );
      },
    );
  }
}
