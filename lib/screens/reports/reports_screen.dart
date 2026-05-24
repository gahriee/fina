import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/empty_state.dart';

class ReportsScreen extends StatefulWidget {
  final TransactionViewModel transactionVM;
  const ReportsScreen({super.key, required this.transactionVM});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _currentMonth = DateTime.now();

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
    });
  }

  String _monthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.transactionVM,
      builder: (context, _) {
        final totals = widget.transactionVM.totals(_currentMonth);
        final breakdown = widget.transactionVM.breakdown(_currentMonth);
        final currency = widget.transactionVM.settings.currencySymbol;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reports'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.chevron_left),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.chevron_right),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Income', style: TextStyle(color: Colors.green)),
                          Text(
                            '$currency${totals.income.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Expense', style: TextStyle(color: Colors.red)),
                          Text(
                            '$currency${totals.expense.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              Expanded(
                child: breakdown.isEmpty
                    ? const EmptyState(
                        icon: CupertinoIcons.chart_pie,
                        title: 'No Expenses',
                        message: 'No expenses tracked for this month.',
                      )
                    : ListView.builder(
                        itemCount: breakdown.length,
                        itemBuilder: (context, index) {
                          final item = breakdown[index];
                          final category = item.$1;
                          final amount = item.$2;
                          final percentage = totals.expense > 0 ? amount / totals.expense : 0.0;

                          return ListTile(
                            leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
                            title: Text(category.name),
                            subtitle: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                            trailing: Text(
                              '$currency${amount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
