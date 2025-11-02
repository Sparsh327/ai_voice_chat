import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:uuid/uuid.dart';

class DeviceService {
  static const String _deviceIdKey = 'device_id';

  /// Get unique device ID (persistent across app launches)
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we already have a device ID stored
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId != null) {
      return deviceId;
    }

    // Generate new device ID
    deviceId = await _generateDeviceId();

    // Save it for future use
    await prefs.setString(_deviceIdKey, deviceId);

    return deviceId;
  }

  /// Generate unique device ID based on device info
  static Future<String> _generateDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Use Android ID if available, otherwise generate UUID
        return androidInfo.id ?? Uuid().v4();
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // Use identifier for vendor
        return iosInfo.identifierForVendor ?? const Uuid().v4();
      }
    } catch (e) {
      // Fallback to UUID if device info fails
      return const Uuid().v4();
    }

    // Default fallback
    return const Uuid().v4();
  }

  /// Clear device ID (for testing)
  static Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
  }
}
