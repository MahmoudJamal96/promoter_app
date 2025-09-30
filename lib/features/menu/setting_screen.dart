import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:promoter_app/core/di/settings_data.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // Hive box for storing settings
  late Box settingsBox;
  ReceiptController? controller;

  // Settings state variables
  bool bluetoothEnabled = false;
  bool pointerEnabled = true;
  double pointerSensitivity = 50.0;
  String selectedPaperSize = 'A4';
  bool autoConnect = false;

  // New business settings
  String stockTransferUnit = 'أساسية';
  String returnUnit = 'أساسية';
  String defaultSalesPayment = 'نقدي';
  String defaultReturnPayment = 'نقدي';
  String selectedDiscountType = 'نسبة';

  // Bluetooth specific variables using flutter_blue_plus
  List<BluetoothDevice> bondedDevices = [];
  List<ScanResult> scanResults = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? writeCharacteristic;
  bool isScanning = false;
  StreamSubscription<BluetoothAdapterState>? adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? scanSubscription;
  StreamSubscription<BluetoothConnectionState>? connectionStateSubscription;

  final List<String> paperSizes = ['58mm', '80mm', 'A4', 'A5'];
  final List<String> unitOptions = ['أساسية', 'فرعية'];
  final List<String> paymentOptions = ['نقدي', 'أجل'];
  final List<String> discountOptions = ['نسبة', 'مبلغ'];

  // Hive keys for settings
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

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  @override
  void dispose() {
    adapterStateSubscription?.cancel();
    scanSubscription?.cancel();
    connectionStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeHive() async {
    try {
      // Initialize Hive if not already initialized
      if (!Hive.isAdapterRegistered(0)) {
        await Hive.initFlutter();
      }

      // Open settings box
      settingsBox = await Hive.openBox('app_settings');

      // Load cached settings
      await _loadCachedSettings();

      // Initialize Bluetooth after loading settings
      await _initializeBluetooth();
    } catch (e) {
      _showErrorSnackBar('خطأ في تهيئة التخزين: $e');
      // Fallback to initialize Bluetooth without cached settings
      await _initializeBluetooth();
    }
  }

  Future<void> _loadCachedSettings() async {
    try {
      setState(() {
        pointerEnabled = settingsBox.get(_pointerEnabledKey, defaultValue: true);
        pointerSensitivity = settingsBox.get(_pointerSensitivityKey, defaultValue: 50.0);
        selectedPaperSize = settingsBox.get(_selectedPaperSizeKey, defaultValue: 'A4');
        autoConnect = settingsBox.get(_autoConnectKey, defaultValue: false);
        stockTransferUnit = settingsBox.get(_stockTransferUnitKey, defaultValue: 'أساسية');
        returnUnit = settingsBox.get(_returnUnitKey, defaultValue: 'أساسية');
        defaultSalesPayment = settingsBox.get(_defaultSalesPaymentKey, defaultValue: 'نقدي');
        defaultReturnPayment = settingsBox.get(_defaultReturnPaymentKey, defaultValue: 'نقدي');
        selectedDiscountType = settingsBox.get(_selectedDiscountTypeKey, defaultValue: 'نسبة');
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل الإعدادات المحفوظة: $e');
    }
  }

  Future<void> _saveSettingToCache(String key, dynamic value) async {
    try {
      await settingsBox.put(key, value);
    } catch (e) {
      _showErrorSnackBar('خطأ في حفظ الإعداد: $e');
    }
  }

  Future<void> _initializeBluetooth() async {
    try {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        _showErrorSnackBar('البلوتوث غير مدعوم على هذا الجهاز');
        return;
      }

      // Listen to adapter state changes
      adapterStateSubscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        setState(() {
          bluetoothEnabled = state == BluetoothAdapterState.on;
          if (!bluetoothEnabled) {
            bondedDevices.clear();
            scanResults.clear();
            connectedDevice = null;
            writeCharacteristic = null;
          }
        });
      });

      // Get initial state
      BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
      setState(() {
        bluetoothEnabled = state == BluetoothAdapterState.on;
      });

      if (bluetoothEnabled) {
        await _loadBondedDevices();

        // Auto-connect if enabled and last device is available
        if (autoConnect) {
          await _tryAutoConnect();
        }
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في تهيئة البلوتوث: $e');
    }
  }

  Future<void> _tryAutoConnect() async {
    try {
      String? lastDeviceId = settingsBox.get(_lastConnectedDeviceKey);
      BluetoothDevice? lastDevice =
          bondedDevices.where((device) => device.remoteId.toString() == lastDeviceId).firstOrNull;

      if (lastDevice != null) {
        await _connectToDevice(lastDevice);
      }
    } catch (e) {
      print('Auto-connect failed: $e');
    }
  }

  Future<void> _requestBluetoothPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status == PermissionStatus.granted);

    if (!allGranted) {
      _showErrorSnackBar('يتطلب التطبيق أذونات البلوتوث للعمل بشكل صحيح');
    }
  }

  Future<void> _toggleBluetooth(bool value) async {
    try {
      await _requestBluetoothPermissions();

      if (value) {
        // Note: flutter_blue_plus doesn't provide direct enable/disable
        // You'll need to guide users to enable it manually
        _showErrorSnackBar('يرجى تفعيل البلوتوث من إعدادات النظام');
      } else {
        // Disconnect current device if connected
        if (connectedDevice != null) {
          await connectedDevice!.disconnect();
        }
        setState(() {
          bondedDevices.clear();
          scanResults.clear();
          connectedDevice = null;
          writeCharacteristic = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في تغيير حالة البلوتوث: $e');
    }
  }

  Future<void> _loadBondedDevices() async {
    try {
      // flutter_blue_plus doesn't have getBondedDevices equivalent
      // We'll rely on system bonded devices that appear in scan results
      bondedDevices = FlutterBluePlus.connectedDevices;
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل الأجهزة المتصلة: $e');
    }
  }

  Future<void> _startScan() async {
    try {
      await _requestBluetoothPermissions();

      setState(() {
        scanResults.clear();
        isScanning = true;
      });

      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

      // Listen to scan results
      scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          setState(() {
            scanResults = results;
          });
        },
        onError: (error) {
          setState(() {
            isScanning = false;
          });
          _showErrorSnackBar('خطأ في البحث عن الأجهزة: $error');
        },
      );

      // Listen for scan completion
      FlutterBluePlus.isScanning.listen((scanning) {
        setState(() {
          isScanning = scanning;
        });
      });
    } catch (e) {
      setState(() {
        isScanning = false;
      });
      _showErrorSnackBar('خطأ في بدء البحث: $e');
    }
  }

  Future<void> _stopScan() async {
    SoundManager().playClickSound();
    try {
      await FlutterBluePlus.stopScan();
      scanSubscription?.cancel();
      setState(() {
        isScanning = false;
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في إيقاف البحث: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      // Disconnect current device if any
      if (connectedDevice != null) {
        await connectedDevice!.disconnect();
      }

      // Show connecting dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('جاري الاتصال...'),
            ],
          ),
        ),
      );

      // Connect to device
      await device.connect(timeout: const Duration(seconds: 15));

      Navigator.pop(context); // Close connecting dialog

      // Discover services
      List<BluetoothService> services = await device.discoverServices();

      // Find a writable characteristic (typically for serial communication)
      BluetoothCharacteristic? foundCharacteristic;
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
            foundCharacteristic = characteristic;
            break;
          }
        }
        if (foundCharacteristic != null) break;
      }

      setState(() {
        connectedDevice = device;
        writeCharacteristic = foundCharacteristic;
      });

      // Save last connected device
      await _saveSettingToCache(_lastConnectedDeviceKey, device.remoteId.toString());

      _showSuccessSnackBar(
          'تم الاتصال بـ ${device.platformName.isNotEmpty ? device.platformName : device.remoteId.toString()}');

      // Listen to connection state
      connectionStateSubscription = device.connectionState.listen(
        (BluetoothConnectionState state) {
          if (state == BluetoothConnectionState.disconnected) {
            setState(() {
              connectedDevice = null;
              writeCharacteristic = null;
            });
            _showErrorSnackBar('تم قطع الاتصال');
          }
        },
      );
    } catch (e) {
      Navigator.pop(context); // Close connecting dialog
      _showErrorSnackBar('فشل الاتصال بالجهاز: $e');
    }
  }

  Future<void> _disconnectDevice() async {
    SoundManager().playClickSound();
    try {
      if (connectedDevice != null) {
        await connectedDevice!.disconnect();
      }
      connectionStateSubscription?.cancel();
      setState(() {
        connectedDevice = null;
        writeCharacteristic = null;
      });
      _showSuccessSnackBar('تم قطع الاتصال');
    } catch (e) {
      _showErrorSnackBar('خطأ في قطع الاتصال: $e');
    }
  }

  Widget testData() {
    return Receipt(
      backgroundColor: Colors.white,
      onInitialized: (controller) {
        this.controller = controller;
      },
      builder: (BuildContext context) => const Column(
        children: [
          Text(
            'This is a test receipt',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Item 1: \$10.00'),
          Text('Item 2: \$15.00'),
          Text('Item 3: \$7.50'),
          SizedBox(height: 10),
          Text(
            'Total: \$32.50',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Thank you for your purchase!'),
        ],
      ),
    );
  }

  // Future<void> _sendTestData() async {
  //   SoundManager().playClickSound();
  //   final device = await FlutterBluetoothPrinter.selectDevice(context);

  //   controller?.print(address: device!.address.toString());
  // }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات التطبيق',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF148ccd),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),

          // Bluetooth Settings Section
          _buildSectionHeader('إعدادات البلوتوث', Icons.bluetooth),

          Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  title: const Text('حالة البلوتوث'),
                  subtitle: Text(bluetoothEnabled ? 'البلوتوث مفعل' : 'البلوتوث معطل'),
                  leading: Icon(
                    bluetoothEnabled ? Icons.bluetooth : Icons.bluetooth_disabled,
                    color: bluetoothEnabled ? Colors.blue : Colors.grey,
                  ),
                  trailing: bluetoothEnabled
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : TextButton(
                          onPressed: () {
                            _showErrorSnackBar('يرجى تفعيل البلوتوث من إعدادات النظام');
                          },
                          child: const Text('تفعيل'),
                        ),
                ),
                if (bluetoothEnabled) ...[
                  const Divider(height: 1),
                  if (connectedDevice != null) ...[
                    // ListTile(
                    //   title: Text(
                    //       'متصل بـ: ${connectedDevice!.platformName.isNotEmpty ? connectedDevice!.platformName : 'جهاز غير معروف'}'),
                    //   subtitle: Text(connectedDevice!.remoteId.toString()),
                    //   leading: const Icon(Icons.bluetooth_connected, color: Colors.green),
                    //   trailing: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       IconButton(
                    //         icon: const Icon(Icons.send),
                    //         onPressed: _sendTestData,
                    //         tooltip: 'إرسال بيانات تجريبية',
                    //       ),
                    //       IconButton(
                    //         icon: const Icon(Icons.close),
                    //         onPressed: _disconnectDevice,
                    //         tooltip: 'قطع الاتصال',
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const Divider(height: 1),
                  ],
                  SwitchListTile(
                    title: const Text('الاتصال التلقائي'),
                    subtitle: const Text('الاتصال بآخر جهاز تلقائياً'),
                    value: autoConnect,
                    onChanged: (bool value) async {
                      setState(() {
                        autoConnect = value;
                      });
                      await _saveSettingToCache(_autoConnectKey, value);
                    },
                    secondary: const Icon(Icons.sync),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('إدارة الأجهزة'),
                    subtitle: const Text('عرض وإدارة أجهزة البلوتوث'),
                    leading: const Icon(Icons.devices),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      SoundManager().playClickSound();
                      _showBluetoothDevices(context);
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Business Settings Section
          _buildSectionHeader('إعدادات العمليات التجارية', Icons.business),
          Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  title: const Text('وحدة طلب تحويل مخزون'),
                  subtitle: Text('الوحدة المحددة: $stockTransferUnit'),
                  leading: const Icon(Icons.transform),
                  trailing: DropdownButton<String>(
                    value: stockTransferUnit,
                    items: unitOptions.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        setState(() {
                          stockTransferUnit = newValue;
                        });
                        await _saveSettingToCache(_stockTransferUnitKey, newValue);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('وحدة طلب مرتجع مخزون'),
                  subtitle: Text('الوحدة المحددة: $returnUnit'),
                  leading: const Icon(Icons.keyboard_return),
                  trailing: DropdownButton<String>(
                    value: returnUnit,
                    items: unitOptions.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        setState(() {
                          returnUnit = newValue;
                        });
                        await _saveSettingToCache(_returnUnitKey, newValue);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('نوع الدفع الإفتراضي (مبيعات)'),
                  subtitle: Text('النوع المحدد: $defaultSalesPayment'),
                  leading: const Icon(Icons.point_of_sale),
                  trailing: DropdownButton<String>(
                    value: defaultSalesPayment,
                    items: paymentOptions.map((String payment) {
                      return DropdownMenuItem<String>(
                        value: payment,
                        child: Text(payment),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        setState(() {
                          defaultSalesPayment = newValue;
                        });
                        await _saveSettingToCache(_defaultSalesPaymentKey, newValue);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('نوع الدفع الإفتراضي (مرتجع)'),
                  subtitle: Text('النوع المحدد: $defaultReturnPayment'),
                  leading: const Icon(Icons.assignment_return),
                  trailing: DropdownButton<String>(
                    value: defaultReturnPayment,
                    items: paymentOptions.map((String payment) {
                      return DropdownMenuItem<String>(
                        value: payment,
                        child: Text(payment),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        setState(() {
                          defaultReturnPayment = newValue;
                        });
                        await _saveSettingToCache(_defaultReturnPaymentKey, newValue);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('نوع الخصم الإفتراضي'),
                  subtitle: Text('النوع المحدد: $selectedDiscountType'),
                  leading: const Icon(Icons.discount),
                  trailing: DropdownButton<String>(
                    value: selectedDiscountType,
                    items: discountOptions.map((String discount) {
                      return DropdownMenuItem<String>(
                        value: discount,
                        child: Text(discount),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        setState(() {
                          selectedDiscountType = newValue;
                        });
                        await _saveSettingToCache(_selectedDiscountTypeKey, newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Paper Size Settings Section
          _buildSectionHeader('إعدادات حجم الورق', Icons.description),
          Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  title: const Text('حجم الورق'),
                  subtitle: Text('الحجم المحدد: $selectedPaperSize'),
                  leading: const Icon(Icons.description),
                  trailing: DropdownButton<String>(
                    value: selectedPaperSize,
                    items: paperSizes.map((String size) {
                      return DropdownMenuItem<String>(
                        value: size,
                        child: Text(size),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        setState(() {
                          selectedPaperSize = newValue;
                        });
                        await _saveSettingToCache(_selectedPaperSizeKey, newValue);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('معاينة حجم الورق'),
                  subtitle: const Text('عرض معاينة للحجم المحدد'),
                  leading: const Icon(Icons.preview),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    SoundManager().playClickSound();
                    _showPaperPreview(context);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetSettings,
                  icon: const Icon(Icons.restore),
                  label: const Text('إعادة تعيين'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ الإعدادات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF148ccd),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF148ccd)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF148ccd),
            ),
          ),
        ],
      ),
    );
  }

  void _showBluetoothDevices(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Text('أجهزة البلوتوث'),
                  const Spacer(),
                  if (isScanning)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  children: [
                    // Connected Devices Section
                    if (bondedDevices.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'الأجهزة المتصلة:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ListView.builder(
                          itemCount: bondedDevices.length,
                          itemBuilder: (context, index) {
                            BluetoothDevice device = bondedDevices[index];
                            bool isConnected = connectedDevice?.remoteId == device.remoteId;

                            return ListTile(
                              leading: Icon(
                                isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                                color: isConnected ? Colors.green : Colors.blue,
                              ),
                              title: Text(device.platformName.isNotEmpty
                                  ? device.platformName
                                  : 'جهاز غير معروف'),
                              subtitle: Text(device.remoteId.toString()),
                              trailing: isConnected
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.arrow_forward_ios),
                              onTap: isConnected
                                  ? null
                                  : () {
                                      SoundManager().playClickSound();
                                      Navigator.pop(context);
                                      _connectToDevice(device);
                                    },
                            );
                          },
                        ),
                      ),
                      const Divider(),
                    ],

                    // Scan Results Section
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'الأجهزة المكتشفة:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: scanResults.isEmpty && !isScanning
                          ? const Center(child: Text('لا توجد أجهزة مكتشفة'))
                          : ListView.builder(
                              itemCount: scanResults.length,
                              itemBuilder: (context, index) {
                                ScanResult result = scanResults[index];
                                BluetoothDevice device = result.device;

                                return ListTile(
                                  leading: Icon(
                                    Icons.bluetooth_searching,
                                    color: Colors.grey[600],
                                  ),
                                  title: Text(device.platformName.isNotEmpty
                                      ? device.platformName
                                      : 'جهاز غير معروف'),
                                  subtitle: Text('${device.remoteId} - القوة: ${result.rssi}'),
                                  onTap: () {
                                    SoundManager().playClickSound();
                                    Navigator.pop(context);
                                    _connectToDevice(device);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    SoundManager().playClickSound();
                    if (isScanning) {
                      _stopScan();
                    } else {
                      _startScan();
                    }
                    setDialogState(() {
                      isScanning = !isScanning;
                    });
                    setState(() {
                      // Update the main state if needed
                    });
                  },
                  child: Text(isScanning ? 'إيقاف البحث' : 'بحث عن أجهزة'),
                ),
                TextButton(
                  onPressed: () {
                    SoundManager().playClickSound();
                    Navigator.pop(context);
                  },
                  child: const Text('إغلاق'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPaperPreview(BuildContext context) {
    Map<String, double> getPaperDimensions(String paperSize) {
      switch (paperSize.toUpperCase()) {
        case 'A4':
          return {'width': 210.0, 'height': 297.0}; // A4 ratio scaled down
        case 'A5':
          return {'width': 148.0, 'height': 210.0}; // A5 ratio scaled down
        case '58MM':
          return {'width': 120.0, 'height': 200.0}; // Thermal receipt paper (narrow)
        case '80MM':
          return {'width': 160.0, 'height': 200.0}; // Thermal receipt paper (wider)
        default:
          return {'width': 200.0, 'height': 280.0}; // Default size
      }
    }

// Your modified dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final dimensions = getPaperDimensions(selectedPaperSize);

        return AlertDialog(
          title: Text('معاينة حجم $selectedPaperSize'),
          content: Container(
            width: dimensions['width'],
            height: dimensions['height'],
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                selectedPaperSize,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                SoundManager().playClickSound();
                Navigator.pop(context);
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetSettings() async {
    SoundManager().playClickSound();
    try {
      setState(() {
        pointerEnabled = true;
        pointerSensitivity = 50.0;
        selectedPaperSize = 'A4';
        autoConnect = false;
        stockTransferUnit = 'أساسية';
        returnUnit = 'أساسية';
        defaultSalesPayment = 'نقدي';
        defaultReturnPayment = 'نقدي';
        selectedDiscountType = 'نسبة';
      });

      // Clear all cached settings
      await settingsBox.clear();

      // Save default values to cache
      await _saveSettingToCache(_pointerEnabledKey, true);
      await _saveSettingToCache(_pointerSensitivityKey, 50.0);
      await _saveSettingToCache(_selectedPaperSizeKey, 'A4');
      await _saveSettingToCache(_autoConnectKey, false);
      await _saveSettingToCache(_stockTransferUnitKey, 'أساسية');
      await _saveSettingToCache(_returnUnitKey, 'أساسية');
      await _saveSettingToCache(_defaultSalesPaymentKey, 'نقدي');
      await _saveSettingToCache(_defaultReturnPaymentKey, 'نقدي');
      await _saveSettingToCache(_selectedDiscountTypeKey, 'نسبة');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إعادة تعيين الإعدادات إلى القيم الافتراضية'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('خطأ في إعادة تعيين الإعدادات: $e');
    }
  }

  Future<void> _saveSettings() async {
    SoundManager().playClickSound();
    try {
      // Save all current settings to cache
      await _saveSettingToCache(_pointerEnabledKey, pointerEnabled);
      await _saveSettingToCache(_pointerSensitivityKey, pointerSensitivity);
      await _saveSettingToCache(_selectedPaperSizeKey, selectedPaperSize);
      await _saveSettingToCache(_autoConnectKey, autoConnect);
      await _saveSettingToCache(_stockTransferUnitKey, stockTransferUnit);
      await _saveSettingToCache(_returnUnitKey, returnUnit);
      await _saveSettingToCache(_defaultSalesPaymentKey, defaultSalesPayment);
      await _saveSettingToCache(_defaultReturnPaymentKey, defaultReturnPayment);
      await _saveSettingToCache(_selectedDiscountTypeKey, selectedDiscountType);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الإعدادات بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      await HiveSettingsManager.printAllSettings();
    } catch (e) {
      _showErrorSnackBar('خطأ في حفظ الإعدادات: $e');
    }
  }

  // Method to get all cached settings as a Map (useful for debugging or exporting)
  Map<String, dynamic> getAllCachedSettings() {
    return {
      _pointerEnabledKey: settingsBox.get(_pointerEnabledKey),
      _pointerSensitivityKey: settingsBox.get(_pointerSensitivityKey),
      _selectedPaperSizeKey: settingsBox.get(_selectedPaperSizeKey),
      _autoConnectKey: settingsBox.get(_autoConnectKey),
      _stockTransferUnitKey: settingsBox.get(_stockTransferUnitKey),
      _returnUnitKey: settingsBox.get(_returnUnitKey),
      _defaultSalesPaymentKey: settingsBox.get(_defaultSalesPaymentKey),
      _defaultReturnPaymentKey: settingsBox.get(_defaultReturnPaymentKey),
      _selectedDiscountTypeKey: settingsBox.get(_selectedDiscountTypeKey),
      _lastConnectedDeviceKey: settingsBox.get(_lastConnectedDeviceKey),
    };
  }

  // Method to import settings from a Map (useful for backup/restore)
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      for (String key in settings.keys) {
        if (settings[key] != null) {
          await _saveSettingToCache(key, settings[key]);
        }
      }
      await _loadCachedSettings();
    } catch (e) {
      _showErrorSnackBar('خطأ في استيراد الإعدادات: $e');
    }
  }
}
