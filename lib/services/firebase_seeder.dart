import 'package:flutter/foundation.dart';

class FirebaseSeeder {
  static Future<void> seedInitialData() async {
    // Mode Strict Read-Only : Aucune création automatique de données de test dans la base Cloud Firestore.
    if (kDebugMode) {
      print('FirebaseSeeder: Strict Read-Only mode active. Automatic seeding disabled.');
    }
  }
}
