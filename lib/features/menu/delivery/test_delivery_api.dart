import 'package:flutter/material.dart';
import '../../../core/di/injection_container.dart';
import 'services/delivery_service.dart';
import 'models/delivery_order_model.dart';

/// Test widget to verify the delivery API integration
class TestDeliveryApiWidget extends StatefulWidget {
  const TestDeliveryApiWidget({Key? key}) : super(key: key);

  @override
  State<TestDeliveryApiWidget> createState() => _TestDeliveryApiWidgetState();
}

class _TestDeliveryApiWidgetState extends State<TestDeliveryApiWidget> {
  final DeliveryService _deliveryService = sl<DeliveryService>();
  List<DeliveryOrder> _orders = [];
  bool _isLoading = false;
  String _message = '';

  Future<void> _testGetOrders() async {
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
        title: Text('Delivery API Test'),
        backgroundColor: Colors.blue,
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
                  child: Text('Test Get Orders'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testGetActiveOrders,
                  child: Text('Test Active Orders'),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else ...[
              Text(
                'Result:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(_message),
              SizedBox(height: 20),
              if (_orders.isNotEmpty) ...[
                Text(
                  'Orders (${_orders.length}):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
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
