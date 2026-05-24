# Project Status: Fina

**App:** Fina  
**Platform:** iOS + Android  
**Language:** Dart / Flutter  
**Architecture:** MVVM (using built-in `ChangeNotifier` + `ListenableBuilder`)  
**Backend:** Firebase (Auth + Firestore)

---

## 📌 Phase 1: Planning & Setup
- [x] Define app architecture and technical choices (`finance-tracker-architecture.md`)
- [x] Initialize Flutter project
- [x] Update README with project details
- [x] Configure Firebase project (Auth & Firestore)
- [x] Run `flutterfire configure` to generate `firebase_options.dart`
- [x] Add Firebase dependencies to `pubspec.yaml` (`firebase_core`, `firebase_auth`, `cloud_firestore`)
- [x] Add UI dependencies to `pubspec.yaml` (`cupertino_icons`)

## 🛠 Phase 2: Core Foundation (Models & Services)
- [x] Create `lib/app/theme.dart` (Light/Dark themes, AppColors)
- [x] Create `lib/models/models.dart` (`Transaction`, `Category`, `UserSettings`, enums)
- [x] Create `lib/services/auth_service.dart` (Firebase Auth integration)
- [x] Create `lib/services/transaction_service.dart` (Firestore CRUD & Streams)

## 🧠 Phase 3: State Management (ViewModels)
- [x] Create `lib/viewmodels/auth_viewmodel.dart`
- [x] Create `lib/viewmodels/transaction_viewmodel.dart`

## 📱 Phase 4: UI Shared Components
- [x] Create `AmountText` widget
- [x] Create `BalanceCard` widget
- [x] Create `TransactionTile` widget
- [x] Create `CategoryIcon` widget
- [x] Create `EmptyState` widget

## 🚀 Phase 5: Application Screens
- [x] **Auth:** Implement `AuthScreen` (Login/Register)
- [x] **Shell:** Implement `MainScreen` with `BottomNavigationBar`
- [x] **Dashboard:** Implement `DashboardScreen`
- [x] **Transactions:** Implement `TransactionListScreen` and `AddTransactionSheet`
- [x] **Reports:** Implement `ReportsScreen` (Monthly breakdown)
- [x] **Settings:** Implement `SettingsScreen` and `CategoryListScreen`
- [x] **Entry Point:** Wire up `main.dart` with `StreamBuilder` for Auth Gate

## 🧪 Phase 6: Testing & Polish
- [ ] Test offline persistence and data sync (Manual via QA Playbook)
- [ ] Test auth flows and session handling (Manual via QA Playbook)
- [x] UI Polish (Ensured iOS/Apple-native aesthetic compliance & Scroll Physics)
- [ ] Final device testing (iOS & Android)
