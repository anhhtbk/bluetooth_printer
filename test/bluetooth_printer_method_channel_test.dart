import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bluetooth_printer/bluetooth_printer_method_channel.dart';

void main() {
  MethodChannelBluetoothPrinter platform = MethodChannelBluetoothPrinter();
  const MethodChannel channel = MethodChannel('bluetooth_printer');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}