import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class BudgetService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Budget>> budgetsStream(String userId) {
    return _db
      .collection('budgets')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snap) => snap.docs
        .map((d) => Budget.fromMap(d.id, d.data()))
        .toList());
  }

  Future<void> setBudget(Budget b) async {
    // Upsert budget based on category and month (using a compound ID or just letting Firestore handle it)
    // We can use a combination of categoryId and month string as the document ID to easily upsert
    final monthStr = '${b.month.year}-${b.month.month.toString().padLeft(2, '0')}';
    final docId = '${b.userId}_${b.categoryId}_$monthStr';
    
    await _db.collection('budgets').doc(docId).set(b.toMap());
  }

  Future<void> deleteBudget(String id) =>
    _db.collection('budgets').doc(id).delete();
}
