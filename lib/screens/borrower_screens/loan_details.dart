import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:theloanapp/widgets/custom_buttons.dart';
import 'package:theloanapp/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanSummaryScreen extends StatefulWidget {
  final String loanId;
  const LoanSummaryScreen({super.key, required this.loanId});

  @override
  State<LoanSummaryScreen> createState() => _LoanSummaryScreenState();
}

class _LoanSummaryScreenState extends State<LoanSummaryScreen> {
  Map<String, dynamic>? loanData;
  bool isLoading = true;
  String? errorMsg;
  String? walletId;
  double? walletBalance;

  @override
  void initState() {
    super.initState();
    _fetchLoan();
  }

  Future<void> _fetchLoan() async {
    try {
      final data = await DatabaseService().getLoanDetails(widget.loanId);
      final walletDetails = await DatabaseService().getWalletDetails();
      setState(() {
        loanData = data;
        walletId = walletDetails['walletId']?.toString() ?? "N/A";
        walletBalance = walletDetails['walletBalance'] != null
            ? (walletDetails['walletBalance'] as num).toDouble()
            : null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = 'Failed to load loan details';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (loanData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Loan Summary")),
        body: Center(child: Text(errorMsg ?? "No loan data")),
      );
    }
    final principal = loanData!['loanAmount'] ?? 0.0;
    final interestRate = loanData!['interestRate'] ?? 0.0;
    final period = loanData!['loanPeriod'] ?? 1;
    final agreementDate = (loanData!['agreementDate'] as Timestamp?)?.toDate();
    final agreementDateStr = agreementDate != null ? "${agreementDate.day} ${_monthName(agreementDate.month)}, ${agreementDate.year}" : "-";
    final monthlyPayment = loanData!['monthlyPayment'] ?? 0.0;
    final status = loanData!['status'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan Summary"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 17,),
                    Flexible(
                      flex: 0,
                      child: Image.asset(
                        'assets/coin_stack.png',
                        height: constraints.maxHeight * 0.25,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 40,),
                    if (status == 'pending')
                      const Text(
                        "Loan not approved yet.",
                        style: TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    if (status != 'pending')
                      const Text(
                        "Early and one time payment increases your loan limit and makes you eligible for higher amounts.",
                        style: TextStyle(fontSize: 14),
                      ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Wallet",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Wallet ID: $walletId"),
                          if (walletBalance != null) Text("Wallet Balance: \$${walletBalance!.toStringAsFixed(2)}"),
                          const Divider(),
                          buildRow("Borrowed Amount", "\$${principal.toStringAsFixed(2)}"),
                          buildRow("Interest rate/month", "${interestRate.toStringAsFixed(2)}%"),
                          buildRow("Period", "$period Months"),
                          buildRow("Agreement date", agreementDateStr),
                          buildRow("Monthly payment", "\$${monthlyPayment.toStringAsFixed(2)}"),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total payment to make", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("\$${monthlyPayment.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (status != 'pending')
                      CustomButton('Make Payment', () {
                        context.push('/loan_repayment', extra: widget.loanId);
                      }),
                    const SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), Text(value)],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}