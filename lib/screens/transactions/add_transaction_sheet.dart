import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/models.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/category_icon.dart';
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
  String? _walletId;
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
      _walletId = t.walletId;
      _date = t.date;
    } else {
      _setDefaultCategory();
      if (widget.transactionVM.wallets.isNotEmpty) {
        _walletId = widget.transactionVM.wallets.first.id;
      }
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
        walletId: _walletId,
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
        walletId: _walletId,
      );
    }
    
    if (mounted) {
      Navigator.pop(context);
      final msg = widget.transactionToEdit == null ? 'Transaction added successfully!' : 'Transaction updated successfully!';
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
        child: SingleChildScrollView(
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
            CupertinoSlidingSegmentedControl<TransactionType>(
              groupValue: _type,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              thumbColor: Theme.of(context).colorScheme.surface,
              children: const {
                TransactionType.expense: Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10), child: Text('Expense', style: TextStyle(fontWeight: FontWeight.w500))),
                TransactionType.income: Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10), child: Text('Income', style: TextStyle(fontWeight: FontWeight.w500))),
              },
              onValueChanged: (val) {
                if (val != null) {
                  setState(() {
                    _type = val;
                    _setDefaultCategory();
                  });
                }
              },
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
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Padding(
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
                              items: availableCategories.map((c) {
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
                              onChanged: (val) {
                                setState(() => _categoryId = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.transactionVM.wallets.isNotEmpty) ...[
                    Divider(height: 1, indent: 16, color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          const Text('Wallet', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _walletId,
                                isExpanded: true,
                                icon: const Icon(CupertinoIcons.chevron_down, size: 16),
                                alignment: Alignment.centerRight,
                                items: widget.transactionVM.wallets.map((w) {
                                  return DropdownMenuItem(
                                    value: w.id,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(CategoryIcon.availableIcons[w.icon] ?? CupertinoIcons.briefcase_fill, size: 16),
                                          const SizedBox(width: 8),
                                          Text(w.name),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() => _walletId = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Divider(height: 1, indent: 16, color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              Text('${_date.month}/${_date.day}/${_date.year}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              const SizedBox(width: 8),
                              const Icon(CupertinoIcons.calendar, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                hintText: 'Note (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
        ),
      ),
    );
  }
}
