import 'package:authenticatu/services/firestore_service.dart';
import 'package:authenticatu/models/keys.dart';
import 'package:authenticatu/database/key_db.dart';

// we may not use this, since comparing through == could work better.
Future<List<String>> getCloudCombinationStringList() async {
  final secureDataServiceObj = SecureDataService();
  List<String> combinationStringList = [];
  try {
    List<Map<String, dynamic>> userSecrets =
        await secureDataServiceObj.fetchUserSecrets();
    for (var secret in userSecrets) {
      String issuer = secret['issuer'] ?? '';
      String label = secret['label'] ?? '';
      String secretValue = secret['secretValue'] ?? '';
      String combination = issuer + label + secretValue;
      combinationStringList.add(combination);
    }
  } catch (e) {
    print("ERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
  }
  return combinationStringList;
}

Future<List<TOTPKey>> getCloudSecretTOTPList() async {
  final secureDataServiceObj = SecureDataService();
  List<TOTPKey> totpList = [];
  try {
    List<Map<String, dynamic>> userSecrets =
        await secureDataServiceObj.fetchUserSecrets();
    for (var secret in userSecrets) {
      String issuer = secret['issuer'] ?? '';
      String label = secret['label'] ?? '';
      String secretValue = secret['secretValue'] ?? '';
      // THIS REPLACES NULL ISSUER TO "" MAYBE THIS IS NOT INTENED MAY CAUSE ISSUES
      totpList.add(TOTPKey(key: secretValue, label: label, issuer: issuer));
    }
  } catch (e) {
    print("ERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
  }
  return totpList;
}

Future<void> updateCloudWithMissingTOTP() async {
  await TOTPDB.initialize();
  TOTPDB.instance;
  List<TOTPKey> dbTOTPList = await TOTPDB.instance.loadAllData();
  List<TOTPKey> cloudTOTPList = await getCloudSecretTOTPList();
  for (TOTPKey i in dbTOTPList) {
    print("LOCAL");
    print(i);
  }
  for (TOTPKey i in cloudTOTPList) {
    print("CLOUD");
    print(i);
  }
  // find object in dbTOTPList that are not in cloudTOTPList
  List<TOTPKey> differenceTOTPList =
      dbTOTPList.where((key) => !cloudTOTPList.contains(key)).toList();

  for (TOTPKey i in differenceTOTPList) {
    print("DIFF");
    print(i);
  }
}
