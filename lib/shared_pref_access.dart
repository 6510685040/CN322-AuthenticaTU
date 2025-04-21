import 'package:shared_preferences/shared_preferences.dart';
import 'package:authenticatu/backup_management.dart';

Future<void> initializePreferences() async {
  final prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('backup')) {
    await prefs.setBool('backup', false);
  }
}

Future<bool> getBackUpStatus() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('backup') ?? false; // default to false if null
}

Future<void> toggleBackUpStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final boolValue = prefs.getBool('backup') ?? false;
  if (boolValue) {
    try {
      handleBackUp();
    } catch (e) {
      print("ERROR :");
    }
  }
  await prefs.setBool('backup', !boolValue);
}
