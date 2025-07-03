import 'package:flutter/material.dart';
import 'package:theloanapp/widgets/TextStyles.dart';
import 'package:theloanapp/widgets/custom_fields.dart';
import 'package:theloanapp/widgets/custom_buttons.dart';
import 'package:theloanapp/services/database_service.dart';

class ConnectWalletScreen extends StatefulWidget {
  @override
  _ConnectWalletScreenState createState() => _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends State<ConnectWalletScreen> {
  final TextEditingController walletIdController = TextEditingController();
  final TextEditingController initialBalanceController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  bool isLoading = true;
  bool walletExists = false;
  String walletId = '';
  double walletBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _checkWallet();
  }

  Future<void> _checkWallet() async {
    try {
      final walletDetails = await _databaseService.getWalletDetails();
      if (walletDetails['walletId'] != null) {
        setState(() {
          walletExists = true;
          walletId = walletDetails['walletId'];
          walletBalance = walletDetails['walletBalance'] ?? 0.0;
          isLoading = false;
        });
      } else {
        setState(() {
          walletExists = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        walletExists = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: myPoppinText("Connect Wallet", FontWeight.w500, 18),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (walletExists) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: myPoppinText("Wallet Connected", FontWeight.w500, 18),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet, size: 64, color: Color(0xFFD5F278)),
                const SizedBox(height: 24),
                myPoppinText("Wallet ID", FontWeight.w500, 14),
                const SizedBox(height: 8),
                SelectableText(walletId, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                myPoppinText("Current Balance: \$${walletBalance.toStringAsFixed(2)}", FontWeight.w500, 14),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _databaseService.deleteWallet();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Wallet deleted successfully!')),
                      );
                      _checkWallet(); // Refresh UI
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete Wallet'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If wallet does not exist, show connect form
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: myPoppinText("Connect Wallet", FontWeight.w500, 18),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 64, color: Color(0xFFD5F278)),
                    const SizedBox(height: 40),
                    CustomField('Wallet ID', false, walletIdController),
                    const SizedBox(height: 16),
                    CustomField('Initialize Balance', false, initialBalanceController),
                    const SizedBox(height: 40),
                    CustomButton("Save & Connect", () async {
                      final walletId = walletIdController.text.trim();
                      final initialBalance = double.tryParse(initialBalanceController.text.trim()) ?? 0.0;

                      if (walletId.isNotEmpty && initialBalance >= 0) {
                        try {
                          await _databaseService.connectWallet(walletId, initialBalance);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Wallet connected successfully!')),
                          );
                          _checkWallet(); // Refresh UI
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter valid details.')),
                        );
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}