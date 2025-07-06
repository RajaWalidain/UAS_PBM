import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(initSettings);
    tz.initializeTimeZones();
  }

static Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
}) async {
  final now = tz.TZDateTime.now(tz.local);
  final schedule = tz.TZDateTime.from(scheduledTime, tz.local);

  if (schedule.isBefore(now)) {
    print('⛔ Tidak bisa menjadwalkan notifikasi untuk waktu yang sudah lewat: $schedule');
    return;
  }

  await _notificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    schedule,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'tugas_channel',
        'Pengingat Tugas',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  );
}

}
