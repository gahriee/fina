# Fina — Flutter Architecture

**App:** Fina · **Platform:** iOS + Android · **Language:** Dart · **UI:** Flutter · **Pattern:** MVVM

> ✅ One codebase, both platforms. Firebase-backed — data syncs across devices.

---

## Philosophy

> If Flutter can do it, we don't add a package for it.

| Concern          | Uses                                     | Built-in?              |
| ---------------- | ---------------------------------------- | ---------------------- |
| State management | `ChangeNotifier` + `ListenableBuilder`   | ✅ Yes                 |
| Navigation       | `Navigator` + `BottomNavigationBar`      | ✅ Yes                 |
| Models           | Plain Dart classes                       | ✅ Yes                 |
| UI icons         | `CupertinoIcons` (Apple-native icon set) | ✅ Yes                 |
| Auth + Database  | Firebase                                 | ❌ External (required) |

**Total added packages: 4** — `firebase_core`, `firebase_auth`, `cloud_firestore`, `cupertino_icons`. That's it.

---

## 1. Features

| #   | Feature      | Description                                                   |
| --- | ------------ | ------------------------------------------------------------- |
| 1   | Dashboard    | Total balance, income vs expense summary, recent transactions |
| 2   | Transactions | Add, edit, delete income and expense entries                  |
| 3   | Categories   | Simple labels for grouping transactions                       |
| 4   | Reports      | Monthly spending breakdown by category                        |
| 5   | Settings     | Currency symbol, theme, clear data                            |

---

## 2. Project Structure

```
kita/
├── lib/
│   ├── main.dart                          # Entry point + MaterialApp + auth gate
│   │
│   ├── app/
│   │   └── theme.dart                     # AppColors, lightTheme, darkTheme
│   │
│   ├── models/
│   │   └── models.dart                    # All data classes and enums
│   │
│   ├── services/
│   │   ├── auth_service.dart              # Firebase Auth wrapper
│   │   └── transaction_service.dart       # Firestore CRUD + streams
│   │
│   ├── viewmodels/
│   │   ├── auth_viewmodel.dart            # ChangeNotifier — auth state
│   │   └── transaction_viewmodel.dart     # ChangeNotifier — all transaction/category logic
│   │
│   ├── screens/
│   │   ├── auth_screen.dart               # Login + Register
│   │   ├── main_screen.dart               # BottomNavigationBar shell
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── transactions/
│   │   │   ├── transaction_list_screen.dart
│   │   │   └── add_transaction_sheet.dart
│   │   ├── reports/
│   │   │   └── reports_screen.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       └── category_list_screen.dart
│   │
│   └── widgets/
│       ├── balance_card.dart
│       ├── transaction_tile.dart
│       ├── amount_text.dart
│       ├── empty_state.dart
│       └── category_icon.dart
│
├── pubspec.yaml
└── firebase_options.dart
```

---

## 3. Data Models (`lib/models/models.dart`)

Plain Dart — no code generation, no annotations. Serialization updated from `fromJson`/`toJson` (ISO strings) to `fromMap`/`toMap` (Firestore `Timestamp`).

```dart
class Transaction {
  final String id;
  final String userId;           // ← links to Firebase Auth UID
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? note;

  const Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
  });

  factory Transaction.fromMap(String id, Map<String, dynamic> map) => Transaction(
    id:         id,
    userId:     map['userId']     as String,
    amount:     (map['amount']    as num).toDouble(),
    type:       TransactionType.values.byName(map['type'] as String),
    categoryId: map['categoryId'] as String,
    date:       (map['date']      as Timestamp).toDate(),
    note:       map['note']       as String?,
  );

  Map<String, dynamic> toMap() => {
    'userId':     userId,
    'amount':     amount,
    'type':       type.name,
    'categoryId': categoryId,
    'date':       Timestamp.fromDate(date),
    'note':       note,
  };
}

class Category {
  final String id;
  final String userId;           // ← links to Firebase Auth UID
  final String name;
  final String icon;             // emoji
  final TransactionType type;

  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.type,
  });

  factory Category.fromMap(String id, Map<String, dynamic> map) => Category(
    id:     id,
    userId: map['userId'] as String,
    name:   map['name']   as String,
    icon:   map['icon']   as String,
    type:   TransactionType.values.byName(map['type'] as String),
  );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name':   name,
    'icon':   icon,
    'type':   type.name,
  };
}

class UserSettings {
  final String currencySymbol;
  final AppThemeMode themeMode;

  const UserSettings({
    this.currencySymbol = 'PHP',
    this.themeMode      = AppThemeMode.system,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) => UserSettings(
    currencySymbol: map['currencySymbol'] as String? ?? 'PHP',
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
```

---

## 4. Services

### `lib/services/auth_service.dart`

```dart
class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email, password: password,
    );
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email, password: password,
    );
  }

  Future<void> logout() => _auth.signOut();
}
```

### `lib/services/transaction_service.dart`

```dart
class TransactionService {
  final _db = FirebaseFirestore.instance;

  // ── Transactions ──────────────────────────────────────────────────────────

  Stream<List<Transaction>> transactionsStream(String userId) {
    return _db
      .collection('transactions')
      .where('userId', isEqualTo: userId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs
        .map((d) => Transaction.fromMap(d.id, d.data()))
        .toList());
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

  Future<void> deleteCategory(String id) =>
    _db.collection('categories').doc(id).delete();

  Future<void> seedCategories(String userId) {
    final seeds = [
      ('Food',          '🍔', TransactionType.expense),
      ('Transport',     '🚌', TransactionType.expense),
      ('Housing',       '🏠', TransactionType.expense),
      ('Entertainment', '🎮', TransactionType.expense),
      ('Shopping',      '🛍️', TransactionType.expense),
      ('Others',        '📦', TransactionType.expense),
      ('Salary',        '💼', TransactionType.income),
      ('Freelance',     '💰', TransactionType.income),
      ('Gift',          '🎁', TransactionType.income),
      ('Others',        '💵', TransactionType.income),
    ];
    final batch = _db.batch();
    for (final s in seeds) {
      final ref = _db.collection('categories').doc();
      batch.set(ref, Category(
        id: ref.id, userId: userId, name: s.$1, icon: s.$2, type: s.$3,
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
    for (final d in txSnap.docs)  batch.delete(d.reference);
    for (final d in catSnap.docs) batch.delete(d.reference);
    await batch.commit();
    await seedCategories(userId);
  }
}
```

---

## 5. State Management

**No Riverpod. No Provider package.** Flutter's built-in `ChangeNotifier` + `ListenableBuilder`.

### `lib/viewmodels/auth_viewmodel.dart`

```dart
class AuthViewModel extends ChangeNotifier {
  final _service = AuthService();

  bool isLoading = false;
  String? error;

  Stream<User?> get authStateChanges => _service.authStateChanges;

  Future<void> login(String email, String password) async {
    isLoading = true; error = null; notifyListeners();
    try {
      await _service.login(email, password);
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    isLoading = true; error = null; notifyListeners();
    try {
      await _service.register(email, password);
    } on FirebaseAuthException catch (e) {
      error = e.message;
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> logout() => _service.logout();
}
```

### `lib/viewmodels/transaction_viewmodel.dart`

```dart
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
      income:  f.where((t) => t.type == TransactionType.income) .fold(0, (s, t) => s + t.amount),
      expense: f.where((t) => t.type == TransactionType.expense).fold(0, (s, t) => s + t.amount),
    );
  }

  List<(Category, double)> breakdown(DateTime month) {
    final expenses = _forMonth(month).where((t) => t.type == TransactionType.expense);
    final map = <String, double>{};
    for (final t in expenses) map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    return map.entries.map((e) {
      final cat = _categories.firstWhere((c) => c.id == e.key,
        orElse: () => Category(id: e.key, userId: '', name: 'Unknown',
                               icon: '?', type: TransactionType.expense));
      return (cat, e.value);
    }).toList()..sort((a, b) => b.$2.compareTo(a.$2));
  }

  // Private helpers
  double _sum(TransactionType type) =>
    _transactions.where((t) => t.type == type).fold(0, (s, t) => s + t.amount);

  List<Transaction> _forMonth(DateTime m) =>
    _transactions.where((t) =>
      t.date.year == m.year && t.date.month == m.month).toList();
}
```

### Wiring in `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KitaApp());
}

class KitaApp extends StatefulWidget {
  const KitaApp({super.key});
  @override
  State<KitaApp> createState() => _KitaAppState();
}

class _KitaAppState extends State<KitaApp> {
  final _authVM        = AuthViewModel();
  final _transactionVM = TransactionViewModel();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _transactionVM,
      builder: (_, __) => MaterialApp(
        title: 'Kita',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: _transactionVM.settings.themeMode.flutterValue,
        // Auth gate — StreamBuilder replaces go_router redirect
        home: StreamBuilder<User?>(
          stream: _authVM.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasData) {
              _transactionVM.listen(snapshot.data!.uid);
              return MainScreen(transactionVM: _transactionVM, authVM: _authVM);
            }
            return AuthScreen(authVM: _authVM);
          },
        ),
      ),
    );
  }
}
```

---

## 6. Navigation Flow

```
AuthScreen (Login / Register)
  └── on login → MainScreen

MainScreen (BottomNavigationBar)
  ├── Tab 1: DashboardScreen
  │     └── FAB → showModalBottomSheet → AddTransactionSheet
  │
  ├── Tab 2: TransactionListScreen
  │     ├── SegmentedButton row: All · Income · Expense
  │     ├── Tap row → AddTransactionSheet (edit mode)
  │     ├── Dismissible swipe-to-delete (with undo SnackBar)
  │     └── FAB → AddTransactionSheet
  │
  ├── Tab 3: ReportsScreen
  │     └── Month picker (prev/next arrows) + category breakdown
  │
  └── Tab 4: SettingsScreen
        └── Navigator.push → CategoryListScreen
```

---

## 7. Screens

### UI Design Language

All screens follow an **Apple-native aesthetic** using Flutter's Material 3 styled to iOS visual conventions:

| Element           | Implementation                                                                               |
| ----------------- | -------------------------------------------------------------------------------------------- |
| Icons             | `CupertinoIcons` throughout — tabs, actions, nav arrows, indicators                          |
| Tab bar           | `NavigationBar` (M3) styled to match iOS tab bar — translucent background, SF-style labels   |
| Cards             | `borderRadius: 16`, zero elevation, thin `outline` border — matches iOS grouped list cells   |
| Bottom sheets     | `showModalBottomSheet` with `useSafeArea: true`, drag handle, `borderRadius: 20` top corners |
| Buttons           | Rounded `FilledButton` (primary) and `TextButton` (destructive red) — no square corners      |
| Text fields       | Filled style with `borderRadius: 12` — matches iOS `UITextField` appearance                  |
| Haptics           | `HapticFeedback.lightImpact()` on FAB tap; `HapticFeedback.selectionClick()` on tab switch   |
| Segmented control | `SegmentedButton` — mirrors iOS `UISegmentedControl`                                         |

### AuthScreen

- Email + password `TextField` (iOS-style filled, rounded)
- Toggle between **Sign In** and **Create Account** — no separate screen
- `FilledButton` for primary action; `TextButton` to switch mode
- Error message from `authVM.error` shown inline in red
- `CupertinoIcons.person_circle` large header icon, centered

### DashboardScreen

- **BalanceCard** — `transactionVM.balance` formatted with currency symbol, full-width, `borderRadius: 16`
- **This Month strip** — income (green) + expense (red) totals side by side
- **Recent** — last 5 from `transactionVM.recentTransactions` as `TransactionTile` rows
- FAB (`CupertinoIcons.add`) → `showModalBottomSheet` with `AddTransactionSheet`

### TransactionListScreen

- Date-grouped `ListView` with date section headers
- `SegmentedButton`: All · Income · Expense — filters in-memory, no extra reads
- `Dismissible` swipe-to-delete with `SnackBar` undo action
- Tap `TransactionTile` → `AddTransactionSheet` in edit mode

### AddTransactionSheet _(bottom sheet)_

- Drag handle at top, `borderRadius: 20` top corners
- Amount `TextField` (numeric keyboard) with currency symbol prefix
- `SegmentedButton`: Income / Expense
- `DropdownButton` for category — filtered by selected type
- `showDatePicker()` — defaults to today
- Optional note `TextField`
- Save (`CupertinoIcons.checkmark_alt`) and Cancel (`CupertinoIcons.xmark`) in sheet header row

### ReportsScreen

- Month/year row with `CupertinoIcons.chevron_left` / `CupertinoIcons.chevron_right` arrows
- Income and expense totals for selected month
- Category expense list — icon, name, amount, `LinearProgressIndicator` as percentage bar

### CategoryListScreen _(pushed from Settings)_

- `ListTile` per category: icon + name + type badge
- FAB → inline create form: name + emoji icon + type `SegmentedButton`
- `Dismissible` swipe-to-delete — if category is in use, shows `SnackBar` error

### SettingsScreen

- Currency symbol `TextField`
- Appearance `SegmentedButton`: System / Light / Dark
- **Account** section — signed-in email + `CupertinoIcons.square_arrow_right` logout button
- **Manage Categories** → `Navigator.push(CategoryListScreen)`
- **Clear All Data** red `TextButton` → `showDialog` confirm → `transactionVM.clearAllData(uid)`

---

## 8. Key Operations

| Operation          | Method                                                                       |
| ------------------ | ---------------------------------------------------------------------------- |
| Register           | `authVM.register(email, password)`                                           |
| Login              | `authVM.login(email, password)`                                              |
| Logout             | `authVM.logout()`                                                            |
| Stream data        | `transactionVM.listen(userId)` — called once on login                        |
| Add transaction    | `transactionVM.addTransaction(userId, amount, type, categoryId, date, note)` |
| Edit transaction   | `transactionVM.updateTransaction(updated)`                                   |
| Delete transaction | `transactionVM.deleteTransaction(id)`                                        |
| Add category       | `transactionVM.addCategory(userId, name, icon, type)`                        |
| Delete category    | `transactionVM.deleteCategory(id)` — returns `false` if in use               |
| Monthly totals     | `transactionVM.totals(month)` — named record `(income, expense)`             |
| Category breakdown | `transactionVM.breakdown(month)` — sorted list of `(Category, double)`       |
| Update settings    | `transactionVM.updateSettings(userId, updated)`                              |
| Clear all data     | `transactionVM.clearAllData(userId)`                                         |

---

## 9. Persistence & Backend

**Firebase — Authentication + Firestore**

```
/transactions/{transactionId}
  userId:     String    ← links to Firebase Auth UID
  amount:     Double
  type:       String    ← "income" | "expense"
  categoryId: String
  date:       Timestamp ← used for sort order
  note:       String?

/categories/{categoryId}
  userId: String
  name:   String
  icon:   String        ← emoji
  type:   String        ← "income" | "expense"

/settings/{userId}
  currencySymbol: String
  themeMode:      String ← "system" | "light" | "dark"
```

**Firestore Security Rules**

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /transactions/{txId} {
      allow read, write: if request.auth != null
        && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
    }

    match /categories/{catId} {
      allow read, write: if request.auth != null
        && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
    }

    match /settings/{userId} {
      allow read, write: if request.auth != null
        && request.auth.uid == userId;
    }
  }
}
```

Offline persistence is on by default — data loads from the local Firestore cache instantly, syncs when reconnected.

---

## 10. Default Seed Categories

Seeded via `TransactionService.seedCategories(userId)` on first login — triggered automatically in `TransactionViewModel.listen()` when `_categories.isEmpty`.

| Type    | Categories                                                     |
| ------- | -------------------------------------------------------------- |
| Expense | Food · Transport · Housing · Entertainment · Shopping · Others |
| Income  | Salary · Freelance · Gift · Others                             |

---

## 11. Deletion Rules

```
Delete Transaction  →  removed immediately from Firestore, no cascade

Delete Category
  └── blocked if any transaction references it
  └── transactionVM.deleteCategory() returns false
  └── screen shows SnackBar: "Reassign or delete transactions first"
```

---

## 12. Color Scheme

### Brand Palette

| Token          | Light Mode           | Dark Mode            | Usage                         |
| -------------- | -------------------- | -------------------- | ----------------------------- |
| primary        | `#EA580C` Orange 600 | `#FB923C` Orange 400 | Buttons, FAB, active tabs     |
| surface        | `#FFFFFF`            | `#1C1C1E`            | Cards, sheets, list rows      |
| background     | `#F2F2F7`            | `#000000`            | Screen backgrounds            |
| surfaceVariant | `#F2F2F7`            | `#2C2C2E`            | Input fields, secondary cards |
| outline        | `#C6C6C8`            | `#38383A`            | Dividers, borders             |
| textPrimary    | `#000000`            | `#FFFFFF`            | Main labels                   |
| textSecondary  | `#6C6C70`            | `#98989D`            | Subtitles, placeholders       |
| income         | `#16A34A` Green 600  | `#4ADE80` Green 400  | Income amounts and badges     |
| expense        | `#DC2626` Red 600    | `#F87171` Red 400    | Expense amounts and badges    |
| warning        | `#D97706` Amber 600  | `#FBBF24` Amber 400  | Budget warnings (future use)  |

### Implementation (`lib/app/theme.dart`)

```dart
class AppColors {
  static const primary            = Color(0xFFEA580C);
  static const primaryDark        = Color(0xFFFB923C);

  static const background         = Color(0xFFF2F2F7);
  static const backgroundDark     = Color(0xFF000000);
  static const surface            = Color(0xFFFFFFFF);
  static const surfaceDark        = Color(0xFF1C1C1E);
  static const surfaceVariant     = Color(0xFFF2F2F7);
  static const surfaceVariantDark = Color(0xFF2C2C2E);

  static const textPrimary        = Color(0xFF000000);
  static const textPrimaryDark    = Color(0xFFFFFFFF);
  static const textSecondary      = Color(0xFF6C6C70);
  static const textSecondaryDark  = Color(0xFF98989D);

  static const outline            = Color(0xFFC6C6C8);
  static const outlineDark        = Color(0xFF38383A);

  static const income             = Color(0xFF16A34A);
  static const incomeDark         = Color(0xFF4ADE80);
  static const expense            = Color(0xFFDC2626);
  static const expenseDark        = Color(0xFFF87171);
  static const warning            = Color(0xFFD97706);
  static const warningDark        = Color(0xFFFBBF24);
}

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary:                 AppColors.primary,
    onPrimary:               Colors.white,
    surface:                 AppColors.surface,
    surfaceContainerHighest: AppColors.surfaceVariant,
    outline:                 AppColors.outline,
    onSurface:               AppColors.textPrimary,
    onSurfaceVariant:        AppColors.textSecondary,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.outline),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariant,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor:     AppColors.surface,
    selectedItemColor:   AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    elevation: 0,
  ),
  dividerTheme: const DividerThemeData(color: AppColors.outline),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary:                 AppColors.primaryDark,
    onPrimary:               Colors.white,
    surface:                 AppColors.surfaceDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    outline:                 AppColors.outlineDark,
    onSurface:               AppColors.textPrimaryDark,
    onSurfaceVariant:        AppColors.textSecondaryDark,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textPrimaryDark,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surfaceDark,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.outlineDark),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor:     AppColors.surfaceDark,
    selectedItemColor:   AppColors.primaryDark,
    unselectedItemColor: AppColors.textSecondaryDark,
    elevation: 0,
  ),
  dividerTheme: const DividerThemeData(color: AppColors.outlineDark),
);
```

### AmountText Widget (`lib/widgets/amount_text.dart`)

```dart
// Always use this widget for any monetary amount — never hardcode colors in screens.
class AmountText extends StatelessWidget {
  final double amount;
  final TransactionType type;
  final String currencySymbol;
  final TextStyle? style;

  const AmountText({
    super.key,
    required this.amount,
    required this.type,
    required this.currencySymbol,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = type == TransactionType.income
        ? (isDark ? AppColors.incomeDark  : AppColors.income)
        : (isDark ? AppColors.expenseDark : AppColors.expense);
    return Text(
      '${type.sign}$currencySymbol${amount.toStringAsFixed(2)}',
      style: (style ?? Theme.of(context).textTheme.bodyMedium)
               ?.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}
```

---

## 13. Typography Scale

Flutter uses the Material 3 type scale. Mapping from the original SF Pro scale:

| Original (SF Pro)        | Flutter (Material 3) | Usage                           |
| ------------------------ | -------------------- | ------------------------------- |
| largeTitle 34pt Bold     | `displaySmall`       | Dashboard balance amount        |
| title2 22pt Semibold     | `titleLarge`         | Section headers                 |
| headline 17pt Semibold   | `titleMedium`        | Transaction amount, card titles |
| body 17pt Regular        | `bodyMedium`         | Default text                    |
| subheadline 15pt Regular | `bodySmall`          | Category name, date label       |
| caption 12pt Regular     | `labelSmall`         | Note text, metadata             |

Dynamic Type (accessibility text scaling) is supported automatically via Flutter's `MediaQuery.textScaler`.

---

## 14. Module Responsibilities

| Module                                  | Responsibility                                                                           |
| --------------------------------------- | ---------------------------------------------------------------------------------------- |
| `models/models.dart`                    | Plain Dart classes — `fromMap`, `toMap`, `copyWith`. No logic.                           |
| `services/auth_service.dart`            | Firebase Auth wrapper only — no business logic.                                          |
| `services/transaction_service.dart`     | Firestore CRUD + streams — no business logic.                                            |
| `viewmodels/auth_viewmodel.dart`        | `ChangeNotifier` — auth state, loading, error.                                           |
| `viewmodels/transaction_viewmodel.dart` | `ChangeNotifier` — all transaction/category/settings operations and report calculations. |
| `screens/`                              | Presentation only. Reads viewmodel, calls viewmodel methods.                             |
| `widgets/`                              | Reusable UI pieces with no viewmodel dependency.                                         |

---

## 15. `pubspec.yaml`

```yaml
name: kita
description: A simple personal finance tracker.

dependencies:
  flutter:
    sdk: flutter

  # Firebase — Auth + Firestore
  firebase_core: ^3.x.x
  firebase_auth: ^5.x.x
  cloud_firestore: ^5.x.x

  # Apple-native icon set
  cupertino_icons: ^1.x.x

dev_dependencies:
  flutter_test:
    sdk: flutter
```

---

## 16. System Requirements

| Tool     | Version                 |
| -------- | ----------------------- |
| Flutter  | 3.41.1 (stable channel) |
| Dart     | 3.11.0                  |
| DevTools | 2.54.1                  |

### iOS — Direct Device Install (Free Apple ID)

> iOS builds require a Mac.

| Requirement                 | Notes                           |
| --------------------------- | ------------------------------- |
| macOS Ventura (13)+         | Required to run Xcode           |
| Xcode latest stable or beta | Free from Mac App Store         |
| CocoaPods latest            | `sudo gem install cocoapods`    |
| iPhone running iOS 13+      | Flutter 3.41 supports iOS 13–26 |

App certificate expires every **7 days** with a free Apple ID. Reinstall: `flutter run --release`.

**One-Time Device Setup:**

1. Connect iPhone via USB, tap **Trust** on device
2. Settings > Privacy and Security > Developer Mode, toggle On and restart
3. Xcode > Settings > Accounts, add your Apple ID
4. Open `ios/Runner.xcworkspace`, select device, set **Team** in Signing and Capabilities, hit **Run**

### Android

| Requirement      | Version                          |
| ---------------- | -------------------------------- |
| Android Studio   | Latest stable                    |
| minSdkVersion    | 24                               |
| targetSdkVersion | 36                               |
| JDK              | 17 (bundled with Android Studio) |

---

## 17. GitHub & Setup

```bash
# 1. Create project
flutter create kita --platforms=ios,android
cd kita

# 2. Push to GitHub
git init && git add . && git commit -m "initial commit"
git remote add origin https://github.com/yourusername/kita.git
git branch -M main && git push -u origin main

# 3. Configure Firebase
dart pub global activate flutterfire_cli
flutterfire configure

# 4. Install dependencies
flutter pub get

# 5a. Run on Android
flutter run

# 5b. Run on iPhone
cd ios && pod install && cd ..
open ios/Runner.xcworkspace   # set Team in Signing and Capabilities, then hit Run
```

### After Fresh Clone

```bash
git clone https://github.com/yourusername/kita.git
cd kita
flutter pub get
flutterfire configure    # re-generates firebase_options.dart
cd ios && pod install && cd ..
flutter run
```

### `.gitignore` — Key Entries

```
google-services.json
GoogleService-Info.plist
firebase_options.dart
build/
.dart_tool/
ios/Pods/
android/.gradle/
```
