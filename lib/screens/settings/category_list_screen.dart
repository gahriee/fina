import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/models.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/category_icon.dart';

class CategoryListScreen extends StatelessWidget {
  final TransactionViewModel transactionVM;
  const CategoryListScreen({super.key, required this.transactionVM});

  void _showAddCategoryDialog(BuildContext context, [Category? category]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddCategorySheet(transactionVM: transactionVM, categoryToEdit: category),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: transactionVM.refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          SliverAppBar(
            title: const Text('Categories', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1.0)),
            pinned: true,
            centerTitle: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80, top: 16),
              child: ListenableBuilder(
                listenable: transactionVM,
                builder: (context, _) {
                  final categories = transactionVM.categories;
                  
                  if (categories.isEmpty) {
                    return const Center(child: Text('No categories found.'));
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: categories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final c = entry.value;

                        return Column(
                          children: [
                            Dismissible(
                              key: ValueKey(c.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Theme.of(context).colorScheme.error,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                child: const Icon(CupertinoIcons.trash, color: Colors.white),
                              ),
                              confirmDismiss: (_) async {
                                final confirm = await showCupertinoDialog<bool>(
                                  context: context,
                                  builder: (ctx) => CupertinoAlertDialog(
                                    title: const Text('Delete Category?'),
                                    content: const Text('Are you sure you want to delete this category?'),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text('Cancel'),
                                        onPressed: () => Navigator.pop(ctx, false),
                                      ),
                                      CupertinoDialogAction(
                                        isDestructiveAction: true,
                                        child: const Text('Delete'),
                                        onPressed: () => Navigator.pop(ctx, true),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm != true) return false;

                                final success = await transactionVM.deleteCategory(c.id);
                                if (context.mounted) {
                                  if (!success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.white, size: 20),
                                            SizedBox(width: 12),
                                            Expanded(child: Text('Cannot delete category: It is currently in use.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                                          ],
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        margin: const EdgeInsets.all(20),
                                        elevation: 0,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(CupertinoIcons.trash_fill, color: Colors.white, size: 20),
                                            const SizedBox(width: 12),
                                            Expanded(child: Text('Category "${c.name}" deleted', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                                          ],
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        margin: const EdgeInsets.all(20),
                                        elevation: 0,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                                return success;
                              },
                              child: ListTile(
                                leading: CategoryIcon(icon: c.icon, type: c.type, colorHex: c.colorHex),
                                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                trailing: Text(c.type.label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                onTap: () => _showAddCategoryDialog(context, c),
                              ),
                            ),
                            if (index < categories.length - 1)
                              Divider(
                                height: 1,
                                indent: 72,
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }
}

class _AddCategorySheet extends StatefulWidget {
  final TransactionViewModel transactionVM;
  final Category? categoryToEdit;

  const _AddCategorySheet({required this.transactionVM, this.categoryToEdit});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameCtrl = TextEditingController();
  TransactionType _type = TransactionType.expense;
  
  static final _icons = CategoryIcon.availableIcons.keys.toList();
  static const _colors = ['#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5', '#2196F3', '#03A9F4', '#00BCD4', '#009688', '#4CAF50', '#8BC34A', '#CDDC39', '#FFEB3B', '#FF9800', '#FF5722', '#795548', '#9E9E9E', '#607D8B'];
  
  String _selectedIcon = 'food';
  String _selectedColor = '#F44336';

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameCtrl.text = widget.categoryToEdit!.name;
      _type = widget.categoryToEdit!.type;
      _selectedIcon = widget.categoryToEdit!.icon;
      if (widget.categoryToEdit!.colorHex != null) {
        _selectedColor = widget.categoryToEdit!.colorHex!;
      }
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final isEditing = widget.categoryToEdit != null;

    if (isEditing) {
      final updated = widget.categoryToEdit!.copyWith(
        name: name,
        icon: _selectedIcon,
        type: _type,
        colorHex: _selectedColor,
      );
      await widget.transactionVM.updateCategory(updated);
    } else {
      await widget.transactionVM.addCategory(userId, name, _selectedIcon, _type, colorHex: _selectedColor);
    }
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('Category "$name" ${isEditing ? 'updated' : 'added'} successfully!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
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
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
              Text(widget.categoryToEdit == null ? 'Add Category' : 'Edit Category', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
              TransactionType.expense: Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('Expense')),
              TransactionType.income: Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('Income')),
            },
            onValueChanged: (val) {
              if (val != null) setState(() => _type = val);
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CategoryIcon(icon: _selectedIcon, type: _type, colorHex: _selectedColor),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Category Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _icons.length,
              itemBuilder: (context, index) {
                final icon = _icons[index];
                final isSelected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
                    ),
                    child: Icon(CategoryIcon.availableIcons[icon], size: 24, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _colors.length,
              itemBuilder: (context, index) {
                final colorHex = _colors[index];
                final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
                final isSelected = colorHex == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorHex),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3) : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}
