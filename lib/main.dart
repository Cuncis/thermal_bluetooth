import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';


void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _pressed = false;
  String pathImage;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initSavetoPath();
  }

  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            _pressed = false;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            _pressed = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

  }

  initSavetoPath()async{
    //read and write
    //image max 300px X 300px
    final filename = 'bakugo1.png';
    var bytes = await rootBundle.load("assets/images/bakugo1.png");
    String dir = (await getApplicationDocumentsDirectory()).path;
    writeToFile(bytes,'$dir/$filename');
    setState(() {
      pathImage='$dir/$filename';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Blue Thermal Printer'),
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Device:', style: TextStyle(fontWeight: FontWeight.bold),)
                  ],
                ),
              ),
              DropdownButton(
                items: _getDeviceItems(),
                onChanged: (value) => setState(() => _device = value),
                value: _device,
              ),
              RaisedButton(onPressed: _pressed ? null : _connected ? _disconnect : _connect, child: Text(_connected ? 'Disconnect' : 'Connect'),),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
                child: RaisedButton(onPressed: _connected ? _tesPrint : null, child: Text('Test Print'),),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device){
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  void _connect() {
    if (_device == null) {
      show('No Device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected) {
          bluetooth.connect(_device).catchError((error) {
            setState(() {
              _pressed = false;
            });
            setState(() {
              _pressed = true;
            });
          });
        }
      });
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() {
      _pressed = true;
    });
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void _tesPrint() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printCustom("STRUK PEMBAYARAN PINJAMAN/KREDIT BUSSAN AUTO FINANCE (BAF)", 4, 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight("TANGGAL        : ", " 2019-10-02 14:39:59  ",0);
        bluetooth.printLeftRight("NO RESI        : ", " 20191002023943       ",0);
        bluetooth.printLeftRight("NOMOR KONTRAK  : ", " 1234567890           ",0);
        bluetooth.printLeftRight("NAMA           : ", " User Development Test",0);
        bluetooth.printLeftRight("NAMA KREDIT    : ", " BUSSAN AUTO FINANCE  ",0);
        bluetooth.printLeftRight("NO. POLISI     : ", " DA 6666 XX           ",0);
        bluetooth.printLeftRight("TYPE MOTOR     : ", " -                    ",0);
        bluetooth.printLeftRight("JATUH TEMPO    : ", " 20191002             ",0);
        bluetooth.printLeftRight("ANGSURAN KE    : ", " 28                   ",0);
        bluetooth.printLeftRight("TENOR          : ", " 28 BULAN             ",0);
        bluetooth.printLeftRight("ANGSURAN POKOK : ", " Rp          776.000  ",0);
        bluetooth.printLeftRight("BIAYA TAGIHAN  : ", " Rp            3.000  ",0);
        bluetooth.printLeftRight("              ", "-------------------------",0);
        bluetooth.printLeftRight("TOTAL TAGIHAN  : ", "Rp           779.000  ",0);
        bluetooth.printNewLine();
        bluetooth.printLeftRight("TERBILANG      : ", "", 0);
        bluetooth.printLeftRight("TUJUH RATUS TUJUH PULUH SEMBILAN RIBU RUPIAH", "", 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("TOTAL TAGIHAN BELUM MASUK DENDA (JIKA ADA).", 0, 0);
        bluetooth.printCustom("HARAP STRUK INI DISIMPAN SEBAGAI PEMBAYARAN YANG SAH.", 0, 0);
        bluetooth.printCustom("UNTUK INFORMASI SILAHKAN MENGHUBUNGI KANTOR CABANG BAF TERDEKAT", 0, 0);
        bluetooth.printNewLine();
        bluetooth.paperCut();

      //0 = LEFT
      //1 = CENTER



//        bluetooth.printCustom("HEADER", 3, 1);
//        bluetooth.printNewLine();
//        bluetooth.printImage(pathImage);
//        bluetooth.printNewLine();
//        bluetooth.printLeftRight("KIRI", "KANAN",0);
//        bluetooth.printLeftRight("kiri", "kanan",1);
//        bluetooth.printNewLine();
//        bluetooth.printLeftRight("KIRI", "KANAN",2);      // CENTER
//        bluetooth.printCustom("Body left",1,0);
//        bluetooth.printCustom("Body right",0,2);
//        bluetooth.printNewLine();
//        bluetooth.printCustom("Terimakasih",2,1);
//        bluetooth.printNewLine();
////        bluetooth.printQRcode("Text QR Code to Generate");    // QR Code
//        bluetooth.printNewLine();
//        bluetooth.printNewLine();
//        bluetooth.paperCut();
      }
    });
  }

  Future show(String message, {Duration duration: const Duration(seconds: 3)}) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    Scaffold.of(context).showSnackBar(
      new SnackBar(content: new Text(
        message,
        style: new TextStyle(
          color: Colors.white
        ),
      ),
        duration: duration,
      ),
    );
  }

}


























