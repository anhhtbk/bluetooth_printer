import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bluetooth_printer_platform_interface.dart';

/// An implementation of [BluetoothPrinterPlatform] that uses method channels.
class MethodChannelBluetoothPrinter extends BluetoothPrinterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bluetooth_printer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
