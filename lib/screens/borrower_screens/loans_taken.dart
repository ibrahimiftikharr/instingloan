import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theloanapp/widgets/TextStyles.dart';
import 'package:theloanapp/widgets/appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theloanapp/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyLoansPage extends ConsumerStatefulWidget {
  const MyLoansPage({super.key});

  @override
  ConsumerState<MyLoansPage> createState() => _MyLoansPageState();
}

class _MyLoansPageState extends ConsumerState<MyLoansPage> {
  List<Map<String, dynamic>> currentLoans = [];
  List<Map<String, dynamic>> pastLoans = [];
  bool isLoading = true;
  String? errorMsg;
  int selectedTab = 0; // 0: Current, 1: Past

  @override
  void initState() {
    super.initState();
    _fetchLoansAndIssuePending();
  }

  Future<void> _fetchLoansAndIssuePending() async {
    try {
      await DatabaseService().issueAllPendingLoans();

      final refreshed = await DatabaseService().getBorrowerLoans();

      setState(() {
        currentLoans = refreshed.where((l) => l['status'] != 'completed').toList();
        pastLoans = refreshed.where((l) => l['status'] == 'completed').toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = 'Failed to load or issue loans.';
        isLoading = false;
      });
    }
  }
  
  double get totalBalanceDueThisMonth {
    // Only include loans where the amount repaid is less than the expected amount for the current period
    final now = DateTime.now();
    double totalDue = 0.0;
    for (final l in currentLoans.where((l) => l['status'] == 'approved')) {
      final agreementDate = (l['agreementDate'] as Timestamp?)?.toDate();
      final monthlyPayment = (l['monthlyPayment'] ?? 0.0) as num;
      final loanPeriod = (l['loanPeriod'] ?? 1) as num;
      final amountRepaid = (l['amountRepaid'] ?? 0.0) as num;

      if (agreementDate == null) continue;

      final monthsSinceStart = (now.year - agreementDate.year) * 12 + (now.month - agreementDate.month);
      final currentPeriod = (monthsSinceStart + 1).clamp(1, loanPeriod);

      // Expected repaid till now
      final expectedRepaid = monthlyPayment * currentPeriod;

      // If repaid is less than expected, payment is due this month
      if (amountRepaid < expectedRepaid) {
        totalDue += monthlyPayment;
      }
    }
    return totalDue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar(context, ref),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: myPoppinText('My Loans', FontWeight.bold, 22),
                  ),
                  Container(
                    height: 200,
                    color: const Color(0xFFD5F278),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 18),
                              myPoppinText("TOTAL DUE THIS MONTH", FontWeight.normal, 12),
                              const SizedBox(height: 4),
                              myPoppinText(
                                "\$${totalBalanceDueThisMonth.toStringAsFixed(2)}",
                                FontWeight.w500,
                                32,
                              ),
                              const SizedBox(height: 4),
                              myPoppinText("Due this month", FontWeight.normal, 14),
                            ],
                          ),
                        ),
                        Image.asset("assets/illustration.png", height: 140, fit: BoxFit.contain),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        _tabButton("Current loans", 0),
                        _tabButton("Past loans", 1),
                      ],
                    ),
                  ),
                  if (errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                    ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final loansToShow = selectedTab == 0 ? currentLoans : pastLoans;
                        if (loansToShow.isEmpty) {
                          return Center(
                            child: Text(
                              selectedTab == 1 ? "No past loans" : "No current loans",
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: loansToShow.length,
                          itemBuilder: (context, index) {
                            final loan = loansToShow[index];
                            final repaid = loan['amountRepaid'] ?? 0.0;
                            final total = loan['totalToBePaidBack'] ?? 1.0;
                            final progress = (repaid / total).clamp(0.0, 1.0);

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: AssetImage('assets/apparel.jpg'),
                                    radius: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        context.push('/loan_summary', extra: loan['loanId']);
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          myPoppinText(loan['loanName'] ?? 'Loan', FontWeight.w600, 14),
                                          const SizedBox(height: 4),
                                          myPoppinText(
                                            "\$${(loan['loanAmount'] ?? 0.0).toStringAsFixed(2)}",
                                            FontWeight.normal,
                                            13,
                                          ),
                                          const SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value: progress,
                                            backgroundColor: Colors.grey[300],
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.green.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Icon(
                                        loan['status'] == 'approved'
                                            ? Icons.check_circle
                                            : loan['status'] == 'completed'
                                            ? Icons.done_all
                                            : Icons.hourglass_bottom,
                                        color: loan['status'] == 'approved'
                                            ? Colors.green
                                            : loan['status'] == 'completed'
                                            ? Colors.blue
                                            : Colors.orange,
                                        size: 18,
                                      ),
                                      myPoppinText(
                                        loan['status'] ?? "",
                                        FontWeight.normal,
                                        12,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _tabButton(String label, int tabIndex) {
    final isSelected = selectedTab == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = tabIndex;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}