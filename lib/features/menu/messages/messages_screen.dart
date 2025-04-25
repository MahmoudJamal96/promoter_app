import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<Message> _messages = [
    Message(
      sender: 'أحمد محمد',
      content: 'مرحباً، هل يمكننا مناقشة تقرير المبيعات الأخير؟',
      time: '10:30 ص',
      isRead: true,
    ),
    Message(
      sender: 'سارة خالد',
      content: 'تم إرسال طلب التوصيل الجديد، يرجى التحقق منه',
      time: 'أمس',
      isRead: false,
    ),
    Message(
      sender: 'محمد علي',
      content: 'تمت الموافقة على طلب الإجازة الخاص بك',
      time: '22/04/2025',
      isRead: true,
    ),
    Message(
      sender: 'فاطمة أحمد',
      content: 'هناك اجتماع غداً في الساعة العاشرة صباحاً',
      time: '21/04/2025',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الرسائل', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageTile(_messages[index])
                            .animate()
                            .fadeIn(
                              duration: 300.ms,
                              delay: (50 * index).ms,
                            )
                            .slide(
                                begin: Offset(.1, 0),
                                end: Offset(0, 0),
                                duration: 300.ms,
                                curve: Curves.easeOut);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new message
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد رسائل',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ستظهر الرسائل الجديدة هنا',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: CircleAvatar(
        child: Text(
          message.sender.substring(0, 1),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            message.isRead ? Colors.grey : Theme.of(context).primaryColor,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              message.sender,
              style: TextStyle(
                fontWeight:
                    message.isRead ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ),
          Text(
            message.time,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      subtitle: Text(
        message.content,
        style: TextStyle(
          color: message.isRead ? Colors.grey : Colors.black87,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        // View message details
      },
    );
  }
}

class Message {
  final String sender;
  final String content;
  final String time;
  final bool isRead;

  Message({
    required this.sender,
    required this.content,
    required this.time,
    required this.isRead,
  });
}
