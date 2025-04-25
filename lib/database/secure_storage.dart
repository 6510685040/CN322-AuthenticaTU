import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecureStorageService {
  static const String _encryptionKeyName = 'totp_encryption_key';
  static const String _ivKeyName = 'totp_iv_key';
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  Future<void> initializeKeys() async {
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
  }

  Future<String?> getKey() async {
    return _storage.read(key: _encryptionKeyName);
  }

  Future<void> setKey(String key) async {
    _storage.write(key: _encryptionKeyName, value: key);
  }

  Future<String?> getIV() async {
    return _storage.read(key: _ivKeyName);
  }

  Future<void> setIV(String iv) async {
    _storage.write(key: _ivKeyName, value: iv);
  }

  // Future<void> delete(String key) => _storage.delete(key: key);
  // Future<void> clear() => _storage.deleteAll();
}
