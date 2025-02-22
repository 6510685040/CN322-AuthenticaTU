import 'package:authenticatu/database/key_db.dart';
import 'package:authenticatu/models/keys.dart';
import 'package:authenticatu/models/otps.dart';
import 'package:flutter/foundation.dart';
import 'package:otp/otp.dart';

class OtpProvider with ChangeNotifier {
  List<Otps> otps = [];

  void initData() async {
    var db = TOTPDB.instance;
    _makeOtps(await db.loadAllData());
    notifyListeners();
  }

  Future<bool> addKey(TOTPKey key) async {
    var db = TOTPDB.instance;
    List<TOTPKey> data = await db.loadAllData();

    bool isSuccess = true;
    bool keyExists = data.any(
      (data) =>
          data.key == key.key &&
          data.label == key.label &&
          data.issuer == key.issuer,
    );
    if (keyExists) {
      isSuccess = false;
    } else {
      await db.insertData(key);
    }
    _makeOtps(data);
    notifyListeners();
    return isSuccess;
  }

  List<Otps> getOtps() {
    return otps;
  }

  void _makeOtps(List<TOTPKey> keyList) {
    otps =
        keyList.map((key) {
          return Otps(
            key: generateTOTP(key.key),
            label: key.label,
            issuer: key.issuer,
          );
        }).toList();
  }

  String generateTOTP(String key) {
    return OTP.generateTOTPCodeString(
      key, // Secret key
      DateTime.now().millisecondsSinceEpoch, // Current time
      interval: 30, // Default is 30 seconds per OTP cycle
      length: 6, // OTP length (default 6 digits)
      algorithm: Algorithm.SHA1, // Default algorithm
    );
  }
}
