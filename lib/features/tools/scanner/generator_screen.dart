import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class GeneratorScreen extends StatefulWidget {
  static const id = '/generator_screen';
  final String code;
  final double? width, height;

  const GeneratorScreen({super.key, required this.code, this.height, this.width});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: BarcodeWidget(
          data: widget.code,
          barcode: Barcode.qrCode(),
          // color: CustomTheme.primary.textColor,
          height: widget.height ?? 250,
          width: widget.width ?? 250,
        ),
    );
  }
}
