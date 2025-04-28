import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

class SecureStorageService {
  static const String _encryptionKeyName = 'totp_encryption_key';
  static const String _ivKeyName = 'totp_iv_key';
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static final SecureStorageService _instance =
      SecureStorageService._internal();

  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  Future<void> initialize() async {
    String? encryptionKey = await _storage.read(key: _encryptionKeyName);
    String? ivString = await _storage.read(key: _ivKeyName);

    if (encryptionKey == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      await _storage.write(key: _encryptionKeyName, value: key.base64);
    }

    if (ivString == null) {
      final iv = encrypt.IV.fromSecureRandom(16);
      await _storage.write(key: _ivKeyName, value: iv.base64);
    }
    final iv = await getIV();
    if (iv == null) {
      throw Exception("Can't get IV in secure storage");
    }
    _iv = encrypt.IV.fromBase64(iv);
    final key = await getKey();
    if (key == null) {
      throw Exception("Can't get AES key in secure storage");
    }
    _encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromBase64(key)));
  }

  Future<void> reinitialize() async {
    final iv = await getIV();
    if (iv == null) {
      throw Exception("Can't get IV in secure storage");
    }
    _iv = encrypt.IV.fromBase64(iv);
    final key = await getKey();
    if (key == null) {
      throw Exception("Can't get AES key in secure storage");
    }
    _encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromBase64(key)));
  }

  String encryptValue(String value) {
    try {
      return _encrypter.encrypt(value, iv: _iv).base64;
    } catch (e) {
      throw Exception("Failed to encrypt value: ${e.toString()}");
    }
  }

  String decryptValue(String encrypted) {
    try {
      return _encrypter.decrypt64(encrypted, iv: _iv);
    } catch (e) {
      throw Exception("Failed to decrypt value: ${e.toString()}");
    }
  }

  Future<String?> getKey() async {
    try {
      return await _storage.read(key: _encryptionKeyName);
    } catch (e) {
      throw Exception("Failed to retrieve encryption key: ${e.toString()}");
    }
  }

  Future<void> setKey(String key) async {
    try {
      await _storage.write(key: _encryptionKeyName, value: key);
    } catch (e) {
      throw Exception("Failed to store encryption key: ${e.toString()}");
    }
  }

  Future<String?> getIV() async {
    try {
      return await _storage.read(key: _ivKeyName);
    } catch (e) {
      throw Exception("Failed to retrieve IV: ${e.toString()}");
    }
  }

  Future<void> setIV(String iv) async {
    try {
      await _storage.write(key: _ivKeyName, value: iv);
    } catch (e) {
      throw Exception("Failed to store IV: ${e.toString()}");
    }
  }

  Future<void> clearSecureStorage() async {
    try {
      await _storage.delete(key: _encryptionKeyName);
      await _storage.delete(key: _ivKeyName);
      debugPrint('Secure storage cleared successfully.');
    } catch (e) {
      debugPrint('Error clearing secure storage: $e');
    }
  }
}
