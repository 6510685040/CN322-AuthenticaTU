import 'dart:io';
import 'package:authenticatu/database/secure_storage.dart';
import 'package:flutter/foundation.dart';
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
  Database? _database;
  final _secure = SecureStorageService();

  static final TOTPDB _instance = TOTPDB._internal();

  factory TOTPDB() => _instance;
  TOTPDB._internal();

  Future<Database> openDatabase() async {
    if (_database != null) return _database!;

    Directory appDirectory = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDirectory.path, _dbName);
    DatabaseFactory dbFactory = await databaseFactoryIo;
    _database = await dbFactory.openDatabase(dbLocation);
    return _database!;
  }

  // didnt use yet
  Future<void> closeDatabase() async {
    await _database?.close();
    _database = null;
  }

  Future<void> insertData(TOTPKey key) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(_storeName);

    try {
      await store.add(db, {
        "key": _secure.encryptValue(key.key),
        "label": key.label,
        "issuer": key.issuer,
      });
    } catch (e) {
      // db error
    }
  }

  Future<void> insertWithoutEncryption(TOTPKey key) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(_storeName);

    try {
      await store.add(db, {
        "key": key.key,
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
      debugPrint('Error loading TOTP keys: $e');
      return [];
    }
  }

  Future<void> clearStore() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store(_storeName);
    await store.delete(db);
    debugPrint('All TOTP keys deleted from database.');
  }
}
