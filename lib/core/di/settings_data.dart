import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';

class HiveSettingsManager {
  static const String _boxName = 'app_settings';

  // Setting keys (same as in your SettingScreen)
  static const String _pointerEnabledKey = 'pointer_enabled';
  static const String _pointerSensitivityKey = 'pointer_sensitivity';
  static const String _selectedPaperSizeKey = 'selected_paper_size';
  static const String _autoConnectKey = 'auto_connect';
  static const String _stockTransferUnitKey = 'stock_transfer_unit';
  static const String _returnUnitKey = 'return_unit';
  static const String _defaultSalesPaymentKey = 'default_sales_payment';
  static const String _defaultReturnPaymentKey = 'default_return_payment';
  static const String _selectedDiscountTypeKey = 'selected_discount_type';
  static const String _lastConnectedDeviceKey = 'last_connected_device';

  // Method 1: Get individual setting values with default fallbacks
  static Future<bool> getPointerEnabled() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_pointerEnabledKey, defaultValue: true);
  }

  static Future<double> getPointerSensitivity() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_pointerSensitivityKey, defaultValue: 50.0);
  }

  static Future<String> getSelectedPaperSize() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_selectedPaperSizeKey, defaultValue: 'A4');
  }

  static Future<bool> getAutoConnect() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_autoConnectKey, defaultValue: false);
  }

  static Future<String> getStockTransferUnit() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_stockTransferUnitKey, defaultValue: 'أساسية');
  }

  static Future<String> getReturnUnit() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_returnUnitKey, defaultValue: 'أساسية');
  }

  static Future<String> getDefaultSalesPayment() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_defaultSalesPaymentKey, defaultValue: 'نقدي');
  }

  static Future<String> getDefaultReturnPayment() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_defaultReturnPaymentKey, defaultValue: 'نقدي');
  }

  static Future<String> getSelectedDiscountType() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_selectedDiscountTypeKey, defaultValue: 'نسبة');
  }

  static Future<String?> getLastConnectedDevice() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_lastConnectedDeviceKey);
  }

  // Method 2: Get all settings as a Map
  static Future<Map<String, dynamic>> getAllSettings() async {
    final box = await Hive.openBox(_boxName);
    return {
      'pointerEnabled': box.get(_pointerEnabledKey, defaultValue: true),
      'pointerSensitivity': box.get(_pointerSensitivityKey, defaultValue: 50.0),
      'selectedPaperSize': box.get(_selectedPaperSizeKey, defaultValue: 'A4'),
      'autoConnect': box.get(_autoConnectKey, defaultValue: false),
      'stockTransferUnit': box.get(_stockTransferUnitKey, defaultValue: 'أساسية'),
      'returnUnit': box.get(_returnUnitKey, defaultValue: 'أساسية'),
      'defaultSalesPayment': box.get(_defaultSalesPaymentKey, defaultValue: 'نقدي'),
      'defaultReturnPayment': box.get(_defaultReturnPaymentKey, defaultValue: 'نقدي'),
      'selectedDiscountType': box.get(_selectedDiscountTypeKey, defaultValue: 'نسبة'),
      'lastConnectedDevice': box.get(_lastConnectedDeviceKey),
    };
  }

  // Method 3: Generic getter for any setting
  static Future<T> getSetting<T>(String key, T defaultValue) async {
    final box = await Hive.openBox(_boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  // Method 4: Check if a setting exists
  static Future<bool> hasSettingValue(String key) async {
    final box = await Hive.openBox(_boxName);
    return box.containsKey(key);
  }

  // Method 5: Get raw box for direct access (if box is already open)
  static Box? getOpenBox() {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return null;
  }

  // Method 6: Print all settings for debugging
  static Future<void> printAllSettings() async {
    final settings = await getAllSettings();
    log('=== Current Settings ===');
    settings.forEach((key, value) {
      log('$key: $value');
    });
    log('=====================');
  }
}
