import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      null, // default icon
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic notifications',
          defaultColor: const Color(0xFF41B06E),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        )
      ],
    );
  }

  Future<void> showNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'basic_channel',
        title: title,
        body: body,
      ),
    );
  }
}