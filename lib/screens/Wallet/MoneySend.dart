import 'package:flutter/material.dart';
import 'package:theloanapp/services/auth_service.dart';
import 'package:theloanapp/widgets/TextStyles.dart';
import 'package:theloanapp/widgets/custom_fields.dart';
import 'package:theloanapp/widgets/custom_buttonS.dart';
import 'package:theloanapp/services/database_service.dart';

class MoneySendScreen extends StatelessWidget {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController recipientWalletIdController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: myPoppinText("MoneySend", FontWeight.w500, 18),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send, size: 64, color: Color(0xFFD5F278)),
                    const SizedBox(height: 40),
                    myPoppinText("Enter the amount to send", FontWeight.normal, 14),
                    const SizedBox(height: 16),
                    myFormField(
                      "Amount",
                      amountController,
                      TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    myPoppinText("Enter recipient wallet ID", FontWeight.normal, 14),
                    const SizedBox(height: 16),
                    myFormField(
                      "Recipient Wallet ID",
                      recipientWalletIdController,
                      TextInputType.text,
                    ),
                    const SizedBox(height: 40),
                    CustomButton("Send Money", () async {
                      final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                      final recipientWalletId = recipientWalletIdController.text.trim();

                      if (amount > 0 && recipientWalletId.isNotEmpty) {
                        try {
                          await _databaseService.withdrawFromWallet(amount, recipientWalletId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Money sent successfully!')),
                          );
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