import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({Key? key}) : super(key: key);

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  String _leaveType = 'إجازة سنوية';
  final TextEditingController _reasonController = TextEditingController();

  final List<String> _leaveTypes = [
    'إجازة سنوية',
    'إجازة مرضية',
    'إجازة طارئة',
    'إجازة بدون راتب',
    'أخرى',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('طلب إجازة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                              'تاريخ البدء', _startDate, _selectStartDate)),
                      SizedBox(width: 16.w),
                      Expanded(
                          child: _buildDatePicker(
                              'تاريخ الانتهاء', _endDate, _selectEndDate)),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('سبب الإجازة'),
                  SizedBox(height: 16.h),
                  _buildReasonField(),
                  SizedBox(height: 32.h),
                  _buildSubmitButton(),
                  SizedBox(height: 16.h),
                  _buildLeaveHistory(),
                ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slide(
                    begin: Offset(0, 0.5),
                    end: Offset(0, 0),
                    duration: 300.ms,
                    curve: Curves.easeOut)),
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
      onTap: onTap,
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
              date == null
                  ? 'اختر التاريخ'
                  : '${date.day}/${date.month}/${date.year}',
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

  Widget _buildSubmitButton() {
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
            onPressed: _submitLeaveRequest,
            child: Text(
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

  Widget _buildLeaveHistory() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سجل الإجازات السابقة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            _buildLeaveHistoryItem(
              '10/03/2025 - 15/03/2025',
              'إجازة سنوية',
              LeaveStatus.approved,
            ),
            _buildLeaveHistoryItem(
              '20/01/2025 - 22/01/2025',
              'إجازة مرضية',
              LeaveStatus.approved,
            ),
            _buildLeaveHistoryItem(
              '05/04/2025 - 07/04/2025',
              'إجازة طارئة',
              LeaveStatus.pending,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveHistoryItem(String date, String type, LeaveStatus status) {
    Color statusColor;
    String statusText;

    switch (status) {
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
                  type,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  date,
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
      lastDate: DateTime.now().add(Duration(days: 365)),
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
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _submitLeaveRequest() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null) {
        _showErrorMessage('الرجاء اختيار تاريخ البدء');
        return;
      }
      if (_endDate == null) {
        _showErrorMessage('الرجاء اختيار تاريخ الانتهاء');
        return;
      }

      // Process the leave request
      _showSuccessMessage();
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

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تقديم طلب الإجازة بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
    // Reset form
    setState(() {
      _startDate = null;
      _endDate = null;
      _leaveType = 'إجازة سنوية';
      _reasonController.clear();
    });
  }

  void _printLeaveRequest() async {
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end, // For RTL layout
              children: [
                // Header with logo and title
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'رقم الطلب: ${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                          style: pw.TextStyle(font: arabicFont, fontSize: 10),
                        ),
                        pw.Text(
                          'التاريخ: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
                          style: pw.TextStyle(font: arabicFont, fontSize: 10),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'طلب إجازة',
                          style: pw.TextStyle(
                            font: arabicFontBold,
                            fontSize: 24,
                            color: PdfColors.indigo900,
                          ),
                        ),
                        pw.Text(
                          'شركة البرومتر | Promoter Company',
                          style: pw.TextStyle(font: arabicFont, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 40),

                // Employee information
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'معلومات الموظف',
                        style: pw.TextStyle(font: arabicFontBold, fontSize: 16),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            'كريم',
                            style: pw.TextStyle(font: arabicFont),
                          ),
                          pw.SizedBox(width: 5),
                          pw.Text(
                            'اسم الموظف:',
                            style: pw.TextStyle(font: arabicFontBold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            '12345',
                            style: pw.TextStyle(font: arabicFont),
                          ),
                          pw.SizedBox(width: 5),
                          pw.Text(
                            'رقم الموظف:',
                            style: pw.TextStyle(font: arabicFontBold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            'مروج مبيعات',
                            style: pw.TextStyle(font: arabicFont),
                          ),
                          pw.SizedBox(width: 5),
                          pw.Text(
                            'المسمى الوظيفي:',
                            style: pw.TextStyle(font: arabicFontBold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Leave information
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'تفاصيل الإجازة',
                        style: pw.TextStyle(font: arabicFontBold, fontSize: 16),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            _leaveType,
                            style: pw.TextStyle(font: arabicFont),
                          ),
                          pw.SizedBox(width: 5),
                          pw.Text(
                            'نوع الإجازة:',
                            style: pw.TextStyle(font: arabicFontBold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                            style: pw.TextStyle(font: arabicFont),
                          ),
                          pw.SizedBox(width: 5),
                          pw.Text(
                            'تاريخ البدء:',
                            style: pw.TextStyle(font: arabicFontBold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                            style: pw.TextStyle(font: arabicFont),
                          ),
                          pw.SizedBox(width: 5),
                          pw.Text(
                            'تاريخ الانتهاء:',
                            style: pw.TextStyle(font: arabicFontBold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 5),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            '$difference يوم',
                            style: pw.TextStyle(font: arabicFont),
                          ),
                          pw.SizedBox(width: 5),
                          pw.Text(
                            'عدد الأيام:',
                            style: pw.TextStyle(font: arabicFontBold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'سبب الإجازة:',
                        style: pw.TextStyle(font: arabicFontBold),
                        textAlign: pw.TextAlign.right,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        padding: pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        width: double.infinity,
                        child: pw.Text(
                          _reasonController.text.isEmpty
                              ? 'لا يوجد'
                              : _reasonController.text,
                          style: pw.TextStyle(font: arabicFont),
                          textAlign: pw.TextAlign.right,
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
                          decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 1)),
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'المدير المباشر',
                          style: pw.TextStyle(font: arabicFontBold),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(
                          width: 150,
                          height: 70,
                          decoration: pw.BoxDecoration(
                            border: pw.Border(bottom: pw.BorderSide(width: 1)),
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'توقيع الموظف',
                          style: pw.TextStyle(font: arabicFontBold),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.Spacer(),

                // Footer
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.symmetric(vertical: 10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                        top: pw.BorderSide(width: 1, color: PdfColors.grey300)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'تمت الطباعة بتاريخ: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
                        style: pw.TextStyle(font: arabicFont, fontSize: 10),
                      ),
                      pw.Text(
                        'شركة البرومتر - نظام إدارة طلبات الإجازة',
                        style: pw.TextStyle(font: arabicFont, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}

enum LeaveStatus { approved, rejected, pending }
