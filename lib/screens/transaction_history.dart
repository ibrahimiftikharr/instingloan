import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theloanapp/widgets/TextStyles.dart';
import 'package:theloanapp/services/database_service.dart'; // Import DatabaseService

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final DatabaseService _databaseService = DatabaseService(); // Initialize DatabaseService
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try
    {
      final fetchedTransactions = await _databaseService.getTransactionHistory();
      setState(() {
        transactions = fetchedTransactions;
        isLoading = false;
      });
    }
    catch (e)
    {
      setState(()
      {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching transactions: ${e.toString()}')),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: myPoppinText("Transaction History", FontWeight.bold, 20.sp),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : transactions.isEmpty
                ? Center(child: myPoppinText("No transactions found.", FontWeight.normal, 16.sp))
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset('assets/pen_paper.png', height: 250.h),
                          SizedBox(height: 15.h),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: transactions.length,
                            separatorBuilder: (context, index) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final txn = transactions[index];
                              final amount = (txn["amount"] is int)
                                  ? (txn["amount"] as int).toDouble()
                                  : (txn["amount"] ?? 0.0);
                              final purpose = txn["purpose"] ?? "N/A";
                              final direction = txn["direction"] ?? "N/A";
                              return Container(
                                padding: EdgeInsets.all(7.w),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF4F4F4),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: myPoppinText(
                                        purpose,
                                        FontWeight.w500,
                                        16.sp,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        myPoppinText("\$${amount.toStringAsFixed(2)}", FontWeight.bold, 16.sp),
                                        Text(
                                          direction == "In" ? "Credit" : "Debit",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.sp,
                                            color: direction == "In" ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}