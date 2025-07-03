import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theloanapp/providers/user_provider.dart';
import 'package:theloanapp/screens/borrower_screens/home_page.dart';
import 'package:theloanapp/screens/borrower_screens/loans_taken.dart';
import 'package:theloanapp/screens/Wallet/WalletNavigation.dart';
import 'package:theloanapp/screens/chatbot.dart';
import 'package:theloanapp/screens/transaction_history.dart';

class BorrowerNavigation extends ConsumerStatefulWidget {
  const BorrowerNavigation({super.key});

  @override
  _BorrowerNavigationState createState() => _BorrowerNavigationState();
}

class _BorrowerNavigationState extends ConsumerState<BorrowerNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _screens = [BorrowerHomePage(), MyLoansPage(), WalletDashboardScreen(), TransactionHistoryScreen(), Chat()];
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
            label: 'Loans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
