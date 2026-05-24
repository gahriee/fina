import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/models.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import 'add_transaction_sheet.dart';

class TransactionListScreen extends StatefulWidget {
  final TransactionViewModel transactionVM;
  const TransactionListScreen({super.key, required this.transactionVM});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _filter = 'All';

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddTransactionSheet(transactionVM: widget.transactionVM),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.transactionVM,
      builder: (context, _) {
        final allTransactions = widget.transactionVM.transactions;
        final currency = widget.transactionVM.settings.currencySymbol;

        final filtered = allTransactions.where((t) {
          if (_filter == 'Income') return t.type == TransactionType.income;
          if (_filter == 'Expense') return t.type == TransactionType.expense;
          return true;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Transactions'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'All', label: Text('All')),
                    ButtonSegment(value: 'Income', label: Text('Income')),
                    ButtonSegment(value: 'Expense', label: Text('Expense')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (set) {
                    setState(() => _filter = set.first);
                  },
                ),
              ),
            ),
          ),
          body: filtered.isEmpty
              ? const EmptyState(
                  icon: CupertinoIcons.list_bullet,
                  title: 'No Transactions',
                  message: 'No transactions found for this filter.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final t = filtered[index];
                    final category = widget.transactionVM.categories.firstWhere(
                      (c) => c.id == t.categoryId,
                      orElse: () => Category(id: '', userId: '', name: 'Unknown', icon: '?', type: t.type),
                    );

                    return Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Theme.of(context).colorScheme.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(CupertinoIcons.trash, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        widget.transactionVM.deleteTransaction(t.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Transaction deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                widget.transactionVM.addTransaction(
                                  userId: t.userId,
                                  amount: t.amount,
                                  type: t.type,
                                  categoryId: t.categoryId,
                                  date: t.date,
                                  note: t.note,
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: TransactionTile(
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
                              transactionVM: widget.transactionVM,
                              transactionToEdit: t,
                            ),
                          );
                        },
                      ),
                    );
                  },
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
