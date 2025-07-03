import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:theloanapp/providers/user_provider.dart';
import 'package:theloanapp/widgets/TextStyles.dart';
import 'package:go_router/go_router.dart';
import 'package:theloanapp/widgets/custom_buttons.dart';
import 'package:theloanapp/services/database_service.dart';

class CreateLoanRequestScreen extends ConsumerStatefulWidget {
  const CreateLoanRequestScreen({super.key, required this.loanType});
  final String loanType;

  @override
  ConsumerState<CreateLoanRequestScreen> createState() => _CreateLoanRequestScreenState();
}

class _CreateLoanRequestScreenState extends ConsumerState<CreateLoanRequestScreen> {
  String selectedPeriod = '12 Month';
  double loanAmount = 1000;
  bool dataCorrect = true;
  bool isLoading = false;
  String? errorMsg;

  // For demonstration, use a fixed interest rate. In production, fetch from backend/config.
  final double interestRate = 2.5;

  int get periodMonths {
    switch (selectedPeriod) {
      case '6 Month':
        return 6;
      case '12 Month':
        return 12;
      case '24 Month':
        return 24;
      default:
        return 12;
    }
  }

  double get totalToBePaidBack => loanAmount + (loanAmount * interestRate / 100);
  double get monthlyPayment => totalToBePaidBack / periodMonths;

  Future<void> _submitLoanRequest() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      await DatabaseService().createLoanApplication(
        widget.loanType,
        loanAmount,
        periodMonths,
        interestRate,
      );
      context.push('/loanSuccess', extra: {
        'loanType': widget.loanType,
        'period': selectedPeriod,
        'amount': loanAmount,
        'submissionTime': DateTime.now(),
      });
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final User? currentUser = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.go('/borrowerNavigation');
          },
        ),
        title: myPoppinText('Application for ${widget.loanType}', FontWeight.w500, 16),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: myPoppinText('Create Loan Request', FontWeight.bold, 22)),
              const SizedBox(height: 20),

              // Loan Type Display
              myPoppinText("Loan Name", FontWeight.w600, 14),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.loanType),
              ),
              const SizedBox(height: 15),

              // Period Dropdown
              myPoppinText("Period", FontWeight.w600, 14),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: selectedPeriod,
                items: ['6 Month', '12 Month', '24 Month']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPeriod = value!;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              myPoppinText("How much money you need?", FontWeight.w600, 14),
              const SizedBox(height: 10),
              Center(
                child: myPoppinText("\$${loanAmount.toStringAsFixed(0)}", FontWeight.bold, 22),
              ),
              Slider(
                value: loanAmount,
                onChanged: (value) {
                  setState(() {
                    loanAmount = value;
                  });
                },
                min: 345,
                max: 10000,
                divisions: (10000 - 345).toInt(),
                label: "\$${loanAmount.toStringAsFixed(0)}",
              ),

              // Data Correct Checkbox
              CheckboxListTile(
                value: dataCorrect,
                onChanged: (value) {
                  setState(() {
                    dataCorrect = value!;
                  });
                },
                title: myPoppinText("Data I entered is correct", FontWeight.normal, 14),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),

              // Monthly Payment Display (dynamic)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    myPoppinText("Monthly Payment", FontWeight.normal, 14),
                    const SizedBox(height: 8),
                    myPoppinText("\$${monthlyPayment.toStringAsFixed(2)}", FontWeight.bold, 24),
                    const SizedBox(height: 4),
                    myPoppinText("Interest ${interestRate.toStringAsFixed(1)}%", FontWeight.normal, 14)
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Error message display
              if (errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(errorMsg!, style: TextStyle(color: Colors.red)),
                ),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                  'Save',
                      () {
                    if (dataCorrect) _submitLoanRequest();
                  },
                ),

              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}