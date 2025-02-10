import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:promoter_app/core/service/audio.dart';

import 'ios_scanner.dart';

Function()? reloadScanner;

Function()? pauseScanner;

class Scanner extends StatefulWidget {
  static const id = '/scanner';
  final Function(String barcode) scanResult;
  final Function(String barcode)? scanBefore;

  final bool isContinues;
  const Scanner({
    super.key,
    required this.scanResult,
    this.isContinues = false,
    this.scanBefore,
  });

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  // late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(
    debugLabel: 'QR',
  );

  @override
  void initState() {
    // Audio.getInstance().play('');

    reloadScanner = () async => reloadIosScanner?.call();
    // () async {
    //   try {
    //     setState(() {});

    //     Timer(Duration(milliseconds: 250), () {
    //       subsc?.close();
    //       // screenController.resumeCamera();
    //       mobileScannerController.start();
    //     });
    //   } catch (e) {}
    // };
    pauseScanner = () async => pauseIosScanner?.call();

    // () async {
    //   try {
    //     subsc?.close();
    //     Future.delayed(Duration(milliseconds: 250)).then((_) {}
    //         // (value) => screenController.pauseCamera()
    //         );
    //   } catch (e) {}
    // };
    super.initState();

    // mobileScannerController = MobileScannerController(
    //   detectionTimeoutMs: 500,
    //   detectionSpeed:
    //       // widget.isContinues
    //       //     ? DetectionSpeed.normal
    //       //     :
    //       DetectionSpeed.noDuplicates,
    //   facing: CameraFacing.back,
    //   torchEnabled: false,
    // );
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      // controller.pauseCamera();
    } else if (Platform.isIOS) {
      // controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IOSScanner(
              scanResult: (scanData) => widget.scanResult.call(scanData!),
              isContinues: widget.isContinues,
              scanBefore: (scanData) => widget.scanBefore?.call(scanData!));
  }

  @override
  void dispose() {
    super.dispose();
    // if (mounted) controller.dispose();
  }
}
