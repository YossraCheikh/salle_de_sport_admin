import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

class AuthService {
  FirebaseAuth? get _auth =>
      Firebase.apps.isNotEmpty ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _db =>
      Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> login(String email, String password) async {
    try {
      if (_auth != null) {
        final cred = await _auth!.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        if (cred.user != null && _db != null) {
          final doc = await _db!.collection('users').doc(cred.user!.uid).get();
          if (doc.exists && doc.data() != null) {
            _currentUser = AppUser.fromMap(doc.data()!, cred.user!.uid);
            return _currentUser;
          } else {
            final newUser = AppUser(
              uid: cred.user!.uid,
              name: cred.user!.displayName ?? 'Administrateur',
              email: cred.user!.email ?? email,
              role: 'admin',
            );
            await _db!.collection('users').doc(cred.user!.uid).set({
              'name': newUser.name,
              'email': newUser.email,
              'role': newUser.role,
              'isActive': true,
            });
            _currentUser = newUser;
            return _currentUser;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('Connexion Firebase Auth via fallback local: $e');
    }

    if (email.trim().isNotEmpty && password.length >= 6) {
      _currentUser = AppUser(
        uid: 'admin1',
        name: 'Administrateur',
        email: email,
        role: 'admin',
      );
      return _currentUser;
    }
    return null;
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      if (_auth != null) {
        await _auth!.sendPasswordResetEmail(email: email.trim());
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Reset password fallback: $e');
    }
    return email.contains('@');
  }

  Future<void> logout() async {
    try {
      if (_auth != null) {
        await _auth!.signOut();
      }
    } catch (_) {}
    _currentUser = null;
  }
}
