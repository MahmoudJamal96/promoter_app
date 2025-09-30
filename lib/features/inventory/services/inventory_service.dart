import 'dart:math';

import '../models/inventory_item.dart';
import '../models/product_model.dart';

// Mock data service to simulate API responses
class InventoryService {
  static final Random _random = Random();
  static final List<String> _categories = [
    'مواد غذائية',
    'ألبان وأجبان',
    'مشروبات',
    'منظفات',
    'خضروات وفواكه',
    'مخبوزات',
    'لحوم ودواجن',
    'معلبات',
    'منتجات أطفال',
    'وجبات سريعة'
  ];

  static final List<String> _suppliers = [
    'مخازن البركة',
    'شركة الوادي',
    'مستورد الأمين',
    'توزيع الشروق',
    'مصنع السعادة'
  ];

  static final List<String> _locations = [
    'رف البقالة الرئيسي',
    'ثلاجة الألبان',
    'قسم المشروبات',
    'قسم المنظفات',
    'قسم الخضروات',
    'قسم المخبوزات',
    'ثلاجة اللحوم',
    'قسم المعلبات',
    'رف الأطفال',
  ];

  // Product names by category
  static final Map<String, List<String>> _productsMap = {
    'مواد غذائية': [
      'أرز بسمتي',
      'سكر ناعم',
      'دقيق فاخر',
      'معكرونة إسباجتي',
      'زيت زيتون',
      'زيت نباتي',
      'شاي أسود',
      'قهوة عربية',
      'بهارات مشكلة',
      'ملح طعام',
      'فول مدمس',
      'عسل طبيعي',
      'مربى فراولة',
      'طحينة',
      'حلاوة طحينية'
    ],
    'ألبان وأجبان': [
      'حليب طازج',
      'حليب مبستر',
      'لبن زبادي',
      'جبن أبيض',
      'جبنة شيدر',
      'جبنة موزاريلا',
      'جبنة قريش',
      'قشطة طازجة',
      'زبدة',
      'كريمة خفق'
    ],
    'مشروبات': [
      'عصير برتقال',
      'عصير تفاح',
      'مشروب طاقة',
      'مياه معدنية',
      'صودا',
      'كولا',
      'شاي مثلج',
      'ليمونادة',
      'عصير مانجو',
      'عصير فراولة'
    ],
    'منظفات': [
      'معجون أسنان',
      'مسحوق غسيل',
      'شامبو',
      'بلسم شعر',
      'صابون سائل',
      'منظف زجاج',
      'معطر جو',
      'مناديل ورقية',
      'مناديل مبللة',
      'منظف أرضيات'
    ],
    'خضروات وفواكه': [
      'طماطم',
      'خيار',
      'بصل',
      'ثوم',
      'بطاطس',
      'جزر',
      'موز',
      'تفاح',
      'برتقال',
      'ليمون',
      'خس',
      'فلفل',
      'باذنجان',
      'كوسة',
      'بروكلي'
    ],
    'مخبوزات': [
      'خبز عربي',
      'خبز توست',
      'خبز بر',
      'صامولي',
      'كعك',
      'بسكويت',
      'كرواسون',
      'فطائر',
      'معجنات مشكلة',
      'كيك شوكولاتة'
    ],
    'لحوم ودواجن': [
      'لحم بقري',
      'لحم ضأن',
      'دجاج كامل',
      'صدور دجاج',
      'أفخاذ دجاج',
      'كبدة',
      'مقانق',
      'برجر لحم',
      'سمك فيليه',
      'روبيان'
    ],
    'معلبات': [
      'تونة معلبة',
      'سردين معلب',
      'ذرة معلبة',
      'فاصوليا معلبة',
      'فطر معلب',
      'معجون طماطم',
      'زيتون معلب',
      'فول معلب',
      'حمص معلب',
      'فواكه معلبة'
    ],
    'منتجات أطفال': [
      'حليب أطفال',
      'حفاضات',
      'بسكويت أطفال',
      'طعام أطفال',
      'شامبو أطفال',
      'كريم أطفال',
      'مناديل أطفال',
      'لبن مخصص للأطفال',
      'حبوب إفطار للأطفال',
      'عصير أطفال'
    ],
    'وجبات سريعة': [
      'نودلز سريعة',
      'برجر جاهز',
      'بيتزا مجمدة',
      'ناجتس دجاج',
      'فطائر مجمدة',
      'أصابع بطاطس',
      'كرات لحم',
      'سبرنج رول',
      'شاورما جاهزة',
      'ساندويتشات مجمدة'
    ]
  };

  // Mock product list
  static List<Product> products = _generateGroceryProducts();

  // Generate a list of grocery products
  static List<Product> _generateGroceryProducts() {
    List<Product> mockProducts = [];

    // Create products for each category
    for (String category in _categories) {
      // Get product names for this category
      List<String> productNames = _productsMap[category] ?? [];

      // Create products for this category
      for (int i = 0; i < productNames.length; i++) {
        final String productName = productNames[i];
        final String productId = 'PRD-${category.hashCode}-$i';
        final double price = _generatePrice();
        final int quantity = _random.nextInt(100) + 1; // 1-100 quantity

        // Generate random imageUrl - using placeholder images service
        final String imageUrl =
            'https://via.placeholder.com/150?text=${Uri.encodeComponent(productName)}';

        // Create product
        mockProducts.add(
          Product(
              id: productId,
              name: productName,
              category: category,
              price: price,
              quantity: quantity,
              imageUrl: imageUrl,
              barcode: _generateBarcode(),
              location: _locations[_random.nextInt(_locations.length)],
              supplier: _suppliers[_random.nextInt(_suppliers.length)],
              lastUpdated: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
              units: []),
        );
      }
    }

    return mockProducts;
  }

  // Get all products with pagination
  static Future<List<Product>> getProducts({int page = 0, int pageSize = 20}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final startIndex = page * pageSize;
    final endIndex = min(startIndex + pageSize, products.length);

    if (startIndex >= products.length) {
      return [];
    }

    return products.sublist(startIndex, endIndex);
  }

  // Get filtered products
  static Future<List<Product>> searchProducts(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (query.isEmpty) {
      return products;
    }

    return products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase()) ||
          product.id.toLowerCase().contains(query.toLowerCase()) ||
          product.barcode.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get product by ID
  static Future<Product?> getProductById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get product by barcode
  static Future<Product?> getProductByBarcode(String barcode) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return products.firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  // Update product quantity
  static Future<bool> updateProductQuantity(String id, int newQuantity) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    try {
      final index = products.indexWhere((product) => product.id == id);
      if (index != -1) {
        products[index] = products[index].copyWith(
          quantity: newQuantity,
          lastUpdated: DateTime.now(),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get inventory items for counting (static method)
  static List<InventoryItem> _mockInventoryItems = [];

  // Initialize mock inventory items
  static void _initInventoryItems() {
    if (_mockInventoryItems.isEmpty) {
      _mockInventoryItems = [
        InventoryItem(
          id: '1',
          name: 'أرز بسمتي',
          primaryUnitCount: 100,
          secondaryUnitCount: 10,
          primaryUnit: 'كيلو',
          secondaryUnit: 'كرتون',
          price: 25.0,
        ),
        InventoryItem(
          id: '2',
          name: 'زيت طبخ',
          primaryUnitCount: 50,
          secondaryUnitCount: 5,
          primaryUnit: 'لتر',
          secondaryUnit: 'كرتون',
          price: 35.0,
        ),
        InventoryItem(
          id: '3',
          name: 'سكر',
          primaryUnitCount: 200,
          secondaryUnitCount: 20,
          primaryUnit: 'كيلو',
          secondaryUnit: 'كرتون',
          price: 15.0,
        ),
        InventoryItem(
          id: '4',
          name: 'معكرونة',
          primaryUnitCount: 75,
          secondaryUnitCount: 3,
          primaryUnit: 'كيس',
          secondaryUnit: 'كرتون',
          price: 40.0,
        ),
        InventoryItem(
          id: '5',
          name: 'حليب',
          primaryUnitCount: 150,
          secondaryUnitCount: 15,
          primaryUnit: 'علبة',
          secondaryUnit: 'كرتون',
          price: 30.0,
        ),
      ];
    }
  }

  // Get inventory items for counting
  Future<List<InventoryItem>> getInventoryItems() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Initialize inventory items if needed
    _initInventoryItems();

    return _mockInventoryItems;
  }

  // Save updated inventory counts
  static Future<bool> saveInventoryCount(List<InventoryItem> items) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Update our mock items
    _mockInventoryItems = items;

    return true;
  }

  // Helper methods for generating mock data
  static String _generateProductName(int index) {
    final List<String> productNames = [
      'تلفزيون ذكي ${32 + (index % 20) * 2} بوصة',
      'هاتف ذكي جالاكسي ${index % 12 + 1}',
      'مكنسة كهربائية فيليبس',
      'خلاط كهربائي براون',
      'غسالة أوتوماتيك سامسونج',
      'ثلاجة هيتاشي ${index % 4 + 1} باب',
      'مكواة بخارية فيليبس',
      'طابعة ليزر اتش بي',
      'مروحة سقف ${index % 5 + 1} شفرة',
      'ميكروويف سامسونج ${20 + index % 10} لتر',
      'سماعات بلوتوث سوني',
      'حقيبة لابتوب جلدية',
      'منظم مكتب خشبي',
      'دفتر ملاحظات فاخر',
      'طقم أكواب زجاجية ${6 + (index % 6) * 2} قطعة',
      'طقم أطباق بورسلين',
      'مصباح مكتب LED',
      'صندوق تخزين بلاستيك',
      'قلم حبر جاف أزرق',
      'كرسي مكتب دوار'
    ];

    return productNames[index % productNames.length];
  }

  static double _generatePrice() {
    // Generate price between 50 and 5000
    return (_random.nextInt(4950) + 50) / 1.0;
  }

  static String _generateBarcode() {
    // Generate a random 13-digit barcode
    String barcode = '5';
    for (int i = 0; i < 12; i++) {
      barcode += _random.nextInt(10).toString();
    }
    return barcode;
  }
}

// Mock sales invoice related models
class SalesInvoice {
  final String invoiceId;
  final DateTime date;
  final List<SalesItem> items;
  final String customerName;
  final String customerPhone;
  final PaymentMethod paymentMethod;
  final double taxRate;
  final double discount;
  final InvoiceStatus status;

  SalesInvoice({
    required this.invoiceId,
    required this.date,
    required this.items,
    required this.customerName,
    required this.customerPhone,
    required this.paymentMethod,
    required this.taxRate,
    required this.discount,
    required this.status,
  });

  // Calculate subtotal
  double get subtotal => items.fold(0, (sum, item) => sum + item.total);

  // Calculate tax amount
  double get taxAmount => subtotal * taxRate;

  // Calculate total with tax and discount
  double get total => subtotal + taxAmount - discount;
}

class SalesItem {
  final Product product;
  final int quantity;
  final double price;

  SalesItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  // Calculate total for this item
  double get total => price * quantity;

  // Add copyWith method
  SalesItem copyWith({
    Product? product,
    int? quantity,
    double? price,
  }) {
    return SalesItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}

enum PaymentMethod { cash, credit, bank }

enum InvoiceStatus { pending, completed, cancelled }

// Mock sales service
class SalesService {
  static final Random _random = Random();

  static final List<String> _customerNames = [
    'أحمد محمد',
    'سارة علي',
    'خالد عبدالله',
    'نورة السيد',
    'ياسر أحمد',
    'ليلى حسن',
    'عمر فاروق',
    'دينا كمال',
    'محمود سعيد',
    'هدى إبراهيم',
  ];

  static final List<String> _phoneNumbers = [
    '+966 50 123 4567',
    '+966 55 987 6543',
    '+966 53 456 7890',
    '+966 58 321 6547',
    '+966 59 741 2587',
  ];

  // Generate mock sales invoices
  static List<SalesInvoice> _generateMockInvoices() {
    List<SalesInvoice> invoices = [];

    for (int i = 0; i < 50; i++) {
      // Generate 1-10 items for each invoice
      final itemsCount = _random.nextInt(9) + 1;
      List<SalesItem> items = [];

      // Get random products for this invoice
      final allProducts = InventoryService.products;
      final selectedIndices = <int>[];

      while (selectedIndices.length < itemsCount) {
        final randomIndex = _random.nextInt(allProducts.length);
        if (!selectedIndices.contains(randomIndex)) {
          selectedIndices.add(randomIndex);

          // Create sales item from product
          final product = allProducts[randomIndex];
          items.add(SalesItem(
            product: product,
            quantity: _random.nextInt(5) + 1, // 1-5 quantity
            price: product.price,
          ));
        }
      }

      // Generate invoice with items
      invoices.add(SalesInvoice(
        invoiceId: 'INV-${2000 + i}',
        date: DateTime.now().subtract(Duration(days: _random.nextInt(60))),
        items: items,
        customerName: _customerNames[_random.nextInt(_customerNames.length)],
        customerPhone: _phoneNumbers[_random.nextInt(_phoneNumbers.length)],
        paymentMethod: PaymentMethod.values[_random.nextInt(PaymentMethod.values.length)],
        taxRate: 0.15, // 15% VAT
        discount: _random.nextInt(100) + 0.0,
        status: InvoiceStatus.values[_random.nextInt(InvoiceStatus.values.length)],
      ));
    }

    // Sort invoices by date (newest first)
    invoices.sort((a, b) => b.date.compareTo(a.date));
    return invoices;
  }

  // List of mock invoices
  static final List<SalesInvoice> _invoices = _generateMockInvoices();

  // Get all invoices with pagination
  static Future<List<SalesInvoice>> getInvoices({int page = 0, int pageSize = 20}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final startIndex = page * pageSize;
    final endIndex = min(startIndex + pageSize, _invoices.length);

    if (startIndex >= _invoices.length) {
      return [];
    }

    return _invoices.sublist(startIndex, endIndex);
  }

  // Get invoice by ID
  static Future<SalesInvoice?> getInvoiceById(String invoiceId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _invoices.firstWhere((invoice) => invoice.invoiceId == invoiceId);
    } catch (e) {
      return null;
    }
  }

  // Create new invoice
  static Future<SalesInvoice> createInvoice(List<SalesItem> items, String customerName,
      String customerPhone, PaymentMethod paymentMethod, double discount) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    // Create new invoice
    final newInvoice = SalesInvoice(
      invoiceId: 'INV-${2000 + _invoices.length + 1}',
      date: DateTime.now(),
      items: items,
      customerName: customerName,
      customerPhone: customerPhone,
      paymentMethod: paymentMethod,
      taxRate: 0.15, // 15% VAT
      discount: discount,
      status: InvoiceStatus.completed,
    );

    // Add to invoices list
    _invoices.insert(0, newInvoice);
    return newInvoice;
  }

  // Get payment method as string
  static String paymentMethodToString(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'نقدي';
      case PaymentMethod.credit:
        return 'آجل';
      case PaymentMethod.bank:
        return 'تحويل بنكي';
    }
  }

  // Get invoice status as string
  static String invoiceStatusToString(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.pending:
        return 'معلق';
      case InvoiceStatus.completed:
        return 'مكتمل';
      case InvoiceStatus.cancelled:
        return 'ملغي';
    }
  }

  // Get invoice status color
  static int invoiceStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.pending:
        return 0xFFFFA000; // Amber
      case InvoiceStatus.completed:
        return 0xFF4CAF50; // Green
      case InvoiceStatus.cancelled:
        return 0xFFF44336; // Red
    }
  }
}
