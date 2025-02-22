import 'package:authenticatu/database/key_db.dart';
import 'package:authenticatu/models/keys.dart';
import 'package:authenticatu/models/otps.dart';
import 'package:flutter/foundation.dart';
import 'package:otp/otp.dart';

class OtpProvider with ChangeNotifier {
  List<Otps> otps = [];

  Future<void> initData() async {
    try {
      final db = TOTPDB.instance;
      final data = await db.loadAllData();
      _makeOtps(data);
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing OTP data: $e');
    }
  }

  Future<bool?> addKey(TOTPKey key) async {
    try {
      final db = TOTPDB.instance;
      final data = await db.loadAllData();

      // Check if key already exists
      if (data.any(
        (existing) =>
            existing.key == key.key &&
            existing.label == key.label &&
            existing.issuer == key.issuer,
      )) {
        return false;
      }

      await db.insertData(key);
      await initData(); // Reload data after insertion
      return true;
    } catch (e) {
      debugPrint('Error adding key: $e');
      return null;
    }
  }

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
        key,
        DateTime.now().millisecondsSinceEpoch,
        interval: 30,
        length: 6,
        algorithm: Algorithm.SHA1,
      );
    } catch (e) {
      debugPrint('Error generating TOTP: $e');
      return '------';
    }
  }
}
