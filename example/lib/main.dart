import 'dart:async';
// import 'dart:io' show Platform;

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(_MyApp());
}

class _MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> {
   ScanResult scanResult = ScanResult();

  // final _flashOnController = TextEditingController(text: "Flash on");
  // final _flashOffController = TextEditingController(text: "Flash off");
  // final _cancelController = TextEditingController(text: "Cancel");

  // var _aspectTolerance = 0.00;
  // var _numberOfCameras = 0;
  // var _selectedCamera = -1;
  // var _useAutoFocus = true;
  // var _autoEnableFlash = false;

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  // List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  @override
  // ignore: type_annotate_public_apis
  initState() {
    super.initState();

    // Future.delayed(Duration.zero, () async {
    //   _numberOfCameras = await BarcodeScanner.numberOfCameras;
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
          // if (scanResult != null)

    var contentList = <Widget>[
        Card(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text("Result Type"),
                subtitle: Text(scanResult?.type?.toString() ?? ""),
              ),
              ListTile(
                title: Text("Raw Content"),
                subtitle: Text(scanResult?.rawContent ?? ""),
              ),
              ListTile(
                title: Text("Format"),
                subtitle: Text(scanResult?.format?.toString() ?? ""),
              ),
              ListTile(
                title: Text("Format note"),
                subtitle: Text(scanResult?.formatNote ?? ""),
              ),
            ],
          ),
        ),
      // ListTile(
      //   title: Text("Camera selection"),
      //   dense: true,
      //   enabled: false,
      // ),
      // RadioListTile(
      //   onChanged: (v) => setState(() => _selectedCamera = -1),
      //   value: -1,
      //   title: Text("Default camera"),
      //   groupValue: _selectedCamera,
      // ),
    ];

    // for (var i = 0; i < _numberOfCameras; i++) {
    //   contentList.add(RadioListTile(
    //     onChanged: (v) => setState(() => _selectedCamera = i),
    //     value: i,
    //     title: Text("Camera ${i + 1}"),
    //     groupValue: _selectedCamera,
    //   ));
    // }

    // contentList.addAll([
    //   ListTile(
    //     title: Text("Button Texts"),
    //     dense: true,
    //     enabled: false,
    //   ),
    //   ListTile(
    //     title: TextField(
    //       decoration: InputDecoration(
    //         hasFloatingPlaceholder: true,
    //         labelText: "Flash On",
    //       ),
    //       controller: _flashOnController,
    //     ),
    //   ),
    //   ListTile(
    //     title: TextField(
    //       decoration: InputDecoration(
    //         hasFloatingPlaceholder: true,
    //         labelText: "Flash Off",
    //       ),
    //       controller: _flashOffController,
    //     ),
    //   ),
    //   ListTile(
    //     title: TextField(
    //       decoration: InputDecoration(
    //         hasFloatingPlaceholder: true,
    //         labelText: "Cancel",
    //       ),
    //       controller: _cancelController,
    //     ),
    //   ),
    // ]);

    // if (Platform.isAndroid) {
    //   contentList.addAll([
    //     ListTile(
    //       title: Text("Android specific options"),
    //       dense: true,
    //       enabled: false,
    //     ),
    //     ListTile(
    //       title:
    //           Text("Aspect tolerance (${_aspectTolerance.toStringAsFixed(2)})"),
    //       subtitle: Slider(
    //         min: -1.0,
    //         max: 1.0,
    //         value: _aspectTolerance,
    //         onChanged: (value) {
    //           setState(() {
    //             _aspectTolerance = value;
    //           });
    //         },
    //       ),
    //     ),
    //     CheckboxListTile(
    //       title: Text("Use autofocus"),
    //       value: _useAutoFocus,
    //       onChanged: (checked) {
    //         setState(() {
    //           _useAutoFocus = checked;
    //         });
    //       },
    //     )
    //   ]);
    // }

    // contentList.addAll([
    //   ListTile(
    //     title: Text("Other options"),
    //     dense: true,
    //     enabled: false,
    //   ),
    //   CheckboxListTile(
    //     title: Text("Start with flash"),
    //     value: _autoEnableFlash,
    //     onChanged: (checked) {
    //       setState(() {
    //         _autoEnableFlash = checked;
    //       });
    //     },
    //   )
    // ]);

    // contentList.addAll([
    //   ListTile(
    //     title: Text("Barcode formats"),
    //     dense: true,
    //     enabled: false,
    //   ),
    //   ListTile(
    //     trailing: Checkbox(
    //       tristate: true,
    //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //       value: selectedFormats.length == _possibleFormats.length
    //           ? true
    //           : selectedFormats.length == 0 ? false : null,
    //       onChanged: (checked) {
    //         setState(() {
    //           selectedFormats = [
    //             if (checked ?? false) ..._possibleFormats,
    //           ];
    //         });
    //       },
    //     ),
    //     dense: true,
    //     enabled: false,
    //     title: Text("Detect barcode formats"),
    //     subtitle: Text(
    //       'If all are unselected, all possible platform formats will be used',
    //     ),
    //   ),
    // ]);

    // contentList.addAll(_possibleFormats.map(
    //   (format) => CheckboxListTile(
    //     value: selectedFormats.contains(format),
    //     onChanged: (i) {
    //       setState(() => selectedFormats.contains(format)
    //           ? selectedFormats.remove(format)
    //           : selectedFormats.add(format));
    //     },
    //     title: Text(format.toString()),
    //   ),
    // ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Barcode Scanner Example'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.camera),
              tooltip: "Scan",
              onPressed: scan,
            ),
            IconButton(
              icon: Icon(Icons.camera_alt),
              tooltip: "Scan",
              onPressed: scan1,
            ),
          ],
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children:scanResult != null ? contentList : [],
        ),
      ),
    );
  }

  Future scan() async {
    try {
      var options = ScanOptions(
        strings: {
          "cancel": "取消",
          "flash_on": "开灯",
          "flash_off": "关灯",
        },
        restrictFormat: _possibleFormats,
        useCamera: -1,
        autoEnableFlash: false,
        android: AndroidOptions(
          aspectTolerance: 0.5,// -1 到 1
          useAutoFocus: true,
        ),
      );

      var result = await BarcodeScanner.scan(options: options);

      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }

  Future scan1() async {
    try {
      var options = ScanOptions(
        strings: {
        "title" : "扫一扫",
     "detail" : "请将条码/二维码放入框内",
      "flash_on" : "打开手电筒",
      "flash_off" : "关闭手电筒",
      "hand_input" : "手动输入",
      "show_hand_input" : "1",
        },
        restrictFormat: _possibleFormats,
        useCamera: -1,
        autoEnableFlash: false,
        android: AndroidOptions(
          aspectTolerance: 0.5,// -1 到 1
          useAutoFocus: true,
        ),
      );

      var result = await BarcodeScanner.scan(options: options);

      setState(() => scanResult = result);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }
      setState(() {
        scanResult = result;
      });
    }
  }
}
