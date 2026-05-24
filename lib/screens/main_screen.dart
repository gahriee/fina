import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';
import 'dashboard/dashboard_screen.dart';
import 'transactions/transaction_list_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  final TransactionViewModel transactionVM;
  final AuthViewModel authVM;

  const MainScreen({
    super.key,
    required this.transactionVM,
    required this.authVM,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(transactionVM: widget.transactionVM),
          TransactionListScreen(transactionVM: widget.transactionVM),
          ReportsScreen(transactionVM: widget.transactionVM),
          SettingsScreen(transactionVM: widget.transactionVM, authVM: widget.authVM),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.list_bullet),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.chart_pie),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
