import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MeetingsScreen extends StatefulWidget {
  final bool pastMeetings;

  const MeetingsScreen({Key? key, this.pastMeetings = false}) : super(key: key);

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  late List<Meeting> _meetings;

  @override
  void initState() {
    super.initState();
    _meetings = widget.pastMeetings ? _pastMeetings : _upcomingMeetings;
  }

  final List<Meeting> _upcomingMeetings = [
    Meeting(
      id: '1',
      title: 'اجتماع مع شركة الأمل',
      location: 'مكتب المبيعات الرئيسي',
      date: DateTime.now().add(Duration(days: 1)),
      startTime: TimeOfDay(hour: 10, minute: 0),
      endTime: TimeOfDay(hour: 11, minute: 30),
      participants: ['أحمد محمد', 'سارة علي', 'محمد خالد'],
      agenda: 'مناقشة العرض الجديد وإمكانيات التعاون المستقبلي',
    ),
    Meeting(
      id: '2',
      title: 'لقاء مع عميل جديد',
      location: 'كافيه ستاربكس - الفرع الرئيسي',
      date: DateTime.now().add(Duration(days: 3)),
      startTime: TimeOfDay(hour: 13, minute: 0),
      endTime: TimeOfDay(hour: 14, minute: 0),
      participants: ['سعيد عبدالله'],
      agenda: 'تقديم منتجاتنا وخدماتنا للعميل الجديد',
    ),
    Meeting(
      id: '3',
      title: 'اجتماع فريق المبيعات',
      location: 'قاعة الاجتماعات الكبرى',
      date: DateTime.now().add(Duration(days: 5)),
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 12, minute: 0),
      participants: ['فريق المبيعات بالكامل'],
      agenda: 'مراجعة أهداف الربع السنوي ومناقشة استراتيجيات جديدة',
    ),
  ];

  final List<Meeting> _pastMeetings = [
    Meeting(
      id: '4',
      title: 'زيارة عميل شركة النور',
      location: 'مقر شركة النور',
      date: DateTime.now().subtract(Duration(days: 5)),
      startTime: TimeOfDay(hour: 11, minute: 0),
      endTime: TimeOfDay(hour: 12, minute: 30),
      participants: ['فهد عمر', 'خالد محمد'],
      agenda: 'متابعة الطلبيات السابقة وعرض المنتجات الجديدة',
      notes: 'تم الاتفاق على طلبية جديدة بقيمة 50,000 ريال',
      outcome: MeetingOutcome.successful,
    ),
    Meeting(
      id: '5',
      title: 'اجتماع متابعة مع مجموعة الفيصل',
      location: 'مقر مجموعة الفيصل',
      date: DateTime.now().subtract(Duration(days: 10)),
      startTime: TimeOfDay(hour: 14, minute: 0),
      endTime: TimeOfDay(hour: 15, minute: 30),
      participants: ['محمد سعيد', 'عبدالله راشد'],
      agenda: 'متابعة المشاريع المشتركة وبحث فرص التعاون المستقبلي',
      notes:
          'العميل غير راضٍ عن التسليم المتأخر، يجب متابعة الأمر مع قسم الشحن',
      outcome: MeetingOutcome.needsFollowUp,
    ),
    Meeting(
      id: '6',
      title: 'عرض تقديمي لمنتج جديد',
      location: 'قاعة المؤتمرات - فندق الريتز',
      date: DateTime.now().subtract(Duration(days: 15)),
      startTime: TimeOfDay(hour: 10, minute: 0),
      endTime: TimeOfDay(hour: 13, minute: 0),
      participants: ['فريق التسويق', 'فريق المبيعات', 'عدة عملاء محتملين'],
      agenda: 'تقديم المنتج الجديد وشرح مميزاته وفوائده للعملاء',
      notes: 'العرض كان ناجحًا، تم استلام عدة طلبات مبدئية',
      outcome: MeetingOutcome.successful,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pastMeetings ? 'المقابلات السابقة' : 'المقابلات القادمة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _meetings.isEmpty
            ? _buildEmptyState()
            : Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.pastMeetings) _buildTodayMeetings(),
                    SizedBox(height: 16.h),
                    Text(
                      widget.pastMeetings
                          ? 'المقابلات السابقة'
                          : 'المقابلات القادمة',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _meetings.length,
                        itemBuilder: (context, index) {
                          return _buildMeetingCard(_meetings[index])
                              .animate()
                              .fadeIn(
                                duration: 300.ms,
                                delay: (50 * index).ms,
                              )
                              .slide(
                                  begin: Offset(0.1, 0),
                                  end: Offset(0, 0),
                                  duration: 300.ms,
                                  curve: Curves.easeOut);
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: !widget.pastMeetings
          ? FloatingActionButton(
              onPressed: () {
                // Add new meeting functionality
                _showAddMeetingDialog();
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.pastMeetings ? Icons.history : Icons.meeting_room,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            widget.pastMeetings
                ? 'لا توجد مقابلات سابقة'
                : 'لا توجد مقابلات قادمة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.pastMeetings
                ? 'ستظهر المقابلات السابقة هنا'
                : 'اضغط على زر الإضافة لإنشاء مقابلة جديدة',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMeetings() {
    // Filter today's meetings
    final todayMeetings = _meetings
        .where((meeting) =>
            meeting.date.day == DateTime.now().day &&
            meeting.date.month == DateTime.now().month &&
            meeting.date.year == DateTime.now().year)
        .toList();

    if (todayMeetings.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مقابلات اليوم',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        ...todayMeetings.map((meeting) => _buildTodayMeetingCard(meeting)),
        SizedBox(height: 16.h),
        Divider(),
      ],
    );
  }

  Widget _buildTodayMeetingCard(Meeting meeting) {
    return Card(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
              child: Center(
                child: Icon(
                  Icons.event,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${_formatTime(meeting.startTime)} - ${_formatTime(meeting.endTime)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            TextButton(
              onPressed: () {
                // View meeting details
                _showMeetingDetails(meeting);
              },
              child: Text('عرض'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingCard(Meeting meeting) {
    bool isPast = widget.pastMeetings;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    meeting.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isPast && meeting.outcome != null)
                  _buildOutcomeTag(meeting.outcome!),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey),
                SizedBox(width: 8.w),
                Text(
                  '${meeting.date.day}/${meeting.date.month}/${meeting.date.year}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.access_time, size: 16.sp, color: Colors.grey),
                SizedBox(width: 8.w),
                Text(
                  '${_formatTime(meeting.startTime)} - ${_formatTime(meeting.endTime)}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.location_on, size: 16.sp, color: Colors.grey),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    meeting.location,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'المشاركون:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              meeting.participants.join('، '),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16.h),
            if (isPast && meeting.notes != null) ...[
              Text(
                'ملاحظات:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                meeting.notes!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 16.h),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isPast)
                  OutlinedButton(
                    onPressed: () {
                      // Cancel meeting functionality
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: Text('إلغاء'),
                  ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () => _showMeetingDetails(meeting),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isPast ? 'عرض التفاصيل' : 'تفاصيل'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomeTag(MeetingOutcome outcome) {
    Color color;
    String text;

    switch (outcome) {
      case MeetingOutcome.successful:
        color = Colors.green;
        text = 'ناجح';
        break;
      case MeetingOutcome.cancelled:
        color = Colors.red;
        text = 'ملغي';
        break;
      case MeetingOutcome.needsFollowUp:
        color = Colors.orange;
        text = 'بحاجة للمتابعة';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showMeetingDetails(Meeting meeting) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'تفاصيل المقابلة',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView(
                  children: [
                    _buildDetailItem('العنوان', meeting.title),
                    _buildDetailItem('التاريخ',
                        '${meeting.date.day}/${meeting.date.month}/${meeting.date.year}'),
                    _buildDetailItem('الوقت',
                        '${_formatTime(meeting.startTime)} - ${_formatTime(meeting.endTime)}'),
                    _buildDetailItem('المكان', meeting.location),
                    _buildDetailItem(
                        'المشاركون', meeting.participants.join('، ')),
                    _buildDetailItem('جدول الأعمال', meeting.agenda),
                    if (widget.pastMeetings && meeting.notes != null)
                      _buildDetailItem('ملاحظات', meeting.notes!),
                    if (widget.pastMeetings && meeting.outcome != null)
                      _buildDetailItem(
                        'النتيجة',
                        meeting.outcome == MeetingOutcome.successful
                            ? 'ناجح'
                            : meeting.outcome == MeetingOutcome.cancelled
                                ? 'ملغي'
                                : 'بحاجة للمتابعة',
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('إغلاق'),
                ),
              ),
              if (!widget.pastMeetings) ...[
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Edit meeting functionality
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text('تعديل المقابلة'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Divider(),
        ],
      ),
    );
  }

  void _showAddMeetingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة مقابلة جديدة'),
        content: Text('سيتم إضافة ميزة إنشاء المقابلات قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

enum MeetingOutcome { successful, cancelled, needsFollowUp }

class Meeting {
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<String> participants;
  final String agenda;
  final String? notes;
  final MeetingOutcome? outcome;

  Meeting({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.participants,
    required this.agenda,
    this.notes,
    this.outcome,
  });
}
