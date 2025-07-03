import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theloanapp/widgets/TextStyles.dart';
import 'package:theloanapp/services/database_service.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  Future<Map<String, dynamic>> _fetchRewards() async {
    final userData = await DatabaseService().getWalletDetails();
    final investmentData = await DatabaseService().getInvestorStats();

    return {
      'walletBalance': userData['walletBalance'] ?? 0.0,
      'totalInvested': investmentData['totalInvested'] ?? 0.0,
      'totalPaidBack': investmentData['totalPaidBack'] ?? 0.0,
      'totalProfit': investmentData['totalProfit'] ?? 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: myPoppinText("Rewards Summary", FontWeight.bold, 20.sp),
        backgroundColor: const Color(0xFFFCFCFC),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchRewards(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Image.asset('assets/sofa_sitting.png', height: 250.h),
                  SizedBox(height: 15.h),
                  myPoppinText("Overview", FontWeight.w600, 18.sp),
                  SizedBox(height: 50.h),
                  _rewardCard("Wallet Balance", "\$${(data['walletBalance'] as num).toStringAsFixed(2)}", const Color(0xFF77BEF6FF)),
                  SizedBox(height: 12.h),
                  _rewardCard("Total Invested", "\$${(data['totalInvested'] as num).toStringAsFixed(2)}", Colors.blue.shade100),
                  SizedBox(height: 12.h),
                  _rewardCard("Total Paid Back", "\$${(data['totalPaidBack'] as num).toStringAsFixed(2)}", Colors.green.shade100),
                  SizedBox(height: 12.h),
                  _rewardCard("Profit Earned", "\$${(data['totalProfit'] as num).toStringAsFixed(2)}", const Color(0xFFD8F474)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _rewardCard(String label, String amount, Color bgColor) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          myPoppinText(label, FontWeight.w500, 16.sp),
          myPoppinText(amount, FontWeight.bold, 18.sp),
        ],
      ),
    );
  }
}