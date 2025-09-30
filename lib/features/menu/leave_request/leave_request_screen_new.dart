import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:promoter_app/core/utils/sound_manager.dart';
import 'package:promoter_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:promoter_app/features/auth/data/models/user_model.dart';
import 'package:provider/provider.dart';

import '../../../core/di/injection_container.dart';
import 'controllers/leave_request_controller.dart';
import 'models/leave_request_model.dart';
import 'providers/leave_request_provider.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  String _leaveType = 'إجازة سنوية';
  final TextEditingController _reasonController = TextEditingController();
  late final LeaveRequestProvider _leaveRequestProvider;
  bool _isSubmitting = false;

  final List<String> _leaveTypes = [
    'إجازة سنوية',
    'إجازة مرضية',
    'إجازة طارئة',
    'إجازة بدون راتب',
    'أخرى',
  ];
  UserModel? user;
  @override
  void initState() {
    super.initState();
    loadUser();
    // Initialize the provider
    _leaveRequestProvider = LeaveRequestProvider(
      leaveRequestController: sl<LeaveRequestController>(),
    );
  }

  loadUser() async {
    user = await sl<AuthLocalDataSource>().getLastUser();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _leaveRequestProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلب إجازة', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFF148ccd),
        ),
        body: SafeArea(
          child: Consumer<LeaveRequestProvider>(
            builder: (context, provider, _) {
              if (provider.status == LoadingStatus.loading && provider.leaveRequests.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.status == LoadingStatus.error && provider.leaveRequests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('حدث خطأ أثناء تحميل البيانات'),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          SoundManager().playClickSound();
                          provider.fetchLeaveRequests();
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _buildSectionTitle('معلومات الإجازة'),
                      SizedBox(height: 16.h),
                      _buildLeaveTypeDropdown(),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePicker(
                              'تاريخ البدء',
                              _startDate,
                              _selectStartDate,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildDatePicker(
                              'تاريخ الانتهاء',
                              _endDate,
                              _selectEndDate,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      _buildSectionTitle('سبب الإجازة'),
                      SizedBox(height: 16.h),
                      _buildReasonField(),
                      SizedBox(height: 32.h),
                      _buildSubmitButton(provider),
                      SizedBox(height: 16.h),
                      _buildLeaveHistory(provider),
                    ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slide(
                        begin: const Offset(0, 0.5),
                        end: const Offset(0, 0),
                        duration: 300.ms,
                        curve: Curves.easeOut),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildLeaveTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'نوع الإجازة',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      value: _leaveType,
      items: _leaveTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _leaveType = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء اختيار نوع الإجازة';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function() onTap) {
    return InkWell(
      onTap: () {
        onTap();
        SoundManager().playClickSound();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              date == null ? 'اختر التاريخ' : '${date.day}/${date.month}/${date.year}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: date == null ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: _reasonController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'اكتب سبب طلب الإجازة هنا...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.all(16.w),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء كتابة سبب الإجازة';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(LeaveRequestProvider provider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: provider.isSubmitting ? null : () => _submitLeaveRequest(provider),
            child: provider.isSubmitting
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'تقديم الطلب',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
            onPressed: _printLeaveRequest,
            icon: Icon(Icons.print, color: Theme.of(context).primaryColor),
            label: Text(
              'طباعة طلب الإجازة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveHistory(LeaveRequestProvider provider) {
    final leaveRequests = provider.leaveRequests;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سجل الإجازات السابقة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (provider.status == LoadingStatus.loaded ||
                    provider.status == LoadingStatus.error)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      SoundManager().playClickSound();
                      provider.fetchLeaveRequests();
                    },
                    tooltip: 'تحديث',
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            if (provider.status == LoadingStatus.loading && leaveRequests.isNotEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const CircularProgressIndicator(),
                ),
              )
            else if (leaveRequests.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'لا توجد إجازات سابقة',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              )
            else
              ...leaveRequests.map((request) => _buildLeaveHistoryItemFromRequest(request)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveHistoryItemFromRequest(LeaveRequest request) {
    Color statusColor;
    String statusText;

    switch (request.status) {
      case LeaveStatus.approved:
        statusColor = Colors.green;
        statusText = 'تمت الموافقة';
        break;
      case LeaveStatus.rejected:
        statusColor = Colors.red;
        statusText = 'مرفوضة';
        break;
      case LeaveStatus.pending:
        statusColor = Colors.orange;
        statusText = 'قيد الانتظار';
        break;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.leaveType,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  request.dateRangeString,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, reset end date
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  void _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _submitLeaveRequest(LeaveRequestProvider provider) async {
    SoundManager().playClickSound();
    if (_formKey.currentState!.validate()) {
      if (_startDate == null) {
        _showErrorMessage('الرجاء اختيار تاريخ البدء');
        return;
      }
      if (_endDate == null) {
        _showErrorMessage('الرجاء اختيار تاريخ الانتهاء');
        return;
      }

      // Set submitting state
      setState(() {
        _isSubmitting = true;
      });

      // Submit the leave request
      final success = await provider.submitLeaveRequest(
        leaveType: _leaveType,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text,
      );

      // Reset submitting state
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        _showSuccessMessage('تم تقديم طلب الإجازة بنجاح');
        // Reset form
        setState(() {
          _startDate = null;
          _endDate = null;
          _leaveType = 'إجازة سنوية';
          _reasonController.clear();
        });
      } else {
        _showErrorMessage(provider.errorMessage ?? 'حدث خطأ أثناء تقديم الطلب');
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _printLeaveRequest() async {
    SoundManager().playClickSound();
    if (_startDate == null || _endDate == null) {
      _showErrorMessage('الرجاء إكمال بيانات الإجازة قبل الطباعة');
      return;
    }

    final pdfDocument = await _generateLeaveRequestPdf();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfDocument,
      name: 'طلب_إجازة_${DateFormat('yyyy_MM_dd').format(DateTime.now())}',
    );
  }

  Future<Uint8List> _generateLeaveRequestPdf() async {
    final pdf = pw.Document();

    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    // Calculate the number of days between start and end date
    final difference = _endDate!.difference(_startDate!).inDays + 1;

    // Improved Arabic text handling function
    String processArabicText(String text) {
      // Remove the string reversal - let the PDF library handle Arabic properly
      // The key is to use proper RTL directionality and appropriate fonts
      return text;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl, // Changed to RTL for proper Arabic rendering
            child: pw.Container(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start, // Changed to start for RTL
                children: [
                  // Header with logo and title
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end, // Swapped for RTL
                        children: [
                          pw.Text(
                            'طلب إجازة',
                            style: pw.TextStyle(
                              font: arabicFontBold,
                              fontSize: 24,
                              color: PdfColors.indigo900,
                            ),
                            textDirection: pw.TextDirection.rtl,
                          ),
                          pw.Text(
                            'آل الياسين للتجارة والتوزيع',
                            style: pw.TextStyle(font: arabicFont, fontSize: 14),
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start, // Swapped for RTL
                        children: [
                          pw.Text(
                            'رقم الطلب: ${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                            style: pw.TextStyle(font: arabicFont, fontSize: 10),
                            textDirection: pw.TextDirection.rtl,
                          ),
                          pw.Text(
                            'التاريخ: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
                            style: pw.TextStyle(font: arabicFont, fontSize: 10),
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 40),

                  // Employee information
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'معلومات الموظف',
                          style: pw.TextStyle(font: arabicFontBold, fontSize: 16),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'اسم الموظف:',
                              style: pw.TextStyle(font: arabicFontBold),
                              textDirection: pw.TextDirection.rtl,
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              user?.name ?? '',
                              style: pw.TextStyle(font: arabicFont),
                              textDirection: pw.TextDirection.rtl,
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'رقم الموظف:',
                              style: pw.TextStyle(font: arabicFontBold),
                              textDirection: pw.TextDirection.rtl,
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              user?.id.toString() ?? '',
                              style: pw.TextStyle(font: arabicFont),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'المسمى الوظيفي:',
                              style: pw.TextStyle(font: arabicFontBold),
                              textDirection: pw.TextDirection.rtl,
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              user?.role ?? '',
                              style: pw.TextStyle(font: arabicFont),
                              textDirection: pw.TextDirection.rtl,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Leave information
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'تفاصيل الإجازة',
                          style: pw.TextStyle(font: arabicFontBold, fontSize: 16),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'نوع الإجازة:',
                              style: pw.TextStyle(font: arabicFontBold),
                              textDirection: pw.TextDirection.rtl,
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              _leaveType,
                              style: pw.TextStyle(font: arabicFont),
                              textDirection: pw.TextDirection.rtl,
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'تاريخ البدء:',
                              style: pw.TextStyle(font: arabicFontBold),
                              textDirection: pw.TextDirection.rtl,
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                              style: pw.TextStyle(font: arabicFont),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'تاريخ الانتهاء:',
                              style: pw.TextStyle(font: arabicFontBold),
                              textDirection: pw.TextDirection.rtl,
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                              style: pw.TextStyle(font: arabicFont),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text(
                              'عدد الأيام:',
                              style: pw.TextStyle(font: arabicFontBold),
                              textDirection: pw.TextDirection.rtl,
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              '$difference يوم',
                              style: pw.TextStyle(font: arabicFont),
                              textDirection: pw.TextDirection.rtl,
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'سبب الإجازة:',
                          style: pw.TextStyle(font: arabicFontBold),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          width: double.infinity,
                          child: pw.Text(
                            _reasonController.text.isEmpty ? 'لا يوجد' : _reasonController.text,
                            style: pw.TextStyle(font: arabicFont),
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 40),

                  // Signature spaces
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 150,
                            height: 70,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(bottom: pw.BorderSide(width: 1)),
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'توقيع الموظف',
                            style: pw.TextStyle(font: arabicFontBold),
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 150,
                            height: 70,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(bottom: pw.BorderSide(width: 1)),
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'المدير المباشر',
                            style: pw.TextStyle(font: arabicFontBold),
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.Spacer(),

                  // Footer
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(vertical: 10),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(width: 1, color: PdfColors.grey300)),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'آل الياسين للتجارة والتوزيع',
                          style: pw.TextStyle(font: arabicFont, fontSize: 10),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.Text(
                          'تمت الطباعة بتاريخ: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
                          style: pw.TextStyle(font: arabicFont, fontSize: 10),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
