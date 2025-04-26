import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:promoter_app/core/constants/assets.dart';
import 'package:promoter_app/core/utils/utils.dart';
import 'package:promoter_app/core/view/widgets/image_loader.dart';
import 'package:promoter_app/features/client/screens/client_screen.dart';
import 'package:promoter_app/features/inventory/screens/inventory_screen.dart';
import 'package:promoter_app/features/inventory/screens/product_inquiry_screen.dart';
import 'package:promoter_app/features/inventory/screens/sales_invoice_screen.dart';
import 'package:promoter_app/features/inventory/screens/sales_report_screen.dart';
import 'package:promoter_app/features/salary/screens/salary_screen.dart';
import 'package:promoter_app/features/tools/scanner/scanner_screen.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../menu/menu_screen.dart';
import '../scanning/scanning_inquiry_screen.dart';

class ZoomDrawerScreen extends StatelessWidget {
  static final ZoomDrawerController _drawerController = ZoomDrawerController();

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _drawerController,
      openCurve: Curves.fastOutSlowIn,
      showShadow: false,
      slideWidth: .7.sw,
      // isRtl: !ltr,
      mainScreenTapClose: true,
      borderRadius: 36.r,
      angle: 0.0,
      menuScreenWidth: double.infinity,
      moveMenuScreen: false,
      // drawerShadowsBackgroundColor: CustomTheme.primary.background,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).primaryColor,
          spreadRadius: 0,
          blurRadius: 0,
          offset: const Offset(0, 0),
        ),
        BoxShadow(
          color: Theme.of(context).primaryColor,
          spreadRadius: 0,
          blurRadius: 0,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Theme.of(context).primaryColor,
          spreadRadius: 0,
          blurRadius: 0,
          offset: const Offset(0, -2),
        ),
        BoxShadow(
          color: Theme.of(context).primaryColor,
          spreadRadius: 0,
          blurRadius: 0,
          offset: const Offset(-2, 0),
        ),
        BoxShadow(
          color: Theme.of(context).primaryColor,
          spreadRadius: 0,
          blurRadius: 0,
          offset: const Offset(2, 0),
        ),
      ],
      menuScreen: MenuScreen(),
      mainScreen: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'مرحبًا كريم',
          style: TextStyle(color: Colors.black, fontSize: 18),
        )
            // Animating the title with extended duration.
            .animate()
            .fade(duration: 1000.ms)
            .slide(begin: const Offset(0, -40), end: Offset.zero),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            ZoomDrawerScreen._drawerController.toggle!();
          },
        )
            .animate()
            .fadeIn(duration: 1000.ms)
            .slide(begin: const Offset(-40, 0), end: Offset.zero)
            .scale(duration: 1000.ms),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animate the row container for gauge and debt card with slower animations.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircularPercentIndicator()
                    .animate()
                    .fade(duration: 1000.ms)
                    .slide(begin: const Offset(-50, 0), end: Offset.zero),
                const DebtCard()
                    .animate()
                    .fade(duration: 1000.ms, delay: 150.ms)
                    .slide(begin: const Offset(50, 0), end: Offset.zero),
              ],
            ).animate().scale(duration: 1000.ms),
            const SizedBox(height: 20),
            const FeatureGrid()
                .animate()
                .fade(duration: 1000.ms, delay: 200.ms),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 1200.ms);
  }
}

class CircularPercentIndicator extends StatelessWidget {
  const CircularPercentIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: .3.sw,
      height: .2.sh,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            showLabels: false,
            showTicks: false,
            startAngle: 270,
            endAngle: 270,
            radiusFactor: 0.8,
            axisLineStyle: const AxisLineStyle(
              thicknessUnit: GaugeSizeUnit.factor,
              thickness: 0.15,
            ),
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                angle: 180,
                widget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '9.99%',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            pointers: const <GaugePointer>[
              RangePointer(
                value: 50,
                cornerStyle: CornerStyle.bothCurve,
                enableAnimation: true,
                animationDuration: 1500,
                sizeUnit: GaugeSizeUnit.factor,
                gradient: SweepGradient(
                  colors: <Color>[Color(0xFF6A6EF6), Color(0xFFDB82F5)],
                  stops: <double>[0.25, 0.75],
                ),
                color: Color(0xFF00A8B5),
                width: 0.15,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DebtCard extends StatelessWidget {
  const DebtCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'إجمالي الديون',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            '1690.0',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a list of features with title, icon, and action.
    final List<Map<String, dynamic>> features = [
      {
        'title': 'جدول المبيعات',
        'icon': Icons.bar_chart,
        'anim': Assets.invoiceLottie,
        'color': Colors.blue.shade700,
        'action': () {
          print('جدول المبيعات tapped');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalesReportScreen()),
          );
        },
      },
      {
        'title': 'فاتورة مبيعات',
        'icon': Icons.receipt,
        'anim': Assets.singleInvoiceLottie,
        'color': Colors.green.shade700,
        'action': () {
          print('فاتورة مبيعات tapped');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalesInvoiceScreen()),
          );
        },
      },
      {
        'title': 'الجرد',
        'icon': Icons.inventory,
        'anim': Assets.warehouseLottie,
        'color': Colors.purple.shade700,
        'action': () {
          print('الجرد tapped');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InventoryScreen()),
          );
        },
      },
      {
        'title': 'استعلام عن صنف',
        'icon': Icons.search,
        'anim': Assets.scanLottie,
        'color': Colors.orange.shade700,
        'action': () {
          print('استعلام عن صنف tapped');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductInquiryScreen()),
          );
        },
      },
      {
        'title': 'سند عميل',
        'icon': Icons.person_outline,
        'anim': Assets.profileLottie,
        'color': Colors.cyan.shade700,
        'action': () {
          print('سند عميل tapped');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClientScreen()),
          );
        },
      },
      {
        'title': 'سند مصروف',
        'icon': Icons.payment,
        'anim': Assets.singleInvoiceLottie,
        'color': Colors.pink.shade700,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('سند مصروف')),
          );
        },
      },
      {
        'title': 'تحويل للمخازن',
        'icon': Icons.swap_horiz,
        'anim': Assets.warehouseLottie,
        'color': Colors.teal.shade700,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تحويل للمخازن')),
          );
        },
      },
      {
        'title': 'جدول تحويلات المخازن',
        'icon': Icons.table_chart,
        'anim': Assets.invoiceLottie,
        'color': Colors.amber.shade700,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('جدول تحويلات المخازن')),
          );
        },
      },
      {
        'title': 'كميات المخازن',
        'icon': Icons.storage,
        'anim': Assets.warehouseLottie,
        'color': Colors.indigo.shade700,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('كميات المخازن')),
          );
        },
      },
      {
        'title': 'عرض سعر',
        'icon': Icons.price_check,
        'anim': Assets.singleInvoiceLottie,
        'color': Colors.deepOrange.shade700,
        'action': () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('عرض سعر')),
          );
        },
      },
      {
        'title': 'العميل',
        'icon': Icons.person,
        'anim': Assets.profileLottie,
        'color': Colors.blue.shade700,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClientScreen()),
          );
        },
      },
      {
        'title': 'المرتب',
        'icon': Icons.attach_money,
        'anim': Assets.invoiceLottie,
        'color': Colors.green.shade700,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalaryScreen()),
          );
        },
      },
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0,
      children: [
        for (var index = 0; index < features.length; index++)
          InkWell(
            onTap: features[index]['action'] as VoidCallback,
            child: FeatureCard(
              action: features[index]['action'] as VoidCallback,
              anim: features[index].containsKey('anim')
                  ? features[index]['anim'] as String
                  : null,
              title: features[index]['title'] as String,
              icon: features[index]['icon'] as IconData,
              color: features[index].containsKey('color')
                  ? features[index]['color'] as Color
                  : null,
            )
                // Each feature card animates in with a slower fade and slide.
                .animate(delay: Duration(milliseconds: (index * 120)))
                .fade(duration: 800.ms)
                .slide(begin: const Offset(0, 40), end: Offset.zero),
          ),
      ],
    );
  }
}

class FeatureCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String? anim;
  final Color? color;
  final VoidCallback? action;

  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    this.anim,
    this.color,
    this.action,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = widget.color ?? Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () {
        widget.action?.call();
      },
      // onTapDown: (_) {
      //   setState(() {
      //     _isHovered = true;
      //     _controller.forward();
      //   });
      // },
      // onTapUp: (_) {
      //   setState(() {
      //     _isHovered = false;
      //     _controller.reverse();
      //   });
      // },
      // onTapCancel: () {
      //   setState(() {
      //     _isHovered = false;
      //     _controller.reverse();
      //   });
      // },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_controller.value * 0.05),
            child: child,
          );
        },
        child: Container(
          width: .41.sw,
          height: .23.sh,
          margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
            elevation: _isHovered ? 5 : 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isHovered
                      ? [buttonColor, buttonColor.withOpacity(0.8)]
                      : [Colors.white, Colors.white],
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: buttonColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              padding: EdgeInsets.all(16.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: (widget.anim != null)
                        ? ImageLoader(
                            path: widget.anim!,
                            repeated: true,
                          )
                        : Icon(
                            widget.icon is IconData
                                ? widget.icon as IconData
                                : Icons.circle,
                            size: 40,
                            color: _isHovered ? Colors.white : buttonColor,
                          ),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: _isHovered ? Colors.white : buttonColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'مرحبًا كريم',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            ZoomDrawer.of(context)!.toggle();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircularPercentIndicator(),
                DebtCard(),
              ],
            ),
            const SizedBox(height: 20),
            FeatureGrid(),
          ],
        ),
      ),
    );
  }
}

class CircularPercentIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: .3.sw,
      height: .2.sh,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            showLabels: false,
            showTicks: false,
            startAngle: 270,
            endAngle: 270,
            radiusFactor: 0.8,
            axisLineStyle: const AxisLineStyle(
              thicknessUnit: GaugeSizeUnit.factor,
              thickness: 0.15,
            ),
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                angle: 180,
                widget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '9.99%',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            pointers: const <GaugePointer>[
              RangePointer(
                value: 50,
                cornerStyle: CornerStyle.bothCurve,
                enableAnimation: true,
                animationDuration: 1200,
                sizeUnit: GaugeSizeUnit.factor,
                gradient: SweepGradient(
                  colors: <Color>[Color(0xFF6A6EF6), Color(0xFFDB82F5)],
                  stops: <double>[0.25, 0.75],
                ),
                color: Color(0xFF00A8B5),
                width: 0.15,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DebtCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        children: [
          Text(
            'إجمالي الديون',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            '1690.0',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

class FeatureGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define a list of features with title, icon, and action
    final List<Map<String, dynamic>> features = [
      {
        'title': 'جدول المبيعات',
        'icon': '📄',
        'action': () {
          print('جدول المبيعات tapped');
          // Add your action logic here
        },
      },
      {
        'title': 'فاتورة مبيعات',
        'icon': '✏️',
        'action': () {
          print('فاتورة مبيعات tapped');
          // Add your action logic here
        },
      },
      {
        'title': 'الجرد',
        'icon': '📏',
        'action': () {
          print('الجرد tapped');
          Navigator.push(context, MaterialPageRoute(builder: (_) => ScanningInquiryScreen()));
        },
      },
      {
        'title': 'استعلام عن صنف',
        'icon': '🔍',
        'action': () {
          print('استعلام عن صنف tapped');
        },
        'anim': Assets.scanLottie,
      },
      {
        'title': 'سند عميل',
        'icon': '📄',
        'action': () {},
      },
      {
        'title': 'سند مصروف',
        'icon': '📄',
        'action': () {},
      },
      {
        'title': 'تحويل للمخازن',
        'icon': '📄',
        'action': () {},
      },
      {
        'title': 'جدول تحويلات المخازن',
        'icon': '📄',
        'action': () {},
      },
      {
        'title': 'كميات المخازن',
        'icon': '📄',
        'action': () {},
      },
      {
        'title': 'عرض سعر',
        'icon': '📄',
        'action': () {},
      },
      {
        'title': 'العميل',
        'icon': '📄',
        'action': () {},
      },
      {
        'title': 'المرتب',
        'icon': '📄',
        'action': () {},
      },
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int index = 0; index < features.length; index++)
          InkWell(
            onTap: features[index]['action'] as VoidCallback,
            child: FeatureCard(
              anim: features[index].keys.contains('anim') ? features[index]['anim'] as String : null,
              title: features[index]['title'] as String,
              icon: features[index]['icon'] as String,
            ),
          ),
      ],
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String icon;
  final String? anim;

  const FeatureCard({super.key, required this.title, required this.icon, this.anim});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: .4.sw,
      height: .2.sh,
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: (anim != null)
                      ? ImageLoader(
                          path: anim!,
                          repeated: true,
                        )
                      : Text(icon, style: const TextStyle(fontSize: 30))),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
