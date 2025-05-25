import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:promoter_app/core/constants/assets.dart';
import 'package:promoter_app/core/constants/strings.dart';
import 'package:promoter_app/core/di/injection_container.dart';
import 'package:promoter_app/core/view/widgets/image_loader.dart';
import 'package:promoter_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:promoter_app/features/client/screens/enhanced_client_screen_new.dart';
import 'package:promoter_app/features/collection/screens/collection_screen.dart'; // Added import
import 'package:promoter_app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:promoter_app/features/inventory/screens/inventory_screen.dart';
import 'package:promoter_app/features/inventory/screens/product_inquiry_screen.dart';
import 'package:promoter_app/features/inventory/screens/sales_invoice_screen.dart';
import 'package:promoter_app/features/inventory/screens/warehouse_transfer_screen.dart';
import 'package:promoter_app/features/returns/screens/return_transaction_screen.dart';
import 'package:promoter_app/features/salary/screens/salary_screen.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../collection/cubit/collection_cubit.dart';
import '../menu/menu_screen.dart';

class ZoomDrawerScreen extends StatelessWidget {
  static final ZoomDrawerController _drawerController = ZoomDrawerController();

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _drawerController,
      openCurve: Curves.fastOutSlowIn,
      showShadow: false,
      slideWidth: .7.sw,
      isRtl: Directionality.of(context) == TextDirection.rtl,
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
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String userName = 'مرحبًا';
            if (state is AuthAuthenticated) {
              userName = 'مرحبًا ${state.user.name}';
            }
            return Text(
              userName,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            );
          },
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
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularPercentIndicator()
                      .animate()
                      .fade(duration: 1000.ms)
                      .slide(begin: const Offset(-50, 0), end: Offset.zero),
                  const SizedBox(width: 20),
                  const DebtCard()
                      .animate()
                      .fade(duration: 1000.ms, delay: 150.ms)
                      .slide(begin: const Offset(50, 0), end: Offset.zero),
                ],
              ).animate().scale(duration: 1000.ms),
            ),
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

class CircularPercentIndicator extends StatefulWidget {
  const CircularPercentIndicator({super.key});

  @override
  State<CircularPercentIndicator> createState() =>
      _CircularPercentIndicatorState();
}

class _CircularPercentIndicatorState extends State<CircularPercentIndicator> {
  bool _isLoading = true;
  double _completionPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCompletionPercentage();
  }

  Future<void> _fetchCompletionPercentage() async {
    try {
      final dashboardController = sl<DashboardController>();
      final dashboardInfo = await dashboardController.getDashboardInfo();

      if (mounted) {
        setState(() {
          // Calculate completion percentage based on current debt vs target debt
          // If target is 0, set percentage to 0 to avoid division by zero
          if (dashboardInfo.completionPercentage > 0) {
            _completionPercentage =
                (dashboardInfo.totalDebt / dashboardInfo.completionPercentage) *
                    100;
            // Limit to 100% maximum
            _completionPercentage =
                _completionPercentage > 100 ? 100 : _completionPercentage;
          } else {
            _completionPercentage = 0;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _completionPercentage = 0.0;
          _isLoading = false;
        });
      }
      print('Error fetching completion percentage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: .3.sw,
      height: .2.sh,
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SfRadialGauge(
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
                            '${_completionPercentage.toStringAsFixed(2)}%',
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
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: _completionPercentage,
                      cornerStyle: CornerStyle.bothCurve,
                      enableAnimation: true,
                      animationDuration: 1500,
                      sizeUnit: GaugeSizeUnit.factor,
                      gradient: const SweepGradient(
                        colors: <Color>[Color(0xFF6A6EF6), Color(0xFFDB82F5)],
                        stops: <double>[0.25, 0.75],
                      ),
                      color: const Color(0xFF00A8B5),
                      width: 0.15,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class DebtCard extends StatefulWidget {
  const DebtCard({super.key});

  @override
  State<DebtCard> createState() => _DebtCardState();
}

class _DebtCardState extends State<DebtCard> {
  bool _isLoading = true;
  String _totalDebt = '0.0';
  String _currencySymbol = Strings.CURRENCY;

  @override
  void initState() {
    super.initState();
    _fetchDebtInfo();
  }

  Future<void> _fetchDebtInfo() async {
    try {
      final dashboardController = sl<DashboardController>();
      final dashboardInfo = await dashboardController.getDashboardInfo();

      if (mounted) {
        setState(() {
          _totalDebt = dashboardInfo.totalDebt.toStringAsFixed(2);
          _currencySymbol = dashboardInfo.currencySymbol;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _totalDebt = '0.0';
          _isLoading = false;
        });
      }
      print('Error fetching debt info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'إجمالي الديون',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          if (_isLoading)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          else
            Text(
              '$_totalDebt $_currencySymbol',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
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
        'title': 'فاتورة مبيعات',
        'icon': Icons.receipt,
        'anim': Assets.singleInvoiceLottie,
        'color': Colors.blue.shade700,
        'action': () {
          print('فاتورة مبيعات tapped');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalesInvoiceScreen()),
          );
        },
      },
      {
        'title': 'العملاء',
        'icon': Icons.person,
        'anim': Assets.profileLottie,
        'color': Colors.blue.shade700,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EnhancedClientScreen()),
          );
        },
      },
      {
        'title': 'تحصيل',
        'icon': Icons.payments,
        'anim': Assets.singleInvoiceLottie,
        'color': Colors.blue.shade700,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BlocProvider(
                    create: (context) => sl<CollectionCubit>(),
                    child: const CollectionScreen())), // Updated navigation
          );
        },
      },
      {
        'title': 'صرف',
        'icon': Icons.payment,
        'anim': Assets.singleInvoiceLottie,
        'color': Colors.blue.shade700,
        'action': () {
          // TODO: Create a disbursement screen and update the navigation
          // For now, showing a SnackBar message

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalaryScreen()),
          );
        },
      },
      {
        'title': 'الخزينة',
        'icon': Icons.account_balance_wallet,
        'anim': Assets.invoiceLottie,
        'color': Colors.blue.shade700,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InventoryScreen()),
          );
        },
      },
      {
        'title': 'تسجيل مرتجع',
        'icon': Icons.assignment_return,
        'anim': Assets.invoiceLottie,
        'color': Colors.blue.shade700,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReturnTransactionScreen()),
          );
        },
      },
      {
        'title': 'المنتجات',
        'icon': Icons.inventory_2,
        'anim': Assets.scanLottie,
        'color': Colors.blue.shade700,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductInquiryScreen()),
          );
        },
      },
      {
        'title': 'تحويل مخزون',
        'icon': Icons.swap_horiz,
        'anim': Assets.warehouseLottie,
        'color': Colors.blue.shade700,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WarehouseTransferScreen()),
          );
        },
      },
    ];

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0.w,
        children: [
          for (var index = 0; index < features.length; index++)
            FeatureCard(
              action: features[index]['action'] as VoidCallback,
              anim: features[index].containsKey('anim')
                  ? features[index]['anim'] as String
                  : null,
              title: features[index]['title'] as String,
              icon: features[index]['icon'] as IconData,
              color: features[index]['color'] as Color,
              withBorder: true,
            )
                // Each feature card animates in with a slower fade and slide.
                .animate(delay: Duration(milliseconds: (index * 120)))
                .fade(duration: 800.ms)
                .slide(begin: const Offset(0, 40), end: Offset.zero),
        ],
      ),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String? anim;
  final Color? color;
  final VoidCallback? action;
  final bool withBorder;

  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    this.anim,
    this.color,
    this.action,
    this.withBorder = false,
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
        onTapDown: (_) {
          setState(() {
            _isHovered = true;
            _controller.forward();
          });
        },
        onTapUp: (_) {
          setState(() {
            _isHovered = false;
            _controller.reverse();
          });
        },
        onTapCancel: () {
          setState(() {
            _isHovered = false;
            _controller.reverse();
          });
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - (_controller.value * 0.05),
              child: child,
            );
          },
          child: Container(
            width: .4.sw,
            height: .23.sh,
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
                side: widget.withBorder
                    ? BorderSide(color: Colors.blueAccent, width: 1.5)
                    : BorderSide.none,
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
                              fit: BoxFit.contain,
                              height: 60.h,
                              width: 60.w,
                            )
                          : Icon(
                              widget.icon,
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
        ));
  }
}
