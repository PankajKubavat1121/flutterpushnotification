import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_pushnotification/MessageScreen.dart';

class NotificationService {

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void firebaseInit(BuildContext context) {

    FirebaseMessaging.onMessage.listen((message) {
      print("message title ${message.notification!.title.toString()}");
      print("message body ${message.notification!.body.toString()}");
      print("message data ${message.data['type']}");
      print("message data ${message.data['id']}");
      print("message data ${message.data.toString()}");

      // if(Platform.is0Android){
      // //  initLocalNotification(context,message);
      //   //showNotification(message);
      // }
      // else{
       showNotification(message);
      // }

    });

  }

  Future<void> showNotification(RemoteMessage message) async {

    AndroidNotificationChannel channel = AndroidNotificationChannel(
         "0",
        'High Importance Notifications',
        importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(),
            channel.name.toString(),
            channelDescription: "Your Channel description",
            importance: Importance.high,
            priority: Priority.high,
            ticker: "ticker");

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("user granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("user granted provisional permission");
    } else {
      AppSettings.openNotificationSettings();
      print("user denied permission");
    }
  }

  void isTokenRefresh() async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }

  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {

    var androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
          handleMessage(context,message);
        });
  }

  void handleMessage(BuildContext context,RemoteMessage message){
    if(message.data['type'] == 'msg'){
      Navigator.push(context,MaterialPageRoute(builder: (context) => MessageScreen(id: message.data['id'],)));
    }
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  Future<void>setupInteractMessage(BuildContext context) async{

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage != null){
      handleMessage(context, initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }
}
