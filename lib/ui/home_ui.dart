import 'package:experiment/widgets/dialog_loading.dart';
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
  bool _isLoading;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.cyan,
        title: Text('xplore'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: initBluetooth,
        child: Icon(Icons.search),
      ),
      body: (_isLoading == true)
          ? _buildScanLoading()
          : _devices.isEmpty
              ? Center(child: Text(_deviceMsg ?? ''))
              : RefreshIndicator(
                  onRefresh: scanPrinter,
                  child: ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.print_rounded),
                        title: Text(_devices[index].name),
                        subtitle: Text(_devices[index].address),
                        onTap: () async {
                          DialogLoading.show(context);
                          await _startPrint(_devices[index]);
                          DialogLoading.hide(context);
                        },
                      );
                    },
                  ),
                ),
    );
  }

  void initBluetooth() {
    _bluetoohManager.state.listen((event) async {
      if (!mounted)
        return;
      else {
        if (event == 12)
          scanPrinter();
        else if (event == 10)
          setState(() => _deviceMsg = 'Bluetooth tidak aktif');
      }
    });
  }

  Future<void> scanPrinter() async {
    setState(() => _setLoading(true));

    /// when scanning , the duration is 3 seconds
    _printerBluetoothManager.startScan(Duration(seconds: 3));

    /// Because startScan is void so i use delay future
    /// with duration same with scan duration
    await Future.delayed(Duration(seconds: 3));

    _printerBluetoothManager.scanResults.listen((event) {
      if (!mounted) return;
      setState(() => _devices = event);
      if (_devices.isEmpty)
        setState(() => _deviceMsg = "Perangkat tidak ditemukan");
    });

    setState(() => _setLoading(false));
  }

  bool _setLoading(bool value) => _isLoading = value;

  Future<void> _startPrint(PrinterBluetooth printer) async {
    try {
      _printerBluetoothManager.selectPrinter(printer);
      await _printerBluetoothManager.printTicket(await _ticket(PaperSize.mm58));
    } catch (e) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<Ticket> _ticket(PaperSize paperSize) async {
    final _ticket = Ticket(paperSize);
    // HEADER (outlet name and address)
    _ticket.text('FERDI ANISSA', styles: PosStyles(align: PosAlign.left));
    _ticket.text('Jl. Pacitan Raya', styles: PosStyles(align: PosAlign.left));

    // build space
    _ticket.feed(1);

    // separator
    _ticket.hr();

    // ticket body
    for (int i = 0; i < 3; i++) {
      _ticket.row([
        PosColumn(text: 'Indosat $i GB', width: 12),
      ]);
      _ticket.row([
        PosColumn(text: '$i x 1$i.000', width: 6),
        PosColumn(
          text: '1$i.000',
          width: 6,
          styles: PosStyles(
            align: PosAlign.right,
          ),
        ),
      ]);
    }

    // ticket footer
    _ticket.hr();
    _ticket.row([
      PosColumn(text: 'TOTAL BELANJA', width: 6),
      PosColumn(
        text: 'Rp. 10.000',
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    _ticket.row([
      PosColumn(text: 'TOTAL BAYAR', width: 6),
      PosColumn(
        text: 'Rp. 10.000',
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    _ticket.row([
      PosColumn(text: 'KEMBALIAN', width: 6),
      PosColumn(
        text: 'Rp. 10.000',
        width: 6,
        styles: PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    _ticket.hr();

    // build space
    _ticket.feed(1);

    _ticket.text('Terimakasih sudah berbelanja,',
        styles: PosStyles(align: PosAlign.left));
    _ticket.text('semoga dilancarkan semua urusan,',
        styles: PosStyles(align: PosAlign.left));

    _ticket.cut();
    return _ticket;
  }

  @override
  void dispose() {
    _printerBluetoothManager.stopScan();
    super.dispose();
  }

  Widget _buildScanLoading() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text('Mencari printer'),
      ],
    ));
  }
}
