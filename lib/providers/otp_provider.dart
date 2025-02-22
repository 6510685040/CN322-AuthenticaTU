import 'dart:async';
import 'package:authenticatu/database/key_db.dart';
import 'package:authenticatu/models/keys.dart';
import 'package:authenticatu/models/otps.dart';
import 'package:flutter/foundation.dart';
import 'package:otp/otp.dart';

class OtpProvider with ChangeNotifier {
  List<Otps> otps = [];
  Timer? _timer;

  OtpProvider() {
    initData(); // Load data when provider is created
    _startOtpTimer(); // Start automatic OTP refresh
  }

  void initData() async {
    var db = TOTPDB.instance;
    _makeOtps(await db.loadAllData());
    notifyListeners();
  }

  void addKey(TOTPKey key) async {
    var db = TOTPDB.instance;
    await db.insertData(key);
    _makeOtps(await db.loadAllData());
    notifyListeners();
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

  void _startOtpTimer() {
    final now = DateTime.now();
    int secondsUntilNextCycle = 30 - (now.second % 30);

    Future.delayed(Duration(seconds: secondsUntilNextCycle), () {
      _refreshOtps();
      _timer = Timer.periodic(Duration(seconds: 30), (timer) {
        _refreshOtps();
      });
    });
  }

  /// Refreshes OTPs every 30 seconds
  void _refreshOtps() async {
    var db = TOTPDB.instance;
    _makeOtps(await db.loadAllData());
    notifyListeners();
  }

  /// Dispose timer when provider is removed
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
