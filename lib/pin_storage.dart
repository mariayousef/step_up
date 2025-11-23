// lib/pin_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class PinStorage {
  static const String _pinKey = 'child_mode_pin';

  /// حفظ الـ PIN
  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  /// قراءة الـ PIN
  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey);
  }

  /// هل فيه PIN متخزن؟
  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey);
  }

  /// التحقق من صحة الـ PIN
  static Future<bool> isCorrectPin(String pin) async {
    final stored = await getPin();
    if (stored == null) return false;
    return stored == pin;
  }

  /// مسح الـ PIN (لو احتجتيه بعدين)
  static Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
  }
}
