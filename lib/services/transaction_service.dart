import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/models.dart';

class TransactionService {
  final _db = FirebaseFirestore.instance;

  // ── Transactions ──────────────────────────────────────────────────────────

  Stream<List<Transaction>> transactionsStream(String userId) {
    return _db
      .collection('transactions')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snap) {
        final docs = snap.docs
          .map((d) => Transaction.fromMap(d.id, d.data()))
          .toList();
        // Sort client-side to avoid requiring a composite index in Firestore
        docs.sort((a, b) => b.date.compareTo(a.date));
        return docs;
      });
  }

  Future<void> addTransaction(Transaction t) =>
    _db.collection('transactions').add(t.toMap());

  Future<void> updateTransaction(Transaction t) =>
    _db.collection('transactions').doc(t.id).update(t.toMap());

  Future<void> deleteTransaction(String id) =>
    _db.collection('transactions').doc(id).delete();

  // ── Categories ────────────────────────────────────────────────────────────

  Stream<List<Category>> categoriesStream(String userId) {
    return _db
      .collection('categories')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snap) => snap.docs
        .map((d) => Category.fromMap(d.id, d.data()))
        .toList());
  }

  Future<void> addCategory(Category c) =>
    _db.collection('categories').add(c.toMap());

  Future<void> updateCategory(Category c) =>
    _db.collection('categories').doc(c.id).update(c.toMap());

  Future<void> deleteCategory(String id) =>
    _db.collection('categories').doc(id).delete();

  Future<void> seedCategories(String userId) {
    final seeds = [
      ('Food',          'food', TransactionType.expense, '#FF5722'),
      ('Transport',     'transport', TransactionType.expense, '#2196F3'),
      ('Housing',       'home', TransactionType.expense, '#9C27B0'),
      ('Entertainment', 'entertainment', TransactionType.expense, '#E91E63'),
      ('Shopping',      'shopping', TransactionType.expense, '#00BCD4'),
      ('Others',        'box', TransactionType.expense, '#9E9E9E'),
      ('Salary',        'salary', TransactionType.income, '#4CAF50'),
      ('Freelance',     'money', TransactionType.income, '#8BC34A'),
      ('Gift',          'gift', TransactionType.income, '#FF9800'),
      ('Others',        'box', TransactionType.income, '#9E9E9E'),
    ];
    final batch = _db.batch();
    for (final s in seeds) {
      final ref = _db.collection('categories').doc();
      batch.set(ref, Category(
        id: ref.id, userId: userId, name: s.$1, icon: s.$2, type: s.$3, colorHex: s.$4,
      ).toMap());
    }
    return batch.commit();
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  Stream<UserSettings> settingsStream(String userId) {
    return _db
      .collection('settings')
      .doc(userId)
      .snapshots()
      .map((doc) => doc.exists
        ? UserSettings.fromMap(doc.data()!)
        : const UserSettings());
  }

  Future<void> updateSettings(String userId, UserSettings s) =>
    _db.collection('settings').doc(userId).set(s.toMap());

  Future<void> clearAllData(String userId) async {
    final batch = _db.batch();
    final txSnap  = await _db.collection('transactions')
      .where('userId', isEqualTo: userId).get();
    final catSnap = await _db.collection('categories')
      .where('userId', isEqualTo: userId).get();
    final walletSnap = await _db.collection('wallets')
      .where('userId', isEqualTo: userId).get();
    final budgetSnap = await _db.collection('budgets')
      .where('userId', isEqualTo: userId).get();
      
    for (final d in txSnap.docs) { batch.delete(d.reference); }
    for (final d in catSnap.docs) { batch.delete(d.reference); }
    for (final d in walletSnap.docs) { batch.delete(d.reference); }
    for (final d in budgetSnap.docs) { batch.delete(d.reference); }
    
    await batch.commit();
    await seedCategories(userId);
  }
}
