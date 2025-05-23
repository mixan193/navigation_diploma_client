import 'package:wifi_scan/wifi_scan.dart';

class WifiService {
  Future<List<WiFiAccessPoint>> scan() async {
    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan != CanStartScan.yes) return [];
    await WiFiScan.instance.startScan();
    return await WiFiScan.instance.getScannedResults();
  }
}