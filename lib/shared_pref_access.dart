import 'package:shared_preferences/shared_preferences.dart';
import 'package:authenticatu/services/firestore_service.dart';
import 'package:authenticatu/backup_management.dart';

Future<void> initializePreferences() async {
  final prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('backup')) {
    await prefs.setBool('backup', false);
  }
}

Future<bool> getSavedBool() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('backup') ?? false; // default to false if null
}

Future<void> toggleBool() async {
  final prefs = await SharedPreferences.getInstance();
  final boolValue = prefs.getBool('backup') ?? false;
  final secureDataServiceObj = SecureDataService();
  if (boolValue) {
    try {
      // secureDataServiceObj.storeSetSecret(
      //   "7V7WzSJZ6w43OpA+/TSDlfLn4eb7U7zzymegiN6dy74=",
      //   "Test_01",
      //   "Epic Games",
      // );
      updateCloudWithMissingTOTP();
    } catch (e) {
      print("ERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
    }
  }
  await prefs.setBool('backup', !boolValue);
}
