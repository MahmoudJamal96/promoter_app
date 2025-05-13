import 'package:flutter/cupertino.dart';

extension SizedBoxs on int {
  SizedBox sizedBoxWidth() => SizedBox(width: toDouble());

  SizedBox sizedBoxHeight() => SizedBox(height: toDouble());

  SizedBox sizedBoxSquare() => SizedBox(width: toDouble(), height: toDouble());
}
