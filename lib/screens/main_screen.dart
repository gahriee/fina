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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: CupertinoTabBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Colors.grey,
          border: null, 
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.square_grid_2x2),
              activeIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.list_bullet),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_pie),
              activeIcon: Icon(CupertinoIcons.chart_pie_fill),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              activeIcon: Icon(CupertinoIcons.settings_solid),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
