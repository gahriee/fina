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
          body: RefreshIndicator(
            onRefresh: widget.transactionVM.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
              SliverAppBar(
                title: const Text('Transactions', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1.0)),
                pinned: true,
                centerTitle: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<String>(
                      groupValue: _filter,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      thumbColor: Theme.of(context).colorScheme.surface,
                      children: const {
                        'All': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('All')),
                        'Income': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Income')),
                        'Expense': Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Expense')),
                      },
                      onValueChanged: (val) {
                        if (val != null) {
                          setState(() => _filter = val);
                        }
                      },
                    ),
                  ),
                ),
              ),
              filtered.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: EmptyState(
                        icon: CupertinoIcons.list_bullet,
                        title: 'No Transactions',
                        message: 'No transactions found for this filter.',
                      ),
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: filtered.asMap().entries.map((entry) {
                            final index = entry.key;
                            final t = entry.value;
                            final category = widget.transactionVM.categories.firstWhere(
                              (c) => c.id == t.categoryId,
                              orElse: () => Category(id: '', userId: '', name: 'Unknown', icon: '?', type: t.type),
                            );

                            return Column(
                              children: [
                                Dismissible(
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
                                        content: const Row(
                                          children: [
                                            Icon(CupertinoIcons.trash_fill, color: Colors.white, size: 20),
                                            SizedBox(width: 12),
                                            Expanded(child: Text('Transaction deleted', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                                          ],
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        margin: const EdgeInsets.all(20),
                                        elevation: 0,
                                        duration: const Duration(seconds: 4),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          textColor: Colors.white,
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
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                        ),
                                        builder: (_) => AddTransactionSheet(
                                          transactionVM: widget.transactionVM,
                                          transactionToEdit: t,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (index < filtered.length - 1)
                                  Divider(
                                    height: 1,
                                    indent: 64,
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddSheet(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(CupertinoIcons.add),
          ),
        );
      },
    );
  }
}
