import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class WalletService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Wallet>> walletsStream(String userId) {
    return _db
      .collection('wallets')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snap) => snap.docs
        .map((d) => Wallet.fromMap(d.id, d.data()))
        .toList());
  }

  Future<void> addWallet(Wallet w) =>
    _db.collection('wallets').add(w.toMap());

  Future<void> updateWallet(Wallet w) =>
    _db.collection('wallets').doc(w.id).update(w.toMap());

  Future<void> deleteWallet(String id) =>
    _db.collection('wallets').doc(id).delete();

  Future<void> seedDefaultWallet(String userId) async {
    final defaultWallet = Wallet(
      id: '',
      userId: userId,
      name: 'Cash',
      icon: 'money',
      initialBalance: 0.0,
    );
    await _db.collection('wallets').add(defaultWallet.toMap());
  }
}
