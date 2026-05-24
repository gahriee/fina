import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/models.dart';
import 'category_list_screen.dart';
import 'wallet_list_screen.dart';

class SettingsScreen extends StatefulWidget {
  final TransactionViewModel transactionVM;
  final AuthViewModel authVM;
  
  const SettingsScreen({
    super.key, 
    required this.transactionVM,
    required this.authVM,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _currencyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currencyCtrl.text = widget.transactionVM.settings.currencySymbol;
  }

  @override
  void dispose() {
    _currencyCtrl.dispose();
    super.dispose();
  }

  void _updateSettings() {
    final s = widget.transactionVM.settings.copyWith(
      currencySymbol: _currencyCtrl.text.trim().isNotEmpty ? _currencyCtrl.text.trim() : '\$',
    );
    widget.transactionVM.updateSettings(widget.authVM.currentUser!.uid, s);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.transactionVM,
      builder: (context, _) {
        final settings = widget.transactionVM.settings;
        final user = widget.authVM.currentUser;

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: widget.transactionVM.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
              SliverAppBar(
                title: const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1.0)),
                pinned: true,
                centerTitle: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader('Preferences'),
                      _buildGroupContainer(
                        context,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                const Text('Currency Symbol', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: settings.currencySymbol,
                                      isExpanded: true,
                                      alignment: Alignment.centerRight,
                                      icon: const Icon(CupertinoIcons.chevron_up_chevron_down, size: 16),
                                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                      items: () {
                                        const currencyNames = {
                                          '\$': 'USD (\$)',
                                          '€': 'EUR (€)',
                                          '£': 'GBP (£)',
                                          '¥': 'JPY (¥)',
                                          '₱': 'PHP (₱)',
                                          '₹': 'INR (₹)',
                                          '₩': 'KRW (₩)',
                                          '₽': 'RUB (₽)',
                                        };
                                        final keys = { ...currencyNames.keys, settings.currencySymbol };
                                        return keys.map((c) => DropdownMenuItem(
                                          value: c, 
                                          child: Text(currencyNames[c] ?? c, textAlign: TextAlign.right),
                                        )).toList();
                                      }(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          final s = settings.copyWith(currencySymbol: val);
                                          widget.transactionVM.updateSettings(user!.uid, s);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildDivider(context),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('Appearance', style: TextStyle(fontSize: 16)),
                                const SizedBox(height: 12),
                                CupertinoSlidingSegmentedControl<AppThemeMode>(
                                  groupValue: settings.themeMode,
                                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  thumbColor: Theme.of(context).colorScheme.surface,
                                  children: const {
                                    AppThemeMode.system: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('System')),
                                    AppThemeMode.light: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Light')),
                                    AppThemeMode.dark: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Dark')),
                                  },
                                  onValueChanged: (val) {
                                    if (val != null) {
                                      final s = settings.copyWith(themeMode: val);
                                      widget.transactionVM.updateSettings(user!.uid, s);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Data'),
                      _buildGroupContainer(
                        context,
                        children: [
                          ListTile(
                            title: const Text('Manage Categories'),
                            trailing: const Icon(CupertinoIcons.chevron_right, size: 18, color: Colors.grey),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryListScreen(transactionVM: widget.transactionVM),
                                ),
                              );
                            },
                          ),
                          _buildDivider(context),
                          ListTile(
                            title: const Text('Manage Wallets'),
                            trailing: const Icon(CupertinoIcons.chevron_right, size: 18, color: Colors.grey),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WalletListScreen(transactionVM: widget.transactionVM, userId: user!.uid),
                                ),
                              );
                            },
                          ),

                          _buildDivider(context),
                          ListTile(
                            title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Clear All Data?'),
                                  content: const Text('This will delete all transactions and reset categories. This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        widget.transactionVM.clearAllData(user!.uid);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Account'),
                      _buildGroupContainer(
                        context,
                        children: [
                          ListTile(
                            title: Text(user?.email ?? 'Unknown User'),
                            trailing: const Icon(CupertinoIcons.person, size: 20, color: Colors.grey),
                          ),
                          _buildDivider(context),
                          ListTile(
                            title: const Text('Log Out', style: TextStyle(color: Colors.red)),
                            trailing: const Icon(CupertinoIcons.square_arrow_right, size: 20, color: Colors.red),
                            onTap: () => widget.authVM.logout(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildGroupContainer(BuildContext context, {required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(height: 1, indent: 16, color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5));
  }
}
