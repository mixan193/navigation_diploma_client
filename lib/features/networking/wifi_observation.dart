class WiFiObservation {
  final String ssid;
  final String bssid;
  final int rssi;
  final int frequency;  // Сделали обязательным полем

  WiFiObservation({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.frequency,
  });

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'rssi': rssi,
      'frequency': frequency,
    };
  }
}
