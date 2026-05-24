# Fina — Personal Finance Tracker

**Fina** is a simple, elegant personal finance tracker built with Flutter. It follows an **Apple-native aesthetic** and uses an **MVVM architecture** with built-in state management (`ChangeNotifier`), backed by Firebase.

## Features

- **Dashboard:** View total balance, income vs. expense summary, and recent transactions.
- **Transactions:** Add, edit, and delete income and expense entries.
- **Categories:** Simple labels and emojis for grouping transactions.
- **Reports:** Monthly spending breakdown by category.
- **Settings:** Customize currency symbol, app theme (Light/Dark/System), and manage data.

## Tech Stack

- **Platform:** iOS + Android
- **Language:** Dart
- **UI:** Flutter (Material 3 styled to iOS conventions, `CupertinoIcons`)
- **Pattern:** MVVM
- **State Management:** Built-in `ChangeNotifier` + `ListenableBuilder` (No external packages)
- **Backend:** Firebase (Auth + Firestore)

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/fina.git
   cd fina
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Configure Firebase**
   Ensure you have the Firebase CLI installed and configured.
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
4. **Run the app**
   ```bash
   flutter run
   ```

For detailed architectural decisions, see the [Architecture Document](finance-tracker-architecture.md) and the [Project Status](project-status.md).
