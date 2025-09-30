import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/features/client/cubit/client_cubit_service.dart';
import 'package:promoter_app/features/client/cubit/client_state.dart';
import 'package:promoter_app/features/client/models/client_model.dart';

class UserStatusDialog extends StatefulWidget {
  final String initialStatus;
  final int clientId;
  final Function(String) onStatusChanged;

  const UserStatusDialog({
    super.key,
    required this.initialStatus,
    required this.clientId,
    required this.onStatusChanged,
  });

  @override
  State<UserStatusDialog> createState() => _UserStatusDialogState();
}

class _UserStatusDialogState extends State<UserStatusDialog> {
  late String selectedStatus;

  final List<Map<String, dynamic>> statusOptions = [
    {
      'value': 'notVisited',
      'label': 'لم تتم الزيارة',
      'color': Colors.grey.shade100,
      'textColor': Colors.grey.shade700,
      'icon': Icons.pending_outlined,
    },
    {
      'value': 'visited',
      'label': 'تمت الزيارة',
      'color': Colors.green.shade100,
      'textColor': Colors.green.shade700,
      'icon': Icons.check_circle_outline,
    },
    {
      'value': 'postponed',
      'label': 'مؤجلة',
      'color': Colors.orange.shade100,
      'textColor': Colors.orange.shade700,
      'icon': Icons.schedule_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.initialStatus;
  }

  Color _getStatusColor() {
    final status = statusOptions.firstWhere(
      (s) => s['value'] == selectedStatus,
      orElse: () => statusOptions[0],
    );
    return status['color'];
  }

  Color _getStatusTextColor() {
    final status = statusOptions.firstWhere(
      (s) => s['value'] == selectedStatus,
      orElse: () => statusOptions[0],
    );
    return status['textColor'];
  }

  IconData _getStatusIcon() {
    final status = statusOptions.firstWhere(
      (s) => s['value'] == selectedStatus,
      orElse: () => statusOptions[0],
    );
    return status['icon'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.person_outline,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          const Text(
            'تغيير حالة المستخدم',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الحالة الحالية:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 16,
                    color: _getStatusTextColor(),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusOptions.firstWhere(
                      (s) => s['value'] == selectedStatus,
                      orElse: () => statusOptions[0],
                    )['label'],
                    style: TextStyle(
                      color: _getStatusTextColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'اختر الحالة الجديدة:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedStatus,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: BorderRadius.circular(8),
                  items: statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status['value'],
                      child: Row(
                        children: [
                          Icon(
                            status['icon'],
                            size: 20,
                            color: status['textColor'],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status['label'],
                            style: TextStyle(
                              color: status['textColor'],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      log('Selected status: $newValue');
                      setState(() {
                        selectedStatus = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            SoundManager().playClickSound();
            Navigator.of(context).pop();
          },
          child: const Text(
            'إلغاء',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        BlocConsumer<ClientCubit, ClientState>(
          listener: (context, state) {},
          builder: (context, state) {
            return ElevatedButton(
              onPressed: () {
                SoundManager().playClickSound();
                widget.onStatusChanged(selectedStatus);
                context.read<ClientCubit>().updateClientStatus(
                    widget.clientId,
                    VisitStatus.values.firstWhere(
                      (status) => status.name == selectedStatus,
                      orElse: () => VisitStatus.notVisited,
                    ));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('حفظ'),
            );
          },
        ),
      ],
    );
  }
}
