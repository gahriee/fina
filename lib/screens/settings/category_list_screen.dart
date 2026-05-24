import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/models.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/category_icon.dart';

class CategoryListScreen extends StatelessWidget {
  final TransactionViewModel transactionVM;
  const CategoryListScreen({super.key, required this.transactionVM});

  void _showAddCategoryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final iconCtrl = TextEditingController();
    TransactionType type = TransactionType.expense;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                      ButtonSegment(value: TransactionType.income, label: Text('Income')),
                    ],
                    selected: {type},
                    onSelectionChanged: (set) => setState(() => type = set.first),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: iconCtrl,
                          decoration: const InputDecoration(labelText: 'Emoji'),
                          maxLength: 2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final icon = iconCtrl.text.trim();
                    if (name.isNotEmpty && icon.isNotEmpty) {
                      final userId = FirebaseAuth.instance.currentUser!.uid;
                      transactionVM.addCategory(userId, name, icon, type);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: ListenableBuilder(
        listenable: transactionVM,
        builder: (context, _) {
          final categories = transactionVM.categories;
          
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final c = categories[index];
              return Dismissible(
                key: ValueKey(c.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(CupertinoIcons.trash, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  final success = await transactionVM.deleteCategory(c.id);
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot delete category: It is currently in use by a transaction.')),
                    );
                  }
                  return success;
                },
                child: ListTile(
                  leading: CategoryIcon(icon: c.icon, type: c.type),
                  title: Text(c.name),
                  trailing: Text(c.type.label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }
}
