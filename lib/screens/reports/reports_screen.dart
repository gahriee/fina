import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/models.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/category_icon.dart';
import 'set_budget_sheet.dart';

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

  void _pickMonth() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.monthYear,
                initialDateTime: _currentMonth,
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    _currentMonth = DateTime(newDate.year, newDate.month, 1);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  void _showSetBudgetSheet([Category? category]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SetBudgetSheet(
        transactionVM: widget.transactionVM,
        month: _currentMonth,
        initialCategory: category,
      ),
    );
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
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Reports', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1.0)),
                pinned: true,
                centerTitle: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton.icon(
                      onPressed: _showSetBudgetSheet,
                      icon: const Icon(CupertinoIcons.slider_horizontal_3, size: 20),
                      label: const Text('Budgets'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(CupertinoIcons.chevron_left),
                          onPressed: () => _changeMonth(-1),
                        ),
                        GestureDetector(
                          onTap: _pickMonth,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 6),
                                const Icon(CupertinoIcons.chevron_down, size: 14),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.chevron_right),
                          onPressed: () => _changeMonth(1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Income', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Text(
                                '$currency${totals.income.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Expense', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Text(
                                '$currency${totals.expense.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              breakdown.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: EmptyState(
                          icon: CupertinoIcons.chart_pie,
                          title: 'No Expenses',
                          message: 'No expenses tracked for this month.',
                        ),
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: breakdown.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final category = item.$1;
                              final amount = item.$2;
                              final percentage = totals.expense > 0 ? amount / totals.expense : 0.0;
                              
                              // Check if there is a budget for this category
                              final budget = widget.transactionVM.budgets.where((b) => 
                                b.categoryId == category.id && 
                                b.month.year == _currentMonth.year && 
                                b.month.month == _currentMonth.month
                              ).firstOrNull;

                              Widget subtitle;
                              if (budget != null) {
                                final budgetPercent = (amount / budget.amountLimit).clamp(0.0, 1.0);
                                final isOverBudget = amount > budget.amountLimit;
                                subtitle = Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${((amount / budget.amountLimit) * 100).toStringAsFixed(0)}% of $currency${budget.amountLimit.toStringAsFixed(0)}', 
                                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                                            maxLines: 1, 
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isOverBudget) ...[
                                          const SizedBox(width: 8),
                                          const Text('Over budget!', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500)),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: budgetPercent,
                                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                        color: isOverBudget ? Colors.red : Theme.of(context).colorScheme.primary,
                                        minHeight: 6,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                );
                              } else {
                                subtitle = Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentage,
                                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                        minHeight: 6,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                );
                              }

                              return Column(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    leading: CategoryIcon(icon: category.icon, type: category.type, colorHex: category.colorHex),
                                    title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: subtitle,
                                    trailing: Text(
                                      '$currency${amount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    onTap: () => _showSetBudgetSheet(category),
                                  ),
                                  if (index < breakdown.length - 1)
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
        );
      },
    );
  }
}
