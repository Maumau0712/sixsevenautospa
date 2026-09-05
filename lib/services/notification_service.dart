import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance =
  NotificationService._internal();

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin
  notifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    tz.initializeTimeZones();

    try {
      tz.setLocalLocation(
        tz.getLocation(
          'Asia/Kuala_Lumpur',
        ),
      );
    } catch (error) {
      debugPrint(
        'Timezone error: $error',
      );
    }

    const androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notifications.initialize(
      settings: settings,
    );

    await notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showTestNotification() async {
    if (kIsWeb) {
      return;
    }

    const details =
    NotificationDetails(
      android:
      AndroidNotificationDetails(
        '67autospa_reminder',
        'Service Reminder',
        channelDescription:
        'Reminder for upcoming car service bookings',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await notifications.show(
      id: 9999,
      title: '67AutoSpa',
      body:
      'Notification is working correctly.',
      notificationDetails: details,
    );
  }

  Future<void> scheduleBookingReminder({
    required int bookingId,
    required String serviceName,
    required String vehiclePlate,
    required DateTime bookingDateTime,
  }) async {
    if (kIsWeb) {
      return;
    }

    DateTime reminderTime =
    bookingDateTime.subtract(
      const Duration(
        days: 1,
      ),
    );

    DateTime now =
    DateTime.now();

    if (reminderTime.isBefore(now)) {
      reminderTime =
          bookingDateTime.subtract(
            const Duration(
              hours: 1,
            ),
          );
    }

    if (reminderTime.isBefore(now)) {
      return;
    }

    final scheduledTime =
    tz.TZDateTime.from(
      reminderTime,
      tz.local,
    );

    const details =
    NotificationDetails(
      android:
      AndroidNotificationDetails(
        '67autospa_reminder',
        'Service Reminder',
        channelDescription:
        'Reminder for upcoming car service bookings',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await notifications.zonedSchedule(
      id: bookingId,
      title:
      '67AutoSpa Service Reminder',
      body:
      '$serviceName for $vehiclePlate is coming up soon.',
      scheduledDate:
      scheduledTime,
      notificationDetails:
      details,
      androidScheduleMode:
      AndroidScheduleMode
          .inexactAllowWhileIdle,
      payload:
      bookingId.toString(),
    );
  }

  Future<void> cancelBookingReminder(
      int bookingId,
      ) async {
    if (kIsWeb) {
      return;
    }

    await notifications.cancel(
      id: bookingId,
    );
  }
}