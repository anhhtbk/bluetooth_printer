import 'package:bluetooth_printer/blue_print_pos.dart';
import 'package:bluetooth_printer/models/models.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BluePrintPos _bluePrintPos = BluePrintPos.instance;
  List<BlueDevice> _blueDevices = <BlueDevice>[];
  BlueDevice? _selectedDevice;
  bool _isLoading = false;
  int _loadingAtIndex = -1;

  @override
  void initState() {
    super.initState();
    _onScanPressed();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Printer'),
        ),
        body: SafeArea(
          child: _isLoading && _blueDevices.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              : _blueDevices.isNotEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            children: List<Widget>.generate(_blueDevices.length,
                                (int index) {
                              return Row(
                                children: <Widget>[
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _blueDevices[index].address ==
                                              (_selectedDevice?.address ?? '')
                                          ? _onDisconnectDevice
                                          : () => _onSelectDevice(index),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              _blueDevices[index].name,
                                              style: TextStyle(
                                                color:
                                                    _selectedDevice?.address ==
                                                            _blueDevices[index]
                                                                .address
                                                        ? Colors.blue
                                                        : Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              _blueDevices[index].address,
                                              style: TextStyle(
                                                color:
                                                    _selectedDevice?.address ==
                                                            _blueDevices[index]
                                                                .address
                                                        ? Colors.blueGrey
                                                        : Colors.grey,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_loadingAtIndex == index && _isLoading)
                                    Container(
                                      height: 24.0,
                                      width: 24.0,
                                      margin: const EdgeInsets.only(right: 8.0),
                                      child: const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.blue,
                                        ),
                                      ),
                                    ),
                                  if (!_isLoading &&
                                      _blueDevices[index].address ==
                                          (_selectedDevice?.address ?? ''))
                                    TextButton(
                                      onPressed: _onPrintReceipt,
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.pressed)) {
                                              return Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.5);
                                            }
                                            return Theme.of(context)
                                                .primaryColor;
                                          },
                                        ),
                                      ),
                                      child: Container(
                                        color: _selectedDevice == null
                                            ? Colors.grey
                                            : Colors.blue,
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Text(
                                          'Test Print',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Text(
                            'Scan bluetooth device',
                            style: TextStyle(fontSize: 24, color: Colors.blue),
                          ),
                          Text(
                            'Press button scan',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isLoading ? null : _onScanPressed,
          backgroundColor: _isLoading ? Colors.grey : Colors.blue,
          child: const Icon(Icons.search),
        ),
      ),
    );
  }

  Future<void> _onScanPressed() async {
    setState(() => _isLoading = true);
    final List<BlueDevice> devices = await _bluePrintPos.scan();
    final List<BlueDevice> printers = devices
        .where((element) => element.name.toLowerCase().contains('printer'))
        .toList();
    debugPrint('printers: ${printers.length}');
    if (printers.isNotEmpty) {
      setState(() {
        _blueDevices = printers;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _onDisconnectDevice() {
    _bluePrintPos.disconnect().then((ConnectionStatus status) {
      if (status == ConnectionStatus.disconnect) {
        setState(() {
          _selectedDevice = null;
        });
      }
    });
  }

  void _onSelectDevice(int index) {
    setState(() {
      _isLoading = true;
      _loadingAtIndex = index;
    });
    final BlueDevice blueDevice = _blueDevices[index];
    _bluePrintPos.connect(blueDevice).then((ConnectionStatus status) {
      if (status == ConnectionStatus.connected) {
        setState(() => _selectedDevice = blueDevice);
        _onPrintReceipt();
      } else if (status == ConnectionStatus.timeout) {
        _onDisconnectDevice();
      } else {
        debugPrint('$runtimeType - something wrong');
      }
      setState(() => _isLoading = false);
    });
  }

  Future<void> _onPrintReceipt() async {
    /// Example for Print Text
    // final ReceiptSectionText receiptText = ReceiptSectionText();

    // receiptText.addText(
    //   'Xin chào',
    //   size: ReceiptTextSizeType.medium,
    //   style: ReceiptTextStyleType.bold,
    // );
    // receiptText.addSpacer(count: 2);

    // await _bluePrintPos.printReceiptText(receiptText);

    // final defaultProfile = await CapabilityProfile.load(name: "RP80USE");
    // final Generator generator = Generator(PaperSize.mm58, defaultProfile);
    final charsets = await CharsetConverter.availableCharsets();
    for (final charset in charsets) {
      // for (final codePage in defaultProfile.codePages) {
      try {
        final bytes = await CharsetConverter.encode(charset, "$charset ấổ");
        // final encodedBytes = generator.row(<PosColumn>[
        //   PosColumn(
        //     textEncoded: bytes,
        //     width: 12,
        //     styles: PosStyles(codeTable: codePage.name),
        //   ),
        // ]);

        _bluePrintPos.printText(bytes);
      } catch (exception) {
        debugPrint(exception.toString());
      }
      // }
    }
  }
}
