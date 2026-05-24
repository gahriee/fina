import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import '../transactions/add_transaction_sheet.dart';
import '../../models/models.dart';

class DashboardScreen extends StatelessWidget {
  final TransactionViewModel transactionVM;
  const DashboardScreen({super.key, required this.transactionVM});

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddTransactionSheet(transactionVM: transactionVM),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: transactionVM,
      builder: (context, _) {
        if (transactionVM.isLoading && transactionVM.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final recents = transactionVM.recentTransactions;
        final currency = transactionVM.settings.currencySymbol;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              BalanceCard(
                balance: transactionVM.balance,
                currencySymbol: currency,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryBox(
                        title: 'Income',
                        amount: transactionVM.totalIncome,
                        currencySymbol: currency,
                        type: TransactionType.income,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryBox(
                        title: 'Expense',
                        amount: transactionVM.totalExpense,
                        currencySymbol: currency,
                        type: TransactionType.expense,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              if (recents.isEmpty)
                const EmptyState(
                  icon: CupertinoIcons.list_dash,
                  title: 'No Transactions Yet',
                  message: 'Tap the + button to add your first transaction.',
                )
              else
                ...recents.map((t) {
                  final category = transactionVM.categories.firstWhere(
                    (c) => c.id == t.categoryId,
                    orElse: () => Category(id: '', userId: '', name: 'Unknown', icon: '?', type: t.type),
                  );
                  return TransactionTile(
                    transaction: t,
                    category: category,
                    currencySymbol: currency,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => AddTransactionSheet(
                          transactionVM: transactionVM,
                          transactionToEdit: t,
                        ),
                      );
                    },
                  );
                }),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddSheet(context),
            child: const Icon(CupertinoIcons.add),
          ),
        );
      },
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final double amount;
  final String currencySymbol;
  final TransactionType type;

  const _SummaryBox({
    required this.title,
    required this.amount,
    required this.currencySymbol,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = type == TransactionType.income
        ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
        : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                type == TransactionType.income ? CupertinoIcons.arrow_down_right : CupertinoIcons.arrow_up_right,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$currencySymbol${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
