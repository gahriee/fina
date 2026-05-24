import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/models.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../app/theme.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/empty_state.dart';

class WalletListScreen extends StatefulWidget {
  final TransactionViewModel transactionVM;
  final String userId;

  const WalletListScreen({super.key, required this.transactionVM, required this.userId});

  @override
  State<WalletListScreen> createState() => _WalletListScreenState();
}

class _WalletListScreenState extends State<WalletListScreen> {
  void _showAddWalletSheet([Wallet? wallet]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddWalletSheet(
        transactionVM: widget.transactionVM,
        userId: widget.userId,
        walletToEdit: wallet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Wallets', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1.0)),
            pinned: true,
            centerTitle: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80, top: 16),
              child: ListenableBuilder(
                listenable: widget.transactionVM,
                builder: (context, _) {
                  final wallets = widget.transactionVM.wallets;
                  if (wallets.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: EmptyState(
                        icon: CupertinoIcons.briefcase_fill,
                        title: 'No Wallets',
                        message: 'Add a wallet to start tracking your balances.',
                      ),
                    );
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
                      children: wallets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final wallet = entry.value;

                        return Column(
                          children: [
                            Dismissible(
                              key: ValueKey(wallet.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: AppColors.expense,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(CupertinoIcons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (_) async {
                                final confirm = await showCupertinoDialog<bool>(
                                  context: context,
                                  builder: (ctx) => CupertinoAlertDialog(
                                    title: const Text('Delete Wallet?'),
                                    content: const Text('Are you sure you want to delete this wallet?'),
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

                                final deleted = await widget.transactionVM.deleteWallet(wallet.id);
                                if (context.mounted) {
                                  if (!deleted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.white, size: 20),
                                            SizedBox(width: 12),
                                            Expanded(child: Text('Cannot delete wallet: It is currently in use.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
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
                                            Expanded(child: Text('Wallet "${wallet.name}" deleted', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
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
                                return deleted;
                              },
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(CategoryIcon.availableIcons[wallet.icon] ?? CupertinoIcons.briefcase_fill, size: 24, color: Theme.of(context).colorScheme.primary),
                                ),
                                title: Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                subtitle: Text(
                                  'Initial: ${widget.transactionVM.settings.currencySymbol}${wallet.initialBalance.toStringAsFixed(2)}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                                ),
                                onTap: () => _showAddWalletSheet(wallet),
                              ),
                            ),
                            if (index < wallets.length - 1)
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWalletSheet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }
}

class _AddWalletSheet extends StatefulWidget {
  final TransactionViewModel transactionVM;
  final String userId;
  final Wallet? walletToEdit;

  const _AddWalletSheet({required this.transactionVM, required this.userId, this.walletToEdit});

  @override
  State<_AddWalletSheet> createState() => _AddWalletSheetState();
}

class _AddWalletSheetState extends State<_AddWalletSheet> {
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  String _selectedIcon = 'money';
  static const _icons = ['money', 'cart', 'home', 'box', 'gift', 'airplane', 'car'];

  @override
  void initState() {
    super.initState();
    if (widget.walletToEdit != null) {
      _nameCtrl.text = widget.walletToEdit!.name;
      _balanceCtrl.text = widget.walletToEdit!.initialBalance.toStringAsFixed(2);
      _selectedIcon = widget.walletToEdit!.icon;
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final balance = double.tryParse(_balanceCtrl.text.trim()) ?? 0.0;

    if (name.isEmpty) return;

    final isEditing = widget.walletToEdit != null;

    if (isEditing) {
      final updated = widget.walletToEdit!.copyWith(
        name: name,
        icon: _selectedIcon,
        initialBalance: balance,
      );
      await widget.transactionVM.updateWallet(updated);
    } else {
      await widget.transactionVM.addWallet(Wallet(
        id: '',
        userId: widget.userId,
        name: name,
        icon: _selectedIcon,
        initialBalance: balance,
      ));
    }
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('Wallet "$name" ${isEditing ? 'updated' : 'added'} successfully!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
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
              Text(widget.walletToEdit == null ? 'Add Wallet' : 'Edit Wallet', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: _save,
                icon: const Icon(CupertinoIcons.checkmark_alt, size: 20),
                label: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _balanceCtrl,
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
            'Initial Balance',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(CategoryIcon.availableIcons[_selectedIcon], size: 32, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Wallet Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
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
        ],
      ),
      ),
    );
  }
}
