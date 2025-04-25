import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:authenticatu/database/secure_storage.dart';
import 'package:authenticatu/services/firestore_service.dart';
import 'package:authenticatu/models/keys.dart';
import 'package:authenticatu/database/key_db.dart';
import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class BackupService {
  static final BackupService _instance = BackupService._internal();

  BackupService._internal();

  factory BackupService() => _instance;

  final CloudService _cloudService = CloudService();
  final SecureStorageService _secureStorageService = SecureStorageService();

  Future<List<TOTPKey>> getCloudSecretTOTPList() async {
    List<TOTPKey> totpList = [];
    try {
      List<Map<String, dynamic>> userSecrets =
          await _cloudService.fetchUserSecrets();
      for (var secret in userSecrets) {
        String issuer = secret['issuer'] ?? '';
        String label = secret['label'] ?? '';
        String secretValue = secret['secretValue'] ?? '';

        totpList.add(TOTPKey(key: secretValue, label: label, issuer: issuer));
      }
    } catch (e) {
      print("Error loading cloud secrets: $e");
    }
    return totpList;
  }

  Future<List<int>> genSalt() async {
    final random = Random.secure();
    final salt = List<int>.generate(16, (i) => random.nextInt(256));
    final base64Salt = base64.encode(salt);
    try {
      await _cloudService.storeUserInfo("salt", base64Salt);
      return salt;
    } catch (e) {
      throw Exception("Fail to generate salt");
    }
  }

  Future<List<int>> getSalt() async {
    final salt = await _cloudService.fetchUserInfo("salt");

    if (salt == null) {
      throw Exception("Salt not found in cloud storage");
    }

    return base64.decode(salt);
  }

  Future<encrypt.Key> getPBKDF2(List<int> salt, String password) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 10000,
      bits: 256,
    );

    final secretKey = await pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );

    final rawBytes = await secretKey.extractBytes();
    return encrypt.Key(Uint8List.fromList(rawBytes));
  }

  Future<void> handleBackup() async {
    List<TOTPKey> localTOTPList = await TOTPDB.instance.loadAllData();
    List<TOTPKey> cloudTOTPList = await getCloudSecretTOTPList();

    List<TOTPKey> toCloudList =
        localTOTPList.where((e) => !cloudTOTPList.contains(e)).toList();
    List<TOTPKey> toLocalList =
        cloudTOTPList.where((e) => !localTOTPList.contains(e)).toList();

    for (var totp in toCloudList) {
      await _cloudService.storeUserSecret(
        totp.key,
        totp.label,
        totp.issuer ?? '',
      );
    }
    for (var totp in toLocalList) {
      await TOTPDB.instance.insertWithoutEncryption(totp);
    }
  }

  Future<void> handleRegister(String password) async {
    final salt = await genSalt();
    final pbkdf2Key = await getPBKDF2(salt, password);
    final aesKey = await _secureStorageService.getKey();
    final ivString = await _secureStorageService.getIV();
    final iv = encrypt.IV.fromBase64(ivString!);
    final encrypter = encrypt.Encrypter(encrypt.AES(pbkdf2Key));

    if (aesKey == null) {
      throw Exception("Can't get AES key in secure storage");
    }

    final encAESKey = encrypter.encrypt(aesKey, iv: iv).base64;
    await _cloudService.storeUserInfo("key", encAESKey);
    await _cloudService.storeUserInfo("iv", ivString);
  }

  Future<void> handleLogin(String password) async {
    final saltString = await _cloudService.fetchUserInfo("salt");
    print("###############");
    print(saltString);
    final salt = base64.decode(saltString!);
    print("###############");
    print(salt);

    final pbkdf2Key = await getPBKDF2(salt, password);
    final encAESKey = await _cloudService.fetchUserInfo("key");
    final ivString = await _cloudService.fetchUserInfo("iv");
    final iv = encrypt.IV.fromBase64(ivString!);
    final encrypter = encrypt.Encrypter(encrypt.AES(pbkdf2Key));

    if (encAESKey == null) {
      throw Exception("Can't get AES key in secure storage");
    }

    final aesKey = encrypter.decrypt64(encAESKey, iv: iv);

    await _secureStorageService.setKey(aesKey);
    await _secureStorageService.setIV(ivString);
  }
}
