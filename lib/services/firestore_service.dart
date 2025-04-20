import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureDataService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Store encryption key in secure storage
  Future<void> _initEncryptionKey() async {
    String? encryptionKey = await _secureStorage.read(key: 'encryption_key');
    if (encryptionKey == null) {
      // Generate a random encryption key if none exists
      final key = encrypt.Key.fromSecureRandom(32);
      await _secureStorage.write(key: 'encryption_key', value: key.base64);
    }
  }

  // Get the encryption key
  Future<encrypt.Key> _getEncryptionKey() async {
    await _initEncryptionKey();
    final keyString = await _secureStorage.read(key: 'encryption_key');
    return encrypt.Key.fromBase64(keyString!);
  }

  // Encrypt data before storing
  Future<String> _encryptData(String data) async {
    final key = await _getEncryptionKey();
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(data, iv: iv);
    // Store IV with encrypted data (separated by a delimiter)
    return "${iv.base64}:${encrypted.base64}";
  }

  // Decrypt data after retrieval
  Future<String> _decryptData(String encryptedData) async {
    final key = await _getEncryptionKey();

    // Split IV and encrypted data
    final parts = encryptedData.split(':');
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encrypted = encrypt.Encrypted.fromBase64(parts[1]);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.decrypt(encrypted, iv: iv);
  }

  // Store a secret for the current user
  Future<void> storeSecret(String secretKey, String secretValue) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Encrypt the value before storing
    final encryptedValue = await _encryptData(secretValue);

    await _firestore.collection('userSecrets').doc(user.uid).set({
      secretKey: encryptedValue,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Retrieve a secret for the current user
  Future<String?> getSecret(String secretKey) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final doc = await _firestore.collection('userSecrets').doc(user.uid).get();

    if (!doc.exists || !doc.data()!.containsKey(secretKey)) {
      return null;
    }

    // Decrypt the stored value
    final encryptedValue = doc.data()![secretKey] as String;
    return await _decryptData(encryptedValue);
  }

  // Delete a secret
  Future<void> deleteSecret(String secretKey) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _firestore.collection('userSecrets').doc(user.uid).update({
      secretKey: FieldValue.delete(),
    });
  }

  Future<void> storeSetSecret(
    String secretValue,
    String label,
    String issuer,
  ) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Encrypt the value before storing

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
      print('Error fetching user secrets: $e');
      return [];
    }
  }
}
