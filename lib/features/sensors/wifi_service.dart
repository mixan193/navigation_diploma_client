import 'package:wifi_scan/wifi_scan.dart';

class WifiService {
  Future<List<WiFiAccessPoint>> scan() async {
    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
    }

    final canGet = await WiFiScan.instance.canGetScannedResults();
    if (canGet == CanGetScannedResults.yes) {
      return await WiFiScan.instance.getScannedResults();
    }

    return [];
  }
}