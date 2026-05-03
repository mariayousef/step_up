class SensorReading {
  final String deviceId;
  final String apiKey;
  final int? heartRate;
  final double? temperature;
  final double? accX;
  final double? accY;
  final double? accZ;
  final double? gyroX;
  final double? gyroY;
  final double? gyroZ;
  final double? latitude;
  final double? longitude;
  final int? satellites;
  final String? gpsFixType;
  final double? hdop;
  final bool fallDetected;

  const SensorReading({
    required this.deviceId,
    required this.apiKey,
    required this.heartRate,
    required this.temperature,
    required this.accX,
    required this.accY,
    required this.accZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.latitude,
    required this.longitude,
    required this.satellites,
    required this.gpsFixType,
    required this.hdop,
    required this.fallDetected,
  });

  bool get hasLocation => latitude != null && longitude != null;

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      deviceId: _string(json['device_id']),
      apiKey: _string(json['api_key']),
      heartRate: _int(json['heart_rate']),
      temperature: _double(json['temperature']),
      accX: _double(json['acc_x']),
      accY: _double(json['acc_y']),
      accZ: _double(json['acc_z']),
      gyroX: _double(json['gyro_x']),
      gyroY: _double(json['gyro_y']),
      gyroZ: _double(json['gyro_z']),
      latitude: _double(json['latitude']),
      longitude: _double(json['longitude']),
      satellites: _int(json['satellites']),
      gpsFixType: json['gps_fix_type']?.toString(),
      hdop: _double(json['hdop']),
      fallDetected: _bool(json['fall_detected']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'api_key': apiKey,
      'heart_rate': heartRate,
      'temperature': temperature,
      'acc_x': accX,
      'acc_y': accY,
      'acc_z': accZ,
      'gyro_x': gyroX,
      'gyro_y': gyroY,
      'gyro_z': gyroZ,
      'latitude': latitude,
      'longitude': longitude,
      'satellites': satellites,
      'gps_fix_type': gpsFixType,
      'hdop': hdop,
      'fall_detected': fallDetected,
    };
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  static int? _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _double(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static bool _bool(dynamic value) {
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }
}
