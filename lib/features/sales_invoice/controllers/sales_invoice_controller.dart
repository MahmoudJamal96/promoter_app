import '../services/sales_invoice_service.dart';
import '../models/sales_invoice_model.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/api_error_handler.dart';

class SalesInvoiceController {
  final SalesInvoiceService _salesInvoiceService;

  SalesInvoiceController({SalesInvoiceService? salesInvoiceService})
      : _salesInvoiceService = salesInvoiceService ?? sl();
  Future<Map<String, dynamic>> createInvoice({
    required int clientId,
    required String paymentMethod,
    required String notes,
    required List<Map<String, dynamic>> items,
  }) async {
    return ApiErrorHandler.call(() async {
      final response = await _salesInvoiceService.createInvoice(
        clientId: clientId,
        paymentMethod: paymentMethod,
        notes: notes,
        items: items,
      );
      return response;
    });
  }

  Future<List<SalesInvoice>> getInvoices({int page = 1}) async {
    return ApiErrorHandler.call(() async {
      final invoices = await _salesInvoiceService.getInvoices(page: page);
      return invoices;
    });
  }

  Future<SalesInvoice> getInvoiceDetails(int invoiceId) async {
    return ApiErrorHandler.call(() async {
      final invoice = await _salesInvoiceService.getInvoiceDetails(invoiceId);
      return invoice;
    });
  }
}
