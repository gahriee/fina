import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'app/theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';

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
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fina',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.values[_transactionVM.settings.themeMode.index],
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
            
            // User is not logged in, clear any existing data
            _transactionVM.clear();
            return AuthScreen(authVM: _authVM);
          },
        ),
      ),
    );
  }
}
