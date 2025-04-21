import 'package:authenticatu/services/firestore_service.dart';
import 'package:authenticatu/models/keys.dart';
import 'package:authenticatu/database/key_db.dart';

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

Future<void> handleBackUp() async {
  List<TOTPKey> localTOTPList = await TOTPDB.instance.loadAllData();
  List<TOTPKey> cloudTOTPList = await getCloudSecretTOTPList();
  List<TOTPKey> toCloudList =
      localTOTPList.where((e) => !cloudTOTPList.contains(e)).toList();
  List<TOTPKey> toLocalList =
      cloudTOTPList.where((e) => !localTOTPList.contains(e)).toList();
  for (var totp in toCloudList) {
    toCloud(totp);
  }
  for (var totp in toLocalList) {
    toLoacal(totp);
  }
}

Future<void> toCloud(TOTPKey totp) async {
  final secureDataServiceObj = SecureDataService();
  await secureDataServiceObj.storeSetSecret(totp.key, totp.label, totp.issuer!);
}

Future<void> toLoacal(TOTPKey totp) async {
  await TOTPDB.instance.insertData(totp);
}
