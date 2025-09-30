import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/features/tools/scanner/generator_screen.dart';
import 'package:url_launcher/url_launcher.dart';

// Dummy data classes
class Product {
  final String id;
  final String image;
  final String name;
  final String expirationDate;
  final String description;
  final String? supplierImage;
  final String supplierId;
  final String? link;
  final List<ProductValue> values;

  Product({
    required this.id,
    required this.image,
    required this.name,
    required this.expirationDate,
    required this.description,
    this.supplierImage,
    required this.supplierId,
    this.link,
    required this.values,
  });
}

class ProductValue {
  final String key;
  final String value;

  ProductValue({required this.key, required this.value});
}

class Supplier {
  final String id;
  final String name;
  final String description;

  Supplier({required this.id, required this.name, required this.description});
}

// Dummy data
final dummyProduct = Product(
  id: '1',
  image: 'https://via.placeholder.com/150',
  name: 'Sample Product',
  expirationDate: '2024-12-31',
  description:
      'This is a sample product description. It contains detailed information about the product features and specifications.',
  supplierId: 'supplier_1',
  link: 'www.example.com',
  values: [
    ProductValue(key: 'Weight', value: '500g'),
    ProductValue(key: 'Color', value: 'Red'),
    ProductValue(key: 'Material', value: 'Plastic'),
  ],
);

final dummySupplier = Supplier(
  id: 'supplier_1',
  name: 'Sample Supplier Company',
  description: 'Leading supplier of quality products since 2020',
);

class ProductDetailsScreen extends StatelessWidget {
  final String productId;
  final String qrCode;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    required this.qrCode,
  });

  @override
  Widget build(BuildContext context) {
    return _OriginalProductScreen(qrCode: qrCode);
  }
}

class _OriginalProductScreen extends StatefulWidget {
  final String qrCode;

  const _OriginalProductScreen({super.key, required this.qrCode});

  @override
  State<_OriginalProductScreen> createState() => _OriginalProductScreenState();
}

class _OriginalProductScreenState extends State<_OriginalProductScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabBarController;
  final Product product = dummyProduct;
  final Supplier supplier = dummySupplier;

  @override
  void initState() {
    tabBarController = TabController(length: 2, vsync: this);
    super.initState();
  }

  void _launchURL(String url) async {
    SoundManager().playClickSound();
    if (!url.startsWith('http')) url = 'https://$url';
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  void dispose() {
    tabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(24.h),
        child: OutlinedButton(
          onPressed: () {
            SoundManager().playClickSound();
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFF148ccd),
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
          ),
          child: const Text('اضافة إلي المخزن'),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 100.w,
                      height: 100.h,
                      child: GeneratorScreen(code: widget.qrCode),
                    ),
                  ),
                  if (widget.qrCode == "INNER")
                    Positioned(
                      left: 80.w,
                      top: 20.h,
                      child: const Icon(Icons.qr_code, size: 35),
                    ),
                ],
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(width: 70.w),
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 30.w),
                      InkWell(
                        onTap: () => _launchURL(product.link ?? ''),
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF148ccd),
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: const Icon(Icons.link, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TabBar(
                controller: tabBarController,
                indicatorWeight: 1.h,
                tabs: const [
                  Tab(text: 'Description'),
                  Tab(text: 'About Company'),
                ],
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 500.h,
                child: TabBarView(
                  controller: tabBarController,
                  children: [
                    _buildProductDescription(),
                    _buildCompanyInfo(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          _buildInfoRow('Brand', product.name),
          SizedBox(height: 16.h),
          _buildInfoRow('Validity', 'Expiry: ${product.expirationDate}'),
          SizedBox(height: 16.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey[200],
            ),
            padding: EdgeInsets.all(10.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  product.description,
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(height: 15.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: product.values.length,
                  itemBuilder: (context, index) => _buildValueItem(product.values[index]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Padding(
      padding: EdgeInsets.all(16.sp),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.grey[200],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Company Details:",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Name: ${supplier.name}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                supplier.description,
                style: TextStyle(fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: EdgeInsets.all(8.sp),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          if (label == 'Brand')
            CircleAvatar(
              radius: 15.r,
              backgroundImage:
                  NetworkImage(product.supplierImage ?? 'https://via.placeholder.com/150'),
            ),
        ],
      ),
    );
  }

  Widget _buildValueItem(ProductValue value) {
    return Container(
      width: double.infinity,
      height: 40.h,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value.key,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          Text(
            value.value,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
