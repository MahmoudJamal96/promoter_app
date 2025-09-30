import 'package:flutter/material.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';

import '../../../core/di/injection_container.dart';
import 'models/delivery_order_model.dart';
import 'services/delivery_service.dart';

/// Test widget to verify the delivery API integration
class TestDeliveryApiWidget extends StatefulWidget {
  const TestDeliveryApiWidget({super.key});

  @override
  State<TestDeliveryApiWidget> createState() => _TestDeliveryApiWidgetState();
}

class _TestDeliveryApiWidgetState extends State<TestDeliveryApiWidget> {
  final DeliveryService _deliveryService = sl<DeliveryService>();
  List<DeliveryOrder> _orders = [];
  bool _isLoading = false;
  String _message = '';

  Future<void> _testGetOrders() async {
    SoundManager().playClickSound();
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final orders = await _deliveryService.getOrders();
      setState(() {
        _orders = orders;
        _message = 'Successfully loaded ${orders.length} orders';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetActiveOrders() async {
    SoundManager().playClickSound();
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final orders = await _deliveryService.getActiveOrders();
      setState(() {
        _orders = orders;
        _message = 'Successfully loaded ${orders.length} active orders';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery API Test'),
        backgroundColor: const Color(0xFF148ccd),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testGetOrders,
                  child: const Text('Test Get Orders'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testGetActiveOrders,
                  child: const Text('Test Active Orders'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              const Text(
                'Result:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(_message),
              const SizedBox(height: 20),
              if (_orders.isNotEmpty) ...[
                Text(
                  'Orders (${_orders.length}):',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Card(
                        child: ListTile(
                          title: Text('Order ${order.id}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Customer: ${order.customerName}'),
                              Text('Status: ${order.status.name}'),
                              Text('Total: ${order.totalAmount} SAR'),
                              Text('Items: ${order.items.length}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
