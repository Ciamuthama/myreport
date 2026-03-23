import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  //  INIT 
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null, // null = use default app icon
      [
        NotificationChannel(
          channelKey: 'report_reminders',
          channelName: 'Report Reminders',
          channelDescription: 'ReportBot deadline reminders',
          importance: NotificationImportance.High,
          channelShowBadge: true,
          enableVibration: true,
          playSound: true,
        ),
        NotificationChannel(
          channelKey: 'report_urgent',
          channelName: 'Urgent Report Reminders',
          channelDescription: 'Urgent ReportBot deadline reminders',
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          enableVibration: true,
          playSound: true,
        ),
      ],
    );

    // Request permission
    await AwesomeNotifications().requestPermissionToSendNotifications();

    print('NotificationService initialized');
  }

  //  LISTEN TO PERMISSION CHANGES 
  static void startListening(BuildContext context) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceived,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceived(ReceivedAction action) async {}

  //  SCHEDULE ALL REMINDERS 
  static Future<void> scheduleReportReminders(DateTime deadline) async {
    await cancelAll();

    final reminders = [
      (
        id: 1,
        date: deadline.subtract(const Duration(days: 2)),
        hour: 9,
        title: 'Report due in 2 days',
        body: 'Your report is due on ${_formatDate(deadline)}. Open ReportBot.',
        channelKey: 'report_reminders',
      ),
      (
        id: 2,
        date: deadline.subtract(const Duration(days: 1)),
        hour: 9,
        title: 'Report due tomorrow!',
        body: 'Your report is due tomorrow. Open ReportBot and send it now.',
        channelKey: 'report_reminders',
      ),
      (
        id: 3,
        date: deadline,
        hour: 8,
        title: 'Report due TODAY',
        body: 'Submit your report today. Open ReportBot now.',
        channelKey: 'report_urgent',
      ),
      (
        id: 4,
        date: deadline,
        hour: 12,
        title: 'FINAL WARNING',
        body: 'Report still not submitted. Open ReportBot immediately.',
        channelKey: 'report_urgent',
      ),
    ];

    final now = DateTime.now();

    for (final reminder in reminders) {
      final scheduleDate = DateTime(
        reminder.date.year,
        reminder.date.month,
        reminder.date.day,
        reminder.hour,
        0,
      );

      // Only schedule future notifications
      if (scheduleDate.isAfter(now)) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: reminder.id,
            channelKey: reminder.channelKey,
            title: reminder.title,
            body: reminder.body,
            notificationLayout: NotificationLayout.Default,
          ),
          schedule: NotificationCalendar(
            year: scheduleDate.year,
            month: scheduleDate.month,
            day: scheduleDate.day,
            hour: scheduleDate.hour,
            minute: 0,
            second: 0,
            millisecond: 0,
            preciseAlarm: true,
            allowWhileIdle: true,
          ),
        );
        print('Scheduled: ${reminder.title} at $scheduleDate');
      }
    }
  }

  //  INSTANT TEST NOTIFICATION 
  static Future<void> showTestNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 99,
        channelKey: 'report_reminders',
        title: 'Test notification',
        body: 'ReportBot notifications are working!',
      ),
    );
  }

  //  SCHEDULED TEST — fires in 1 minute 
  static Future<void> scheduleTestNotification() async {
    final testTime = DateTime.now().add(const Duration(minutes: 1));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 98,
        channelKey: 'report_reminders',
        title: 'Scheduled Test',
        body: 'Scheduled notifications are working!',
      ),
      schedule: NotificationCalendar(
        year: testTime.year,
        month: testTime.month,
        day: testTime.day,
        hour: testTime.hour,
        minute: testTime.minute,
        second: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );

    print('Test notification scheduled for $testTime');
  }

  //  CANCEL ALL 
  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }

  //  HELPER 
  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}