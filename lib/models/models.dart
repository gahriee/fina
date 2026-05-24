import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? note;
  final String? walletId;

  const Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.walletId,
  });

  factory Transaction.fromMap(String id, Map<String, dynamic> map) => Transaction(
    id:         id,
    userId:     map['userId']     as String,
    amount:     (map['amount']    as num).toDouble(),
    type:       TransactionType.values.byName(map['type'] as String),
    categoryId: map['categoryId'] as String,
    date:       (map['date']      as Timestamp).toDate(),
    note:       map['note']       as String?,
    walletId:   map['walletId']   as String?,
  );

  Map<String, dynamic> toMap() => {
    'userId':     userId,
    'amount':     amount,
    'type':       type.name,
    'categoryId': categoryId,
    'date':       Timestamp.fromDate(date),
    'note':       note,
    'walletId':   walletId,
  };
}

class Category {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final TransactionType type;
  final String? colorHex;

  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.type,
    this.colorHex,
  });

  factory Category.fromMap(String id, Map<String, dynamic> map) => Category(
    id:       id,
    userId:   map['userId'] as String,
    name:     map['name']   as String,
    icon:     map['icon']   as String,
    type:     TransactionType.values.byName(map['type'] as String),
    colorHex: map['colorHex'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'userId':   userId,
    'name':     name,
    'icon':     icon,
    'type':     type.name,
    'colorHex': colorHex,
  };

  Category copyWith({
    String? name,
    String? icon,
    TransactionType? type,
    String? colorHex,
  }) {
    return Category(
      id: this.id,
      userId: this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}

class UserSettings {
  final String currencySymbol;
  final AppThemeMode themeMode;

  const UserSettings({
    this.currencySymbol = '\$',
    this.themeMode      = AppThemeMode.system,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) => UserSettings(
    currencySymbol: map['currencySymbol'] as String? ?? '\$',
    themeMode: AppThemeMode.values.byName(map['themeMode'] as String? ?? 'system'),
  );

  Map<String, dynamic> toMap() => {
    'currencySymbol': currencySymbol,
    'themeMode':      themeMode.name,
  };

  UserSettings copyWith({String? currencySymbol, AppThemeMode? themeMode}) {
    return UserSettings(
      currencySymbol: currencySymbol ?? this.currencySymbol,
      themeMode:      themeMode      ?? this.themeMode,
    );
  }
}

enum TransactionType { income, expense }

extension TransactionTypeX on TransactionType {
  String get label => name[0].toUpperCase() + name.substring(1);
  Color get color {
    switch (this) {
      case TransactionType.income:  return const Color(0xFF16A34A);
      case TransactionType.expense: return const Color(0xFFDC2626);
    }
  }
  String get sign {
    switch (this) {
      case TransactionType.income:  return '+';
      case TransactionType.expense: return '-';
    }
  }
}

enum AppThemeMode { system, light, dark }

extension AppThemeModeX on AppThemeMode {
  ThemeMode get flutterValue {
    switch (this) {
      case AppThemeMode.light:  return ThemeMode.light;
      case AppThemeMode.dark:   return ThemeMode.dark;
      case AppThemeMode.system: return ThemeMode.system;
    }
  }
}

class Wallet {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final double initialBalance;

  const Wallet({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    this.initialBalance = 0.0,
  });

  factory Wallet.fromMap(String id, Map<String, dynamic> map) => Wallet(
    id:             id,
    userId:         map['userId'] as String,
    name:           map['name']   as String,
    icon:           map['icon']   as String,
    initialBalance: (map['initialBalance'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toMap() => {
    'userId':         userId,
    'name':           name,
    'icon':           icon,
    'initialBalance': initialBalance,
  };

  Wallet copyWith({
    String? name,
    String? icon,
    double? initialBalance,
  }) {
    return Wallet(
      id: this.id,
      userId: this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      initialBalance: initialBalance ?? this.initialBalance,
    );
  }
}

class Budget {
  final String id;
  final String userId;
  final String categoryId;
  final double amountLimit;
  final DateTime month;

  const Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amountLimit,
    required this.month,
  });

  factory Budget.fromMap(String id, Map<String, dynamic> map) => Budget(
    id:          id,
    userId:      map['userId']     as String,
    categoryId:  map['categoryId'] as String,
    amountLimit: (map['amountLimit'] as num).toDouble(),
    month:       (map['month']     as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'userId':      userId,
    'categoryId':  categoryId,
    'amountLimit': amountLimit,
    'month':       Timestamp.fromDate(month),
  };

  Budget copyWith({
    String? categoryId,
    double? amountLimit,
    DateTime? month,
  }) {
    return Budget(
      id:          this.id,
      userId:      this.userId,
      categoryId:  categoryId  ?? this.categoryId,
      amountLimit: amountLimit ?? this.amountLimit,
      month:       month       ?? this.month,
    );
  }
}
