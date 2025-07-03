import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:theloanapp/screens/investor_screens/home_page.dart';
import 'package:theloanapp/screens/investor_screens/loans.dart';
import 'package:theloanapp/screens/Wallet/WalletNavigation.dart';
import 'package:theloanapp/screens/investor_screens/rewards.dart';
import 'package:theloanapp/screens/transaction_history.dart';

class InvestorNavigation extends StatefulWidget {

  const InvestorNavigation({super.key});

  @override
  State<InvestorNavigation> createState() => _InvestorNavigationState();
}

class _InvestorNavigationState extends State<InvestorNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [InvestorHomePage(), RewardsScreen(), WalletDashboardScreen(), TransactionHistoryScreen()];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],

      ),
    );
  }
}
