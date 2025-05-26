import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String pass) async {
    var cred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
    return cred.user;
  }

  Future<User?> register(String email, String pass) async {
    var cred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
    return cred.user;
  }

  Future<void> signOut() => _auth.signOut();
}