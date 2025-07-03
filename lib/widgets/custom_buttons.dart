import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

Widget CustomButton(String text, Function function) {
  return ElevatedButton(
    onPressed: () {
      function();
    },

    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFD8F474),
      foregroundColor: Colors.black,
      minimumSize: Size(330.w, 60.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: Colors.black, width: 1),
      ),
      elevation: 1,
    ),
    child: Text(text, style: GoogleFonts.poppins(fontSize: 20.sp)),
  );
}
