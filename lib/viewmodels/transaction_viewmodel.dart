import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/transaction_service.dart';

class TransactionViewModel extends ChangeNotifier {
  final _service = TransactionService();

  List<Transaction> _transactions = [];
  List<Category>    _categories   = [];
  UserSettings      _settings     = const UserSettings();
  bool isLoading = false;
  String? error;

  List<Transaction> get transactions => _transactions;
  List<Category>    get categories   => _categories;
  UserSettings      get settings     => _settings;

  double get totalIncome  => _sum(TransactionType.income);
  double get totalExpense => _sum(TransactionType.expense);
  double get balance      => totalIncome - totalExpense;

  List<Transaction> get recentTransactions =>
    ([..._transactions]..sort((a, b) => b.date.compareTo(a.date))).take(5).toList();

  void listen(String userId) {
    isLoading = true; notifyListeners();
    _service.transactionsStream(userId).listen((list) {
      _transactions = list; isLoading = false; notifyListeners();
    });
    _service.categoriesStream(userId).listen((list) {
      if (list.isEmpty) _service.seedCategories(userId);
      _categories = list; notifyListeners();
    });
    _service.settingsStream(userId).listen((s) {
      _settings = s; notifyListeners();
    });
  }

  Future<void> addTransaction({
    required String userId,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? note,
  }) {
    return _service.addTransaction(Transaction(
      id: '', userId: userId, amount: amount,
      type: type, categoryId: categoryId, date: date, note: note,
    ));
  }

  Future<void> updateTransaction(Transaction updated) =>
    _service.updateTransaction(updated);

  Future<void> deleteTransaction(String id) =>
    _service.deleteTransaction(id);

  Future<void> addCategory(
      String userId, String name, String icon, TransactionType type) =>
    _service.addCategory(Category(
      id: '', userId: userId, name: name, icon: icon, type: type,
    ));

  // Returns false if category is in use
  Future<bool> deleteCategory(String id) async {
    if (_transactions.any((t) => t.categoryId == id)) return false;
    await _service.deleteCategory(id);
    return true;
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
