import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  static Future<void> cancelCustomReminder() async {
    await _notifications.cancel(100);
  }

  static Future<void> scheduleIntervalReminder({
    required String title,
    required String body,
    required int intervalHours,
  }) async {
    await cancelCustomReminder();

    await _notifications.zonedSchedule(
      100,
      title.isEmpty ? 'Emlékeztető' : title,
      body.isEmpty ? 'Ideje ránézni az appra!' : body,
      tz.TZDateTime.now(tz.local).add(Duration(hours: intervalHours)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'custom_interval_channel',
          'Egyedi Értesítések',
          channelDescription: 'Felhasználó által megadott gyakoriságú értesítések',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}