import 'dart:io';
import 'package:authenticatu/database/secure_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:authenticatu/models/keys.dart';
import 'package:otp/otp.dart';

class TOTPDB {
  static const String _dbName = "totp.db";
  static const String _storeName = "totp_keys";

  final SecureStorageService _storage = SecureStorageService();
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
    await _storage.initializeKeys();

    final encryptionKey = await _storage.getKey();
    final ivString = await _storage.getIV();

    final key = encrypt.Key.fromBase64(encryptionKey!);
    _iv = encrypt.IV.fromBase64(ivString!);
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

  Future<void> insertData(TOTPKey key) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(_storeName);

    try {
      await store.add(db, {
        "key": _encryptValue(key.key),
        "label": key.label,
        "issuer": key.issuer,
      });
    } catch (e) {
      // db error
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
          key: data["key"],
          label: data["label"],
          issuer: data["issuer"],
        );
      }).toList();
    } catch (e) {
      print('Error loading TOTP keys: $e');
      return [];
    }
  }

  String generateTOTP(String key) {
    try {
      return OTP.generateTOTPCodeString(
        _decryptValue(key),
        DateTime.now().toUtc().millisecondsSinceEpoch,
        interval: 30,
        length: 6,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );
    } catch (e) {
      // print('Error generating TOTP: $e');
      return '------';
    }
  }
}
