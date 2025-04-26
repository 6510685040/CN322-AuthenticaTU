import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CloudService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeUserInfo(String key, String value) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _firestore.collection('userSecrets').doc(user.uid).set({
      key: value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> fetchUserInfo(String key) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final doc = await _firestore.collection('userSecrets').doc(user.uid).get();

    if (!doc.exists || !doc.data()!.containsKey(key)) {
      return null;
    }

    final value = doc.data()![key] as String;
    return value;
  }

  Future<void> storeUserSecret(
    String secretValue,
    String label,
    String issuer,
  ) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('userSecrets')
        .doc(user.uid)
        .collection('secrets')
        .doc()
        .set({
          "issuer": issuer,
          "label": label,
          "secretValue": secretValue,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> fetchUserSecrets() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    try {
      // Reference the secrets subcollection for the specific user
      final secretsSnapshot =
          await _firestore
              .collection('userSecrets')
              .doc(user.uid)
              .collection('secrets')
              .get();

      // Convert the documents to a list of maps
      final secretsList =
          secretsSnapshot.docs.map((doc) => doc.data()).toList();
      return secretsList;
    } catch (e) {
      debugPrint('Error fetching user secrets: $e');
      return [];
    }
  }
}
