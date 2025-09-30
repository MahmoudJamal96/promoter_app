import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';

import '../models/client_model.dart';

class EnhancedClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;
  final VoidCallback? onNavigate;

  const EnhancedClientCard({
    super.key,
    required this.client,
    required this.onTap,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final balance = client.balance;
    final isPositiveBalance = balance > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          onTap();
          SoundManager().playClickSound();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              Row(
                children: [
                  // Status icon
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: client.getStatusColor().withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      client.getStatusIcon(),
                      color: client.getStatusColor(),
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Client info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          client.address,
                          style: TextStyle(fontSize: 12.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Distance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        client.formatDistance(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF148ccd),
                        ),
                      ),
                      // SizedBox(height: 4.h),
                      // Text(
                      //   client.getStatusText(),
                      //   style: TextStyle(
                      //     fontSize: 12.sp,
                      //     color: client.getStatusColor(),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),

              Divider(height: 24.h),

              // Bottom section with debt and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Debt info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الرصيد',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      Text(
                        '${client.balance} ج.م',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isPositiveBalance ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),

                  // Navigate button
                  if (onNavigate != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        SoundManager().playClickSound();
                        onNavigate!();
                      },
                      icon: Icon(Icons.directions, size: 16.r),
                      label: const Text('توجيه'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
