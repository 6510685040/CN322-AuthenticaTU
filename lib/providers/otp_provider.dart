import 'package:authenticatu/database/key_db.dart';
import 'package:authenticatu/database/secure_storage.dart';
import 'package:authenticatu/models/keys.dart';
import 'package:authenticatu/models/otps.dart';
import 'package:authenticatu/services/firestore_service.dart';
import 'package:flutter/foundation.dart';
import 'package:authenticatu/shared_pref_access.dart';
import 'package:otp/otp.dart';

class OtpProvider with ChangeNotifier {
  List<Otps> otps = [];
  final _cloudService = CloudService();
  final _db = TOTPDB();
  final _secure = SecureStorageService();

  Future<void> initData() async {
    try {
      final data = await _db.loadAllData();
      _makeOtps(data);
      notifyListeners();
    } catch (e) {
      //loadAllData ไม่ error เพราะมี error handler และส่ง [] มา
      debugPrint('Error initializing OTP data: $e');
    }
  }

  Future<bool?> addKey(TOTPKey key) async {
    try {
      final data = await _db.loadAllData();

      // Check if key already exists
      if (data.any(
        (existing) =>
            existing.key == key.key &&
            existing.label == key.label &&
            existing.issuer == key.issuer,
      )) {
        return false;
      }

      // local
      await _db.insertData(key);

      //cloud
      bool backUpBool = await getBackUpStatus();
      if (backUpBool) {
        try {
          _cloudService.storeUserSecret(
            _secure.encryptValue(key.key),
            key.label,
            key.issuer!,
          );
        } catch (e) {
          debugPrint("Backup Error :$e");
        }
      }
      await initData();
      return true;
    } catch (e) {
      debugPrint('Error adding key: $e');
      return null;
    }
  }

  //ยังไม่ได้ใช้แต่อาจจะใช้แทนการเรียก instance ตรงๆ
  List<Otps> getOtps() => List.unmodifiable(otps);

  void _makeOtps(List<TOTPKey> keyList) {
    otps =
        keyList
            .map(
              (key) => Otps(
                key: generateTOTP(key.key),
                label: key.label,
                issuer: key.issuer,
              ),
            )
            .toList();
  }

  String generateTOTP(String key) {
    try {
      return OTP.generateTOTPCodeString(
        _secure.decryptValue(key),
        DateTime.now().toUtc().millisecondsSinceEpoch,
        interval: 30,
        length: 6,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );
    } catch (e) {
      debugPrint('Error generating TOTP: $e');
      return '------';
    }
  }
}
