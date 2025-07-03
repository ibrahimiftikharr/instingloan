import 'package:flutter/material.dart';
import 'package:theloanapp/services/auth_service.dart';
import 'package:theloanapp/services/database_service.dart';
import 'package:theloanapp/widgets/custom_fields.dart';
import 'package:theloanapp/widgets/custom_buttons.dart';
import 'package:theloanapp/widgets/TextStyles.dart';
import 'package:theloanapp/screens/Wallet/MoneyReceive.dart';
import 'package:theloanapp/screens/Wallet/MoneySend.dart';
import 'package:theloanapp/screens/Wallet/WalletConnect.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletDashboardScreen extends StatelessWidget {
  const WalletDashboardScreen({super.key});

  Stream<double?> walletBalanceStream() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['walletBalance'] != null
            ? (snapshot.data()!['walletBalance'] as num).toDouble()
            : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5F278),
      appBar: AppBar(
        title: myPoppinText("My Wallet", FontWeight.w500, 18),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        const Icon(Icons.account_balance_wallet, size: 80, color: Colors.white),
                        const SizedBox(height: 16),
                        StreamBuilder<double?>(
                          stream: walletBalanceStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return myPoppinText("Loading...", FontWeight.bold, 24);
                            }
                            if (snapshot.hasError) {
                              return myPoppinText("Error", FontWeight.bold, 24);
                            }
                            if (!snapshot.hasData || snapshot.data == null) {
                              return myPoppinText("No Wallet", FontWeight.bold, 24);
                            }
                            return myPoppinText(
                              "\$ ${snapshot.data!.toStringAsFixed(2)}",
                              FontWeight.normal,
                              24,
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        _walletActionCard(
                          context,
                          icon: Icons.link,
                          title: "Connect Wallet",
                          subtitle: "Set up your wallet ID and balance",
                          color: Colors.green,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ConnectWalletScreen()),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _walletActionCard(
                          context,
                          icon: Icons.send,
                          title: "Money Send",
                          subtitle: "Send money to another wallet",
                          color: Colors.redAccent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => MoneySendScreen()),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _walletActionCard(
                          context,
                          icon: Icons.download,
                          title: "Money Receive",
                          subtitle: "View wallet ID and balance",
                          color: Colors.blueAccent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => MoneyReceiveScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


Widget _walletActionCard(
    BuildContext context, {
      required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap,
    }) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                myPoppinText(title, FontWeight.bold, 16),
                const SizedBox(height: 4),
                myPoppinText(subtitle, FontWeight.normal, 13)
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
}