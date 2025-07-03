import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:theloanapp/providers/user_provider.dart';
import 'package:theloanapp/routes.dart';
import 'package:theloanapp/services/auth_service.dart';
import 'package:theloanapp/widgets/custom_buttons.dart';
import 'package:theloanapp/widgets/custom_fields.dart';

class SignupPage extends ConsumerStatefulWidget {
  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends ConsumerState<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String selectedRole = "Investor";

  AuthService authService = AuthService();

  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Passwords don't match!")));
      return;
    }

    User? user = await authService.signUpWithEmail(
      emailController.text,
      passwordController.text,
      selectedRole,
      context,
      ref
    );

    if (user != null) {
      ref.read(userProvider.notifier).state = user;

      if (selectedRole == 'Investor') {
         context.push('/investorNavigation');
      } else {
        context.push('/borrowerNavigation');
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup failed! Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Color(0xFFFFFCF4),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/leaves.png', height: 250.h),

              SizedBox(height: 15.h),

              Text(
                'Sign Up',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                'Create an account, it\'s free!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16.sp),
              ),

              SizedBox(height: 15.h),

              CustomField('Email', false, emailController),

              SizedBox(height: 15.h),

              CustomField('Password', true, passwordController),

              SizedBox(height: 15.h),

              CustomField('Confirm Password', true, confirmPasswordController),

              SizedBox(height: 65.h),

              ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: Colors.black,
                isSelected: [
                  selectedRole == "Investor",
                  selectedRole == "Borrower",
                ],
                onPressed: (int index) {
                  setState(() {
                    selectedRole = index == 0 ? "Investor" : "Borrower";
                  });
                },
                children: [
                  Padding(padding: EdgeInsets.all(10), child: Text("Investor")),
                  Padding(padding: EdgeInsets.all(10), child: Text("Borrower")),
                ],
              ),

              SizedBox(height: 20.h),

              CustomButton('Sign up', signUp),

              SizedBox(height: 70.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: GoogleFonts.poppins(fontSize: 13.sp),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.go('/signin');
                    },
                    child: Text(
                      ' Log in',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}