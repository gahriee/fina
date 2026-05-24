import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/models.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/category_icon.dart';
class SetBudgetSheet extends StatefulWidget {
  final TransactionViewModel transactionVM;
  final DateTime month;
  final Category? initialCategory;

  const SetBudgetSheet({
    super.key,
    required this.transactionVM,
    required this.month,
    this.initialCategory,
  });

  @override
  State<SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends State<SetBudgetSheet> {
  final _amountCtrl = TextEditingController();
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    final expenseCats = widget.transactionVM.categories.where((c) => c.type == TransactionType.expense).toList();
    if (widget.initialCategory != null) {
      _categoryId = widget.initialCategory!.id;
      final existingBudget = widget.transactionVM.budgets.where((b) => 
        b.categoryId == _categoryId && 
        b.month.year == widget.month.year && 
        b.month.month == widget.month.month
      ).firstOrNull;
      if (existingBudget != null) {
        _amountCtrl.text = existingBudget.amountLimit.toStringAsFixed(0);
      }
    } else if (expenseCats.isNotEmpty) {
      _categoryId = expenseCats.first.id;
    }
  }

  void _onCategoryChanged(String? val) {
    setState(() {
      _categoryId = val;
      final existingBudget = widget.transactionVM.budgets.where((b) => 
        b.categoryId == _categoryId && 
        b.month.year == widget.month.year && 
        b.month.month == widget.month.month
      ).firstOrNull;
      if (existingBudget != null) {
        _amountCtrl.text = existingBudget.amountLimit.toStringAsFixed(0);
      } else {
        _amountCtrl.clear();
      }
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (_categoryId == null) return;
    
    final userId = FirebaseAuth.instance.currentUser!.uid;

    if (amount == null || amount <= 0) {
      // If amount is empty or 0, delete the budget if it exists
      final existingBudget = widget.transactionVM.budgets.where((b) => 
        b.categoryId == _categoryId && 
        b.month.year == widget.month.year && 
        b.month.month == widget.month.month
      ).firstOrNull;
      
      if (existingBudget != null) {
        await widget.transactionVM.deleteBudget(existingBudget.id);
      }
    } else {
      final monthStr = '${widget.month.year}-${widget.month.month.toString().padLeft(2, '0')}';
      final docId = '${userId}_${_categoryId}_$monthStr';
      
      await widget.transactionVM.setBudget(Budget(
        id: docId,
        userId: userId,
        categoryId: _categoryId!,
        amountLimit: amount,
        month: DateTime(widget.month.year, widget.month.month, 1),
      ));
    }
    
    if (mounted) {
      Navigator.pop(context);
      final msg = amount == null ? 'Budget removed successfully!' : 'Budget set successfully!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
          elevation: 0,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseCats = widget.transactionVM.categories.where((c) => c.type == TransactionType.expense).toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(CupertinoIcons.xmark, size: 20),
                label: const Text('Cancel'),
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const Text('Set Budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: _save,
                icon: const Icon(CupertinoIcons.checkmark_alt, size: 20),
                label: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '${widget.transactionVM.settings.currencySymbol}',
              prefixStyle: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
            ),
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, letterSpacing: -2.0),
          ),
          const SizedBox(height: 16),
          const Text(
            'Leave empty to remove budget',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _categoryId,
                        isExpanded: true,
                        icon: const Icon(CupertinoIcons.chevron_down, size: 16),
                        alignment: Alignment.centerRight,
                        items: expenseCats.map((c) {
                          return DropdownMenuItem(
                            value: c.id,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CategoryIcon.availableIcons[c.icon] ?? CupertinoIcons.circle,
                                    size: 16,
                                    color: c.colorHex != null ? Color(int.parse(c.colorHex!.replaceFirst('#', '0xFF'))) : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(c.name),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: _onCategoryChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
