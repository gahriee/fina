import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: '999374234370-bips00mog2vlsnbg3egk952qja2qcvb7.apps.googleusercontent.com',
      );
      // Clear any stuck sessions before authenticating
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

    GoogleSignInAccount? googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate();
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('canceled') || errorString.contains('cancelled') || errorString.contains('16')) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }
      rethrow;
    }

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: '999374234370-bips00mog2vlsnbg3egk952qja2qcvb7.apps.googleusercontent.com',
      );
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    return _auth.signOut();
  }
}

