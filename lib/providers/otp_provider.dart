import 'package:authenticatu/database/key_db.dart';
import 'package:authenticatu/models/keys.dart';
import 'package:authenticatu/models/otps.dart';
import 'package:flutter/foundation.dart';
import 'package:authenticatu/shared_pref_access.dart';
import 'package:authenticatu/backup_management.dart';

class OtpProvider with ChangeNotifier {
  List<Otps> otps = [];

  Future<void> initData() async {
    try {
      final db = TOTPDB.instance;
      final data = await db.loadAllData();
      _makeOtps(data);
      notifyListeners();
    } catch (e) {
      //loadAllData ไม่ error เพราะมี error handler และส่ง [] มา
      debugPrint('Error initializing OTP data: $e');
    }
  }

  Future<bool?> addKey(TOTPKey key) async {
    //TODO - check backup status
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
      bool backUpBool = await getBackUpStatus();
      if (backUpBool) {
        try {
          toCloud(key);
        } catch (e) {
          print("ERROR");
        }
      }
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
                key: TOTPDB.instance.generateTOTP(key.key),
                label: key.label,
                issuer: key.issuer,
              ),
            )
            .toList();
  }
}
