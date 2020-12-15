import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';

class HomeUI extends StatefulWidget {
  @override
  _HomeUIState createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  PrinterBluetoothManager _printerBluetoothManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  String _deviceMsg;

  // BLUETOOTH MANAGER
  BluetoothManager _bluetoohManager = BluetoothManager.instance;

  @override
  void initState() {
    initBluetooth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.cyan,
        title: Text('xplore'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          initBluetooth();
        },
        child: Icon(Icons.search),
      ),
      body: _devices.isEmpty
          ? Center(child: Text(_deviceMsg ?? ''))
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.print_rounded),
                  title: Text(_devices[index].name),
                  subtitle: Text(_devices[index].address),
                  onTap: () {
                    _startPrint(_devices[index]);
                  },
                );
              },
            ),
    );
  }

  void initBluetooth() {
    _bluetoohManager.state.listen((event) {
      if (!mounted) return;
      if (event == 12)
        scanPrinter();
      else if (event == 10) setState(() => _deviceMsg = 'Bluetooth off');
    });
  }

  void scanPrinter() {
    _printerBluetoothManager.startScan(Duration(seconds: 5));
    _printerBluetoothManager.scanResults.listen((event) {
      if (!mounted) return;
      setState(() => _devices = event);
      if (_devices.isEmpty) setState(() => _deviceMsg = "No devices");
    });
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    _printerBluetoothManager.selectPrinter(printer);
    final result = await _printerBluetoothManager
        .printTicket(await _ticket(PaperSize.mm58));
    print(result);
  }

  Future<Ticket> _ticket(PaperSize paperSize) async {
    final _ticket = Ticket(paperSize);
    _ticket.text('FERDI ANISSA CELLULAR',
        styles: PosStyles(
          align: PosAlign.center,
          bold: true,
          underline: true,
        ));
    _ticket.feed(2);

    for (int i = 0; i < 3; i++) {
      _ticket.row([
        PosColumn(text: 'Indosat $i GB', width: 6),
        PosColumn(text: 'Rp. 1$i.000', width: 6),
      ]);
      _ticket.row([
        PosColumn(text: '$i x 1$i.000', width: 12),
      ]);
    }

    _ticket.feed(1);
    _ticket.row([
      PosColumn(text: 'Total', styles: PosStyles(bold: true), width: 6),
      PosColumn(text: 'Rp. 110.000', styles: PosStyles(bold: true), width: 6),
    ]);
    _ticket.feed(2);

    _ticket.text('ARIGATO',
        styles: PosStyles(
          align: PosAlign.center,
        ));

    _ticket.cut();
    return _ticket;
  }

  @override
  void dispose() {
    _printerBluetoothManager.stopScan();
    super.dispose();
  }
}
