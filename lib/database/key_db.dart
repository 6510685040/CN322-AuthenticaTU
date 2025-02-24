import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:authenticatu/models/keys.dart';

class TOTPDB {
  static const String _dbName = "totp.db";
  static const String _storeName = "totp_keys";
  static const String _encryptionKeyName = 'totp_encryption_key';
  static const String _ivKeyName = 'totp_iv_key'; // Add IV storage key

  static const _storage = FlutterSecureStorage();
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;
  Database? _database; // Add database instance variable

  static final TOTPDB instance = TOTPDB._();

  TOTPDB._() {
    // _initializeEncryption();
  }

  static Future<void> initialize() async {
    await instance._initializeEncryption();
  }

  Future<void> _initializeEncryption() async {
    // Get or generate encryption key
    String? encryptionKey = await _storage.read(key: _encryptionKeyName);
    String? ivString = await _storage.read(key: _ivKeyName);

    if (encryptionKey == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      await _storage.write(key: _encryptionKeyName, value: key.base64);
      encryptionKey = key.base64;
    }

    if (ivString == null) {
      _iv = encrypt.IV.fromSecureRandom(16);
      await _storage.write(key: _ivKeyName, value: _iv.base64);
    } else {
      _iv = encrypt.IV.fromBase64(ivString);
    }

    // Initialize encrypter
    final key = encrypt.Key.fromBase64(encryptionKey);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  String _encryptValue(String value) {
    return _encrypter.encrypt(value, iv: _iv).base64;
  }

  String _decryptValue(String encrypted) {
    return _encrypter.decrypt64(encrypted, iv: _iv);
  }

  Future<Database> openDatabase() async {
    if (_database != null) return _database!;

    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, _dbName);
    DatabaseFactory dbFactory = await databaseFactoryIo;
    _database = await dbFactory.openDatabase(dbLocation);
    return _database!;
  }

  Future<void> closeDatabase() async {
    await _database?.close();
    _database = null;
  }

  Future<int> insertData(TOTPKey key) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(_storeName);

    try {
      return await store.add(db, {
        "key": _encryptValue(key.key),
        "label": key.label,
        "issuer": key.issuer,
      });
    } finally {
      // Don't close the database here anymore
    }
  }

  Future<List<TOTPKey>> loadAllData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(_storeName);

    try {
      var snapshot = await store.find(db);
      return snapshot.map((record) {
        var data = record.value as Map<String, dynamic>;
        return TOTPKey(
          key: _decryptValue(data["key"]),
          label: data["label"],
          issuer: data["issuer"],
        );
      }).toList();
    } catch (e) {
      print('Error loading TOTP keys: $e');
      return [];
    }
  }
}
