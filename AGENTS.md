# 🤖 Agent Instructions for Fina (Finance Tracker)

Welcome! If you are an AI agent working on the Fina project, you must strictly adhere to the guidelines and context provided in this document to ensure consistency, prevent regressions, and align with the established architectural patterns.

## 📚 Required Reading

Before starting *any* task, you **MUST** read and understand the following core documents:

1.  **`finance-tracker-architecture.md`**: This is the absolute source of truth for the project. It defines the MVVM pattern, the strict "No external packages if Flutter can do it" philosophy, UI design language (Apple-native aesthetic), and exact implementations for models, services, and viewmodels. Do not deviate from this document.
2.  **`project-status.md`**: This tracks the current phase of development. Always check this file to understand what has already been implemented and what the next logical steps are. Do not duplicate work. Update this file whenever you complete a task.

## 🏛️ Core Architectural Principles

-   **State Management**: Use ONLY Flutter's built-in `ChangeNotifier` and `ListenableBuilder`. **Do not** use Riverpod, Provider, GetX, Bloc, or any external state management library.
-   **UI / Design**: Strictly follow the Apple-native aesthetic. Use `CupertinoIcons`, `NavigationBar` (M3 styled as iOS tab bar), and specific `borderRadius: 16` cards with no elevation. Do not use generic Android-style Material Design shadows. Use the semantic colors defined in `lib/app/theme.dart`.
-   **Dependencies**: Keep external dependencies to an absolute minimum. We only use `firebase_core`, `firebase_auth`, `cloud_firestore`, and `cupertino_icons`.
-   **Backend**: All data must be synced with Firebase Firestore using the structures defined in the architecture document. Plain Dart models use `fromMap` and `toMap` for serialization.

## 🐛 Known Issues & Solutions (Prevent Repeating Errors)

The following are known issues encountered during analysis and development. When working on related files, ensure you apply these solutions to avoid repeating the errors.

### 1. Ambiguous `Transaction` Class Import
-   **Error**: `The name 'Transaction' is defined in the libraries 'package:cloud_firestore/cloud_firestore.dart' and 'package:fina/models/models.dart'` (ambiguous_import).
-   **Context**: The `cloud_firestore` package contains its own `Transaction` class (for database transactions), which conflicts with our custom `Transaction` data model in `lib/models/models.dart`.
-   **Solution**: Always hide `Transaction` when importing `cloud_firestore` in services or viewmodels that also use our custom model.
    ```dart
    // Correct Import:
    import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
    import '../models/models.dart';
    ```

### 2. Control Flow Formatting (Lint Info)
-   **Error**: `Statements in a for should be enclosed in a block` (curly_braces_in_flow_control_structures).
-   **Context**: The standard Dart lint rules used in this project require curly braces `{}` even for single-line `if`, `for`, or `while` statements.
-   **Solution**: Do not use one-liner control flow statements without braces. Always enclose the block.
    ```dart
    // Incorrect:
    for (final d in docs) batch.delete(d.reference);

    // Correct:
    for (final d in docs) {
      batch.delete(d.reference);
    }
    ```

### 3. Deprecated `withOpacity` (Lint Info)
-   **Error**: `'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss` (deprecated_member_use).
-   **Context**: Flutter has updated its `Color` API and deprecated `withOpacity` in newer versions.
-   **Solution**: Use `.withValues(alpha: X)` instead of `.withOpacity(X)`.
    ```dart
    // Incorrect:
    color: Colors.black.withOpacity(0.5)

    // Correct:
    color: Colors.black.withValues(alpha: 0.5)
    ```
