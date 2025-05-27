import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future <void> handleBackgroungMessage(RemoteMessage message)async{
  print("Background message received!!");
  print(message.data);
  print(message.data['message']);
  // await FirebaseMsgApi.instance.setupFlutterNotifications();
  // await FirebaseMsgApi.instance.showNotification(message);
}


class FirebaseMsgApi{
  FirebaseMsgApi._();
  static final FirebaseMsgApi instance = FirebaseMsgApi._();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  Future<void> initialize() async{
    
    receiveBackgroundMessage();

    receiveForegroundMessage();

  }

  Future<void> setupFlutterNotifications() async {
    if(_isFlutterLocalNotificationsInitialized) {
      return;
    }

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: "This channel is used for important notifications.",
      importance: Importance.high
      );

    await _localNotifications.resolvePlatformSpecificImplementation<
       AndroidFlutterLocalNotificationsPlugin>()
       ?.createNotificationChannel(channel);

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    final initializationSettingsDarwin = DarwinInitializationSettings(
      //onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle iOS foreground notification
      //}
    );
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details){

      }
    );
    _isFlutterLocalNotificationsInitialized = true;
  }
  
  Future<void> showNotification(RemoteMessage message) async{
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null){
      await _localNotifications.show(
        notification.hashCode,
        notification.title, 
        notification.body, 
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', 
            'High Importance Notifications',
            channelDescription: "This channel is used for important notifications.",
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentBanner: true,
              presentSound: true
            )
        ),
        payload: message.data.toString(),
        );
    }
  }


  Future<void> receiveBackgroundMessage() async{
    //FirebaseMessaging.onMessageOpenedApp.listen(handleBackgroungMessage);

    //final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    //if (initialMessage != null){
    //  handleBackgroungMessage(initialMessage);
    //}
    FirebaseMessaging.onBackgroundMessage(handleBackgroungMessage);
  }

  Future<void> receiveForegroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     print("Foreground message received!!");
     print(message.data);
     print(message.data['message']);
     showNotification(message);
});


  }
}