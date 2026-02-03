import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Auth State Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign Up with Email & Password
  Future<UserCredential> signUpWithEmail(
      String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // Update Display Name
      if (result.user != null) {
        await result.user!.updateDisplayName(displayName);
      }
      return result;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred during sign up.';
    }
  }

  // Sign In with Email & Password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred during sign in.';
    }
  }

  // Sign In with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in flow

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred during Google sign in.';
    } catch (e) {
      throw 'An error occurred during Google sign in.';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Password Reset
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ??
          'An error occurred while sending password reset email.';
    }
  }
}
