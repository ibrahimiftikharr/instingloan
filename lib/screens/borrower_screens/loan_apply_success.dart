import 'package:flutter/material.dart';
import 'package:theloanapp/widgets/TextStyles.dart';
import 'package:theloanapp/widgets/custom_buttons.dart';

class LoanSuccessScreen extends StatelessWidget {
  final String loanType;
  final String period;
  final double amount;
  final DateTime submissionTime;

  const LoanSuccessScreen({
    super.key,
    required this.loanType,
    required this.period,
    required this.amount,
    required this.submissionTime,
  });

  @override
  Widget build(BuildContext context) {

    final safeLoanType = loanType;
    final safePeriod = period;
    final safeAmount = amount;
    final safeSubmissionTime = submissionTime ?? DateTime.now();

    final formattedDate = "${safeSubmissionTime.day.toString().padLeft(2, '0')} "
        "${_monthName(safeSubmissionTime.month)} ${safeSubmissionTime.year} "
        "${safeSubmissionTime.hour.toString().padLeft(2, '0')}:${safeSubmissionTime.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: Colors.lightGreen,
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const Spacer(),
                            const Icon(Icons.refresh, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                                const SizedBox(height: 16),
                                myPoppinText("Successful", FontWeight.bold, 24),
                                const SizedBox(height: 8),
                                myPoppinText(
                                  "Your loan request has been submitted, please check regularly through this application.",
                                  FontWeight.normal,
                                  14,
                                ),
                                const SizedBox(height: 8),
                                myPoppinText(
                                  formattedDate,
                                  FontWeight.normal,
                                  12,
                                ),
                                const SizedBox(height: 30),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: myPoppinText("Request loan for", FontWeight.normal, 14),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Colors.green,
                                        child: Icon(Icons.school, color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          myPoppinText(
                                            safeLoanType,
                                            FontWeight.bold,
                                            14,
                                          ),
                                          const SizedBox(height: 4),
                                          myPoppinText(
                                            "for period $safePeriod",
                                            FontWeight.normal,
                                            12,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                myPoppinText("Total Loan", FontWeight.normal, 14),
                                const SizedBox(height: 8),
                                myPoppinText(
                                  "\$${safeAmount.toStringAsFixed(0)}",
                                  FontWeight.bold,
                                  32,
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: CustomButton('Continue', (){
                            Navigator.pop(context);
                          }
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

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }
}