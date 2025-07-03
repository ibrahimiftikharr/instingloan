import 'package:flutter/material.dart';
import 'package:theloanapp/screens/investor_screens/loans.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theloanapp/providers/user_provider.dart';
import 'package:theloanapp/screens/signin_page.dart';
import 'package:theloanapp/services/auth_service.dart';
import 'package:theloanapp/services/database_service.dart';


class InvestorHomePage extends ConsumerStatefulWidget {
  InvestorHomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<InvestorHomePage> {
  String? selectedAmount;
  final List<String> presetAmounts = ['10', '20', '30', '40', '50'];
  bool isInvesting = false;
  String? investError;

  void _selectAmount(String amount) {
    setState(() {
      selectedAmount = amount;
    });
  }

  void _showCustomAmountInput() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => LoanPage(
          initialAmount: selectedAmount ?? '',
          isCustomAmountEntry: true,
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      _selectAmount(result);
    }
  }

  Future<void> _invest() async {
    setState(() {
      isInvesting = true;
      investError = null;
    });
    try {
      final amount = double.tryParse(selectedAmount ?? '');
      if (amount == null || amount <= 0) {
        throw Exception("Invalid amount");
      }
      // Deduct from wallet and update totalInvested
      await DatabaseService().pledgeInvestment(amount);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: myPoppinText(
            "Investment Successful",
            FontWeight.w600,
            18,
          ),
          content: myPoppinText(
            "You invested \$$selectedAmount",
            FontWeight.w500,
            16,
          ),
          actions: [
            TextButton(
              child: myPoppinText(
                "OK",
                FontWeight.w500,
                16,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        investError = e.toString();
      });
    } finally {
      setState(() {
        isInvesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: const Icon(Icons.arrow_back),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout(context, ref);
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SigninPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.asset("assets/logo_banner.png", fit: BoxFit.contain),
                  const SizedBox(height: 20),
                  myPoppinText(
                    "Choose your investment amount",
                    FontWeight.w600,
                    20,
                  ),
                  const SizedBox(height: 10),
                  myPoppinText(
                    "Invest to earn profitable rates, most attractive in the market. Your ultimate desination.",
                    FontWeight.w400,
                    14,
                  ),
                  const SizedBox(height: 30),
                  // Use Flexible to prevent overflow and allow grid to shrink
                  Flexible(
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 20,
                      shrinkWrap: true,
                      childAspectRatio: 0.95,
                      children: [
                        ...presetAmounts.map((amount) {
                          return LoanAmountBox(
                            label: '\$$amount',
                            icon: Icons.attach_money,
                            isSelected: selectedAmount == amount,
                            onTap: () => _selectAmount(amount),
                          );
                        }),
                        LoanAmountBox(
                          label: "Type the amount",
                          icon: Icons.add,
                          isCustom: true,
                          isSelected:
                          !presetAmounts.contains(selectedAmount ?? ""),
                          onTap: _showCustomAmountInput,
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (investError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(investError!, style: const TextStyle(color: Colors.red)),
                    ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isInvesting
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : myPoppinText("Invest", FontWeight.w500, 16, color: Colors.white),
                    onPressed: (selectedAmount != null && !isInvesting) ? _invest : null,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class LoanAmountBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isCustom;
  final VoidCallback onTap;
  final double iconSize;

  const LoanAmountBox({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.isCustom = false,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isCustom ? const Color(0xFFDDF5B7) : const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: Colors.purple),
              const SizedBox(height: 10),
              myPoppinText(label, FontWeight.w500, 14),
            ],
          ),
        ),
      ),
    );
  }
}