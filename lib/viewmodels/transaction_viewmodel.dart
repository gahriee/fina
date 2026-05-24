import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/transaction_service.dart';
import '../services/budget_service.dart';
import '../services/wallet_service.dart';

class TransactionViewModel extends ChangeNotifier {
  final _service = TransactionService();
  final _budgetService = BudgetService();
  final _walletService = WalletService();

  List<Transaction> _transactions = [];
  List<Category>    _categories   = [];
  List<Budget>      _budgets      = [];
  List<Wallet>      _wallets      = [];
  UserSettings      _settings     = const UserSettings();
  bool isLoading = false;
  String? error;

  String? _currentUserId;
  StreamSubscription? _txSub;
  StreamSubscription? _catSub;
  StreamSubscription? _setSub;
  StreamSubscription? _budSub;
  StreamSubscription? _walSub;

  List<Transaction> get transactions => _transactions;
  List<Category>    get categories   => _categories;
  List<Budget>      get budgets      => _budgets;
  List<Wallet>      get wallets      => _wallets;
  UserSettings      get settings     => _settings;

  double get totalIncome  => _sum(TransactionType.income);
  double get totalExpense => _sum(TransactionType.expense);
  double get balance      => totalIncome - totalExpense;

  List<Transaction> get recentTransactions =>
    ([..._transactions]..sort((a, b) => b.date.compareTo(a.date))).take(5).toList();

  void listen(String userId) {
    if (_currentUserId == userId) return;
    _currentUserId = userId;

    _txSub?.cancel();
    _catSub?.cancel();
    _setSub?.cancel();
    _budSub?.cancel();
    _walSub?.cancel();

    isLoading = true; notifyListeners();
    
    _txSub = _service.transactionsStream(userId).listen((list) {
      _transactions = list; isLoading = false; notifyListeners();
    });
    _catSub = _service.categoriesStream(userId).listen((list) {
      if (list.isEmpty) _service.seedCategories(userId);
      _categories = list; notifyListeners();
    });
    _setSub = _service.settingsStream(userId).listen((s) {
      _settings = s; notifyListeners();
    });
    _budSub = _budgetService.budgetsStream(userId).listen((list) {
      _budgets = list; notifyListeners();
    });
    _walSub = _walletService.walletsStream(userId).listen((list) {
      if (list.isEmpty) _walletService.seedDefaultWallet(userId);
      _wallets = list; notifyListeners();
    });
  }

  Future<void> refresh() async {
    if (_currentUserId == null) return;
    final uid = _currentUserId!;
    _currentUserId = null;
    listen(uid);
    await Future.delayed(const Duration(milliseconds: 800));
  }

  void clear() {
    _currentUserId = null;
    _txSub?.cancel();
    _catSub?.cancel();
    _setSub?.cancel();
    _budSub?.cancel();
    _walSub?.cancel();
    _transactions = [];
    _categories = [];
    _budgets = [];
    _wallets = [];
    _settings = const UserSettings();
    notifyListeners();
  }

  Future<void> addTransaction({
    required String userId,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? note,
    String? walletId,
  }) {
    return _service.addTransaction(Transaction(
      id: '', userId: userId, amount: amount,
      type: type, categoryId: categoryId, date: date, note: note, walletId: walletId,
    ));
  }

  Future<void> updateTransaction(Transaction updated) =>
    _service.updateTransaction(updated);

  Future<void> deleteTransaction(String id) =>
    _service.deleteTransaction(id);

  Future<void> addCategory(
      String userId, String name, String icon, TransactionType type, {String? colorHex}) =>
    _service.addCategory(Category(
      id: '', userId: userId, name: name, icon: icon, type: type, colorHex: colorHex,
    ));

  Future<void> updateCategory(Category updated) =>
    _service.updateCategory(updated);

  Future<bool> deleteCategory(String id) async {
    if (_transactions.any((t) => t.categoryId == id)) return false;
    await _service.deleteCategory(id);
    return true;
  }

  // Wallet methods
  double getWalletBalance(Wallet w) {
    final txs = _transactions.where((t) => t.walletId == w.id);
    final income = txs.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
    final expense = txs.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
    return w.initialBalance + income - expense;
  }

  Future<void> addWallet(Wallet w) => _walletService.addWallet(w);
  
  Future<void> updateWallet(Wallet w) => _walletService.updateWallet(w);
  
  Future<bool> deleteWallet(String id) async {
    if (_transactions.any((t) => t.walletId == id)) return false;
    await _walletService.deleteWallet(id);
    return true;
  }

  // Budget methods
  Future<void> setBudget(Budget b) => _budgetService.setBudget(b);
  
  Future<void> deleteBudget(String id) => _budgetService.deleteBudget(id);
  
  double getCategorySpent(String categoryId, DateTime month) {
    return _forMonth(month)
      .where((t) => t.type == TransactionType.expense && t.categoryId == categoryId)
      .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> updateSettings(String userId, UserSettings updated) =>
    _service.updateSettings(userId, updated);

  Future<void> clearAllData(String userId) =>
    _service.clearAllData(userId);

  // Reports helpers
  ({double income, double expense}) totals(DateTime month) {
    final f = _forMonth(month);
    return (
      income:  f.where((t) => t.type == TransactionType.income) .fold(0.0, (s, t) => s + t.amount),
      expense: f.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount),
    );
  }

  List<(Category, double)> breakdown(DateTime month) {
    final expenses = _forMonth(month).where((t) => t.type == TransactionType.expense);
    final map = <String, double>{};
    for (final t in expenses) {
      map[t.categoryId] = (map[t.categoryId] ?? 0.0) + t.amount;
    }
    
    for (final b in _budgets) {
      if (b.month.year == month.year && b.month.month == month.month) {
        if (!map.containsKey(b.categoryId)) {
          map[b.categoryId] = 0.0;
        }
      }
    }

    return map.entries.map((e) {
      final cat = _categories.firstWhere((c) => c.id == e.key,
        orElse: () => Category(id: e.key, userId: '', name: 'Unknown',
                               icon: '?', type: TransactionType.expense));
      return (cat, e.value);
    }).toList()..sort((a, b) => b.$2.compareTo(a.$2));
  }

  // Private helpers
  double _sum(TransactionType type) =>
    _transactions.where((t) => t.type == type).fold(0.0, (s, t) => s + t.amount);

  List<Transaction> _forMonth(DateTime m) =>
    _transactions.where((t) =>
      t.date.year == m.year && t.date.month == m.month).toList();
}
