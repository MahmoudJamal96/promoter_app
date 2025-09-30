import 'package:flutter/material.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';

enum OrderStatus {
  active('نشط'),
  completed('مكتمل'),
  cancelled('ملغي');

  const OrderStatus(this.arabicLabel);
  final String arabicLabel;
}

class OrderStatusDialog extends StatefulWidget {
  final OrderStatus currentStatus;
  final Function(OrderStatus) onStatusChanged;

  const OrderStatusDialog({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  State<OrderStatusDialog> createState() => _OrderStatusDialogState();
}

class _OrderStatusDialogState extends State<OrderStatusDialog> {
  late OrderStatus selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'تغيير حالة الطلب',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.right,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: OrderStatus.values.map((status) {
          return RadioListTile<OrderStatus>(
            title: Text(
              status.arabicLabel,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
            value: status,
            groupValue: selectedStatus,
            onChanged: (OrderStatus? value) {
              if (value != null) {
                setState(() {
                  selectedStatus = value;
                });
              }
            },
            activeColor: _getStatusColor(status),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            SoundManager().playClickSound();
            Navigator.of(context).pop();
          },
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            SoundManager().playClickSound();
            widget.onStatusChanged(selectedStatus);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _getStatusColor(selectedStatus),
          ),
          child: const Text(
            'حفظ',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.active:
        return Colors.blue;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
