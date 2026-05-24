import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../viewmodels/transaction_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/models.dart';
import 'category_list_screen.dart';

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
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: _currencyCtrl,
                decoration: const InputDecoration(labelText: 'Currency Symbol'),
                onChanged: (_) => _updateSettings(),
              ),
              const SizedBox(height: 16),
              const Text('Appearance', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              SegmentedButton<AppThemeMode>(
                segments: const [
                  ButtonSegment(value: AppThemeMode.system, label: Text('System')),
                  ButtonSegment(value: AppThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: AppThemeMode.dark, label: Text('Dark')),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (set) {
                  final s = settings.copyWith(themeMode: set.first);
                  widget.transactionVM.updateSettings(user!.uid, s);
                },
              ),
              const SizedBox(height: 32),
              const Text('Data', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Manage Categories'),
                trailing: const Icon(CupertinoIcons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryListScreen(transactionVM: widget.transactionVM),
                    ),
                  );
                },
              ),
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
              const SizedBox(height: 32),
              const Text('Account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(CupertinoIcons.person),
                title: Text(user?.email ?? 'Unknown User'),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.square_arrow_right),
                title: const Text('Log Out'),
                onTap: () => widget.authVM.logout(),
              ),
            ],
          ),
        );
      },
    );
  }
}
