import 'package:go_router/go_router.dart';
import 'package:theloanapp/main.dart';
import 'package:theloanapp/screens/borrower_screens/BorrowerNavigation.dart';
import 'package:theloanapp/screens/borrower_screens/loan_apply_success.dart';
import 'package:theloanapp/screens/borrower_screens/loan_repayment.dart';
import 'package:theloanapp/screens/borrower_screens/loan_details.dart';
import 'package:theloanapp/screens/investor_screens/InvestorNavigation.dart';
import 'package:theloanapp/screens/investor_screens/rewards.dart';
import 'package:theloanapp/screens/signin_page.dart';
import 'package:theloanapp/screens/signup_page.dart';
import 'package:theloanapp/screens/borrower_screens/loan_request.dart';
import 'package:theloanapp/screens/transaction_history.dart';
import 'package:theloanapp/services/auth_gate.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => AuthGate()),
    GoRoute(
        path: '/signin',
        builder: (context, state) => SigninPage()),
    GoRoute(
        path: '/signup',
        builder: (context, state) => SignupPage()),
    GoRoute(
        path: '/transaction_history',
        builder: (context, state) => TransactionHistoryScreen()),
    GoRoute(
        path: '/rewards',
        builder: (context, state) => RewardsScreen()),
    GoRoute(
        path: '/borrowerNavigation',
        builder: (context, state) => BorrowerNavigation(),
    ),
    GoRoute(
        path: '/investorNavigation',
        builder:
          (context, state) => InvestorNavigation(),

      // builder: (context, state) => InvestorNavigation(currUser: state.extra as User),
    ),

    //BORROWER ROUTES
    GoRoute(
      path: '/loan_request',
      builder:
          (context, state) => CreateLoanRequestScreen(loanType: state.extra as String),

      // builder: (context, state) => InvestorNavigation(currUser: state.extra as User),
    ),

    GoRoute(
      path: '/loanSuccess',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return LoanSuccessScreen(
          loanType: data['loanType'],
          period: data['period'],
          amount: data['amount'],
          submissionTime: data['submissionTime'],
        );
      },
    ),

    GoRoute(
        path: '/loan_summary',
        builder: (context, state) => LoanSummaryScreen(loanId: state.extra as String,)),

    GoRoute(
        path: '/loan_repayment',
        builder: (context, state) => LoanRepaymentScreen(loanId: state.extra as String)
    ),

  ],
);