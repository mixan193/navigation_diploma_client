class WiFiObservation {
  final String ssid;
  final String bssid;
  final int rssi;
  final int frequency;

  WiFiObservation({
    required this.ssid,
    required this.bssid,
    required this.rssi,
    required this.frequency,
  });

  factory WiFiObservation.fromJson(Map<String, dynamic> json) {
    return WiFiObservation(
      ssid: json['ssid'] as String,
      bssid: json['bssid'] as String,
      rssi: json['rssi'] as int,
      frequency: json['frequency'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'ssid': ssid,
        'bssid': bssid,
        'rssi': rssi,
        'frequency': frequency,
      };
}