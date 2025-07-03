import 'package:flutter/material.dart';
import 'package:theloanapp/widgets/TextStyles.dart';
import 'package:theloanapp/services/database_service.dart';

class MoneyReceiveScreen extends StatefulWidget {
  @override
  _MoneyReceiveScreenState createState() => _MoneyReceiveScreenState();
}

class _MoneyReceiveScreenState extends State<MoneyReceiveScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String walletId = "";
  double currentBalance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWalletDetails();
  }

  Future<void> _fetchWalletDetails() async {
    try {

      final walletDetails = await _databaseService.getWalletDetails();
      setState(() {
        walletId = walletDetails['walletId'] ?? "N/A";
        currentBalance = walletDetails['walletBalance'] ?? 0.0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching wallet details: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: myPoppinText("MoneyReceive", FontWeight.w500, 18),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_balance_wallet, size: 64, color: Color(0xFFD5F278)),
                          const SizedBox(height: 24),
                          myPoppinText("Your Wallet ID", FontWeight.w500, 14),
                          const SizedBox(height: 8),
                          SelectableText(
                            walletId,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          myPoppinText("Current Balance: \$${currentBalance.toStringAsFixed(2)}", FontWeight.w500, 14),
                          const SizedBox(height: 24),
                          myPoppinText(
                            "Share your Wallet ID to receive money.",
                            FontWeight.normal,
                            14,
                          ),
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