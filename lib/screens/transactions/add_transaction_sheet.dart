import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/models.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionSheet extends StatefulWidget {
  final TransactionViewModel transactionVM;
  final Transaction? transactionToEdit;

  const AddTransactionSheet({
    super.key,
    required this.transactionVM,
    this.transactionToEdit,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  
  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _amountCtrl.text = t.amount.toString();
      _noteCtrl.text = t.note ?? '';
      _type = t.type;
      _categoryId = t.categoryId;
      _date = t.date;
    } else {
      _setDefaultCategory();
    }
  }

  void _setDefaultCategory() {
    final available = widget.transactionVM.categories.where((c) => c.type == _type).toList();
    if (available.isNotEmpty) {
      _categoryId = available.first.id;
    } else {
      _categoryId = null;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0 || _categoryId == null) return;

    final userId = FirebaseAuth.instance.currentUser!.uid;

    if (widget.transactionToEdit != null) {
      final updated = Transaction(
        id: widget.transactionToEdit!.id,
        userId: widget.transactionToEdit!.userId,
        amount: amount,
        type: _type,
        categoryId: _categoryId!,
        date: _date,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      await widget.transactionVM.updateTransaction(updated);
    } else {
      await widget.transactionVM.addTransaction(
        userId: userId,
        amount: amount,
        type: _type,
        categoryId: _categoryId!,
        date: _date,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
    }
    
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = widget.transactionVM.categories.where((c) => c.type == _type).toList();
    
    // Ensure selected category is valid for current type
    if (_categoryId != null && !availableCategories.any((c) => c.id == _categoryId)) {
      _categoryId = availableCategories.isNotEmpty ? availableCategories.first.id : null;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
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
                Text(
                  widget.transactionToEdit == null ? 'New Transaction' : 'Edit Transaction',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: _save,
                  icon: const Icon(CupertinoIcons.checkmark_alt, size: 20),
                  label: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                ButtonSegment(value: TransactionType.income, label: Text('Income')),
              ],
              selected: {_type},
              onSelectionChanged: (set) {
                setState(() {
                  _type = set.first;
                  _setDefaultCategory();
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '${widget.transactionVM.settings.currencySymbol} ',
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Category', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _categoryId,
                  isExpanded: true,
                  items: availableCategories.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.icon} ${c.name}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _categoryId = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) {
                  setState(() => _date = d);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_date.month}/${_date.day}/${_date.year}'),
                    const Icon(CupertinoIcons.calendar, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Note (Optional)'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
