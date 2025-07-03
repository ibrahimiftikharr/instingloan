import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoanPage extends ConsumerStatefulWidget {
  final String initialAmount;
  final bool isCustomAmountEntry;

  const LoanPage({
    super.key,
    this.initialAmount = '120',
    this.isCustomAmountEntry = false,
  });

  @override
  _LoanPageState createState() => _LoanPageState();
}

class _LoanPageState extends ConsumerState<LoanPage> {
  late String amount;

  @override
  void initState() {
    super.initState();
    amount = widget.initialAmount.isNotEmpty ? widget.initialAmount : '120';
  }

  void _handleNumberPress(String number) {
    setState(() {
      amount = amount == '0' ? number : amount + number;
    });
  }

  void _handleBackspace() {
    setState(() {
      if (amount.isNotEmpty) {
        amount =
            amount.length == 1 ? '0' : amount.substring(0, amount.length - 1);
      }
    });
  }

  void _handleSubmit() {
    if (amount.isNotEmpty && amount != '0') {
      Navigator.of(context).pop(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Decide layout based on screen width
    bool isPC = screenWidth > 800; // You can adjust this threshold

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loan Title
                Center(child: myPoppinText('Loan', FontWeight.w600, 16)),
                const SizedBox(height: 16),

                // Image between 'Loan' and 'Type your loan amount'
                Image.asset(
                  "assets/logo_banner.png", // Update the image path
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 32),

                // Input Label
                myPoppinText(
                  widget.isCustomAmountEntry
                      ? 'Type your custom amount'
                      : 'Type your loan amount',
                  FontWeight.w400,
                  14,
                ),
                // Larger text on PC
                const SizedBox(height: 8),

                // Amount Input Field
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Dollar sign in green
                      myPoppinText(
                        '\$',
                        FontWeight.w600,
                        20.0,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: amount),
                          onChanged: (value) => setState(() => amount = value),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: isPC ? 24 : 20, // Larger font size on PC
                            color: Colors.green,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Or Selected Amount
                Center(
                  child: myPoppinText(
                    'Or Selected amount',
                    FontWeight.w400,
                    isPC ? 20 : 16.0,
                  ), // Larger text on PC
                ),
                const SizedBox(height: 32),

                // Next Button with black background and white text
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.isCustomAmountEntry
                        ? _handleSubmit
                        : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Black background
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: myPoppinText(
                      widget.isCustomAmountEntry ? 'Submit' : 'Next',
                      FontWeight.w600,
                      isPC ? 20 : 16.0,
                      color: Colors.white,
                    ), // Larger text on PC
                  ),
                ),
                const SizedBox(height: 32),

                // Number Pad
                SizedBox(
                  height: screenHeight * 0.4, // Use a percentage of screen height
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isPC ? 4 : 3,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: isPC ? 20 : 16,
                    crossAxisSpacing: isPC ? 20 : 16,
                    padding: EdgeInsets.symmetric(
                      horizontal: isPC ? 64 : 32,
                    ),
                    children: [
                      for (int i = 1; i <= 9; i++)
                        NumberButton(
                          number: i.toString(),
                          onPressed: () => _handleNumberPress(i.toString()),
                        ),
                      const SizedBox(), // Empty space
                      NumberButton(
                        number: '0',
                        onPressed: () => _handleNumberPress('0'),
                      ),
                      IconButton(
                        onPressed: _handleBackspace,
                        icon: Icon(Icons.backspace, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NumberButton extends StatelessWidget {
  final String number;
  final VoidCallback onPressed;

  const NumberButton({
    super.key,
    required this.number,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: myPoppinText(number, FontWeight.w600, 24.0),
    );
  }
}

// Your custom Poppins text widget with improved parameters
Widget myPoppinText(
  String text,
  FontWeight weight,
  double size, {
  Color color = Colors.black,
}) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontWeight: weight,
      fontSize: size,
      color: color,
    ),
  );
}