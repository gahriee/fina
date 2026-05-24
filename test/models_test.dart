import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:fina/models/models.dart';

void main() {
  group('Models Serialization', () {
    test('Transaction toMap and fromMap', () {
      final t = Transaction(
        id: '123',
        userId: 'u1',
        amount: 50.5,
        type: TransactionType.expense,
        categoryId: 'c1',
        date: DateTime(2023, 10, 1),
        note: 'Test note',
      );

      final map = t.toMap();
      expect(map['userId'], 'u1');
      expect(map['amount'], 50.5);
      expect(map['type'], 'expense');
      
      final t2 = Transaction.fromMap('123', map);
      expect(t2.id, '123');
      expect(t2.userId, 'u1');
      expect(t2.amount, 50.5);
      expect(t2.type, TransactionType.expense);
      expect(t2.date.year, 2023);
      expect(t2.note, 'Test note');
    });

    test('Category toMap and fromMap', () {
      final c = Category(
        id: 'c1',
        userId: 'u1',
        name: 'Groceries',
        icon: '🛒',
        type: TransactionType.expense,
      );

      final map = c.toMap();
      final c2 = Category.fromMap('c1', map);

      expect(c2.id, 'c1');
      expect(c2.name, 'Groceries');
      expect(c2.icon, '🛒');
      expect(c2.type, TransactionType.expense);
    });

    test('UserSettings toMap and fromMap', () {
      const s = UserSettings(
        currencySymbol: '€',
        themeMode: AppThemeMode.dark,
      );

      final map = s.toMap();
      final s2 = UserSettings.fromMap(map);

      expect(s2.currencySymbol, '€');
      expect(s2.themeMode, AppThemeMode.dark);
    });
  });
}
