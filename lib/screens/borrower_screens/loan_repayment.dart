import 'package:flutter/material.dart';
import 'package:theloanapp/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanRepaymentScreen extends StatefulWidget {
  final String loanId;
  const LoanRepaymentScreen({super.key, required this.loanId});

  @override
  State<LoanRepaymentScreen> createState() => _LoanRepaymentScreenState();
}

class _LoanRepaymentScreenState extends State<LoanRepaymentScreen> {
  Map<String, dynamic>? loanData;
  bool isLoading = true;
  bool isPaying = false;
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
      // Fetch wallet details from database_service
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

  Future<void> _payNow() async {
    if (loanData == null) return;
    setState(() {
      isPaying = true;
      errorMsg = null;
    });
    try {
      final due = (loanData!['monthlyPayment'] ?? 0.0) as double;
      await DatabaseService().makeRepayment(widget.loanId, due);
      await _fetchLoan();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Repayment successful')));
    } catch (e) {
      setState(() {
        errorMsg = 'Payment failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        isPaying = false;
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
        appBar: AppBar(title: const Text("Review Summary")),
        body: Center(child: Text(errorMsg ?? "No loan data")),
      );
    }
    final principal = (loanData!['loanAmount'] ?? 0.0) as num;
    final interestRate = (loanData!['interestRate'] ?? 0.0) as num;
    final monthlyPayment = (loanData!['monthlyPayment'] ?? 0.0) as num;
    final monthlyInterest = principal * interestRate / 100;
    final loanPeriod = (loanData!['loanPeriod'] ?? 1) as num;
    final dueDate = (loanData!['agreementDate'] as Timestamp?)?.toDate().add(
      Duration(days: 30),
    );
    final dueDateStr = dueDate != null ? "${dueDate.day}/${dueDate.month}/${dueDate.year}" : "-";
    final repaid = loanData!['amountRepaid'] ?? 0.0;
    final due = monthlyPayment;
    final period = loanPeriod;
    final periodPaid = ((repaid / (monthlyPayment / period)).ceil()).clamp(1, period);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Summary"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Image.asset('assets/illustration.png', height: 250, fit: BoxFit.contain),
                      const SizedBox(height: 70,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("\$${due.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("Repayment Due Date: $dueDateStr"),
                      Text("Loan ID: ${widget.loanId}"),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Period $periodPaid/$period", style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            buildRow("Principal Loan", "\$${principal.toStringAsFixed(2)}"),
                            buildRow("Loan Interest", "\$${monthlyInterest.toStringAsFixed(2)}"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Wallet details section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Wallet"),
                                Text("Wallet ID: $walletId"),
                                if (walletBalance != null) Text("Wallet Balance: \$${walletBalance!.toStringAsFixed(2)}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40,),
                      if (errorMsg != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                        ),
                      ElevatedButton(
                        onPressed: isPaying || due <= 0 ? null : _payNow,
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                        child: isPaying
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text("Pay Now - \$${due.toStringAsFixed(2)}"),
                      ),
                    ],
                  ),
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
}