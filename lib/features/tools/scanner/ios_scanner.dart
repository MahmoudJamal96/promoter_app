import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:promoter_app/core/constants/assets.dart';
import 'package:promoter_app/core/service/audio.dart';
import 'package:promoter_app/core/view/widgets/image_loader.dart';
import 'package:rxdart/rxdart.dart';

Function()? reloadIosScanner;

Function()? pauseIosScanner;

class IOSScanner extends StatefulWidget {
  static const id = '/scanner';
  final Function(String? barcode) scanResult;
  final Function(String? barcode)? scanBefore;

  final bool isContinues;

  IOSScanner({
    super.key,
    required this.scanResult,
    this.scanBefore,
    this.isContinues = false,
  }) {
    print("Scanner");
  }

  @override
  State<IOSScanner> createState() => _IOSScannerState();
}

class _IOSScannerState extends State<IOSScanner> {
  // late QRViewController screenController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    Audio.getInstance().play('');

    mobileScannerController = MobileScannerController(
      detectionTimeoutMs: 500,
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
      autoStart: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mobileScannerController.value.isInitialized || !mobileScannerController.value.isRunning) {
        await mobileScannerController.stop();
        await mobileScannerController.start();
      }
    });

    reloadIosScanner = () async {
      try {
        setState(() {});

        Timer(const Duration(milliseconds: 250), () {
          subsc?.close();
          // screenController.resumeCamera();
          mobileScannerController.start();
        });
      } catch (e) {}
    };
    pauseIosScanner = () async {
      try {
        // subsc?.close();
        Future.delayed(const Duration(milliseconds: 250)).then((_) {
          mobileScannerController.stop();
        });
      } catch (e) {}
    };
    super.initState();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      // screenController.pauseCamera();
    } else if (Platform.isIOS) {
      print("resumeCamera");
      // screenController.resumeCamera();
    }
  }

  bool islistenable = true;
  BehaviorSubject<Barcode>? subsc = BehaviorSubject<Barcode>();
  List<Barcode> qrs = [];
  int counter = 0;

  late MobileScannerController mobileScannerController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    MobileScanner(
                      placeholderBuilder: (_, __) => const SizedBox.shrink(),
                      controller: mobileScannerController,
                      errorBuilder: (_, __, m) {
                        mobileScannerController.stop();
                        mobileScannerController.start();
                        return const SizedBox.shrink();
                      },
                      onDetect: (capture) {
                        Audio.getInstance().play(Assets.beepAudio);
                        if (!widget.isContinues) {
                          final List<Barcode> barcodes = capture.barcodes;
                          final Uint8List? image = capture.image;
                          Barcode code = barcodes.first;
                          mobileScannerController.stop();
                          widget.scanResult.call(code.displayValue);
                          mobileScannerController.stop();

                          return;
                        }

                        final List<Barcode> barcodes = capture.barcodes;
                        final Uint8List? image = capture.image;
                        for (final barcode in barcodes) {
                          Timer(const Duration(milliseconds: 500), () {
                            widget.scanResult.call(barcode.displayValue);
                          });

                          debugPrint('Barcode found! ${barcode.displayValue}');
                        }
                      },
                    ),
                    Positioned.fill(
                      child: ImageLoader(
                        path: Assets.scanCurves,
                        width: 1.sw,
                        height: 1.sh,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    qrs.clear();
    // screenController.dispose();
  }
}
