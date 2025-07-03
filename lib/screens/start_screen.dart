import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class StartScreen extends StatelessWidget {
  Widget myButton(
      String text,
      Color bgcolor,
      Color textColor,
      BuildContext context,
      String route,
      ) {
    return ElevatedButton(
      onPressed: () {
        context.go(route);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: bgcolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 14.h),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60.h),
                SizedBox(
                  height: 400.h,
                  child: Image.asset('assets/start_screen.png'),
                ),

                SizedBox(height: 10.h),

                Text(
                  "Loan, Shop and Pay with Insting Loan",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 16.h),

                Text(
                  "Platform that empowers individuals to explore the exciting realms of loan, shop, and pay later with InstingLoan.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 50.h),

                Column(
                  children: [
                    myButton(
                      "Create new account",
                      Color(0xFFD1F272),
                      Colors.black,
                      context,
                      '/signup',
                    ),
                    SizedBox(height: 12.h),
                    myButton(
                      "I already have an account",
                      Colors.black,
                      Colors.white,
                      context,
                      '/signin',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
