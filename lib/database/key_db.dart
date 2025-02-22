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
  static const _storage = FlutterSecureStorage();
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;

  static final TOTPDB instance = TOTPDB._();

  TOTPDB._() {
    // Call initializeEncryption() when the instance is created
    _initializeEncryption();
  }

  Future<void> _initializeEncryption() async {
    await initializeEncryption(); // Ensure encryption is initialized
  }

  Future<void> initializeEncryption() async {
    // Get or generate encryption key
    String? encryptionKey = await _storage.read(key: _encryptionKeyName);
    if (encryptionKey == null) {
      final key = encrypt.Key.fromSecureRandom(32);
      await _storage.write(key: _encryptionKeyName, value: key.base64);
      encryptionKey = key.base64;
    }

    // Initialize encrypter
    final key = encrypt.Key.fromBase64(encryptionKey);
    _iv = encrypt.IV.fromLength(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  String _encryptValue(String value) {
    return _encrypter.encrypt(value, iv: _iv).base64;
  }

  String _decryptValue(String encrypted) {
    return _encrypter.decrypt64(encrypted, iv: _iv);
  }

  Future<Database> openDatabase() async {
    //หาตำแหน่งที่จะเก็บข้อมูล
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, _dbName);
    // สร้าง database
    DatabaseFactory dbFactory = await databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  Future<int> insertData(TOTPKey key) async {
    //ฐานข้อมูล => Store
    // transaction.db => expense
    var db = await openDatabase();
    var store = intMapStoreFactory.store(_storeName);

    // json
    var keyID = store.add(db, {
      "key": _encryptValue(key.key),
      "label": key.label,
      "issuer": key.issuer,
    });
    db.close();
    return keyID;
  }

  Future<List<TOTPKey>> loadAllData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(_storeName);
    var snapshot = await store.find(db);
    List<TOTPKey> keyList =
        snapshot.map((record) {
          var data =
              record.value as Map<String, dynamic>; // Ensure correct type
          return TOTPKey(
            key: _decryptValue(data["key"]),
            label: data["label"],
            issuer: data["issuer"], // Nullable field
          );
        }).toList();
    return keyList;
  }
}
