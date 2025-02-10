import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OutlinedText extends StatelessWidget {
  const OutlinedText({
    super.key,
    required this.label,
    required this.data,
    this.labelStyle,
    this.dataStyle,
    this.dataWidget,
    this.callWidget = false,
    this.call,
    this.trailingWidget,
    this.radius,
  });

  final String label;
  final String data;
  final Widget? dataWidget;
  final bool callWidget;
  final TextStyle? labelStyle;
  final TextStyle? dataStyle;
  final VoidCallback? call;
  final Widget? trailingWidget;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius ?? 16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: labelStyle ??
                    TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
              ),
              SizedBox(height: 6.h),
              dataWidget ??
                  Text(
                    data,
                    style: dataStyle ??
                        TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
            ],
          ),
          const Spacer(),
          if (trailingWidget != null) trailingWidget!,
        ],
      ),
    );
  }
}
