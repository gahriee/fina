import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import '../transactions/add_transaction_sheet.dart';
import '../../models/models.dart';
import '../../widgets/category_icon.dart';

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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(CupertinoIcons.add),
      ),
      body: ListenableBuilder(
        listenable: transactionVM,
        builder: (context, _) {
          if (transactionVM.isLoading && transactionVM.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final recents = transactionVM.recentTransactions;
          final currency = transactionVM.settings.currencySymbol;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1.0)),
                pinned: true,
                centerTitle: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BalanceCard(
                        balance: transactionVM.balance,
                        currencySymbol: currency,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                      if (transactionVM.wallets.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                          child: Text(
                            'Wallets',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                          ),
                        ),
                        SizedBox(
                          height: 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: transactionVM.wallets.length,
                            itemBuilder: (context, index) {
                              final wallet = transactionVM.wallets[index];
                              final bal = transactionVM.getWalletBalance(wallet);
                              return Container(
                                width: 150,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.surface,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            CategoryIcon.availableIcons[wallet.icon] ?? CupertinoIcons.briefcase_fill,
                                            size: 16,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            wallet.name,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      '$currency${bal.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 32, 24, 12),
                        child: Text(
                          'Recent Transactions',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                      ),
                      if (recents.isEmpty)
                        const EmptyState(
                          icon: CupertinoIcons.list_dash,
                          title: 'No Transactions Yet',
                          message: 'Tap the + button to add your first transaction.',
                        )
                      else
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: recents.asMap().entries.map((entry) {
                              final index = entry.key;
                              final t = entry.value;
                              final category = transactionVM.categories.firstWhere(
                                (c) => c.id == t.categoryId,
                                orElse: () => Category(id: '', userId: '', name: 'Unknown', icon: '?', type: t.type),
                              );
                              
                              return Column(
                                children: [
                                  TransactionTile(
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
                                          transactionVM: transactionVM,
                                          transactionToEdit: t,
                                        ),
                                      );
                                    },
                                  ),
                                  if (index < recents.length - 1)
                                    Divider(
                                      height: 1, 
                                      indent: 64, 
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                                    ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
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
        
    final bgColor = type == TransactionType.income
        ? (isDark ? const Color(0xFF4ADE80).withValues(alpha: 0.15) : const Color(0xFF16A34A).withValues(alpha: 0.1))
        : (isDark ? const Color(0xFFF87171).withValues(alpha: 0.15) : const Color(0xFFDC2626).withValues(alpha: 0.1));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
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
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$currencySymbol${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 20, 
              letterSpacing: -0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
