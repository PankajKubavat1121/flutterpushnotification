import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_pushnotification/Service/NotificationService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    notificationService.requestNotificationPermission();
    notificationService.firebaseInit(context);
    notificationService.isTokenRefresh();
   // notificationService.setupInteractMessage(context);
    notificationService.getDeviceToken().then((token) {
      log("Token is $token");
      //log("value is $token");
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: Text('Push Notification'),
      ),
      body: Center(
        child: TextButton(onPressed: (){
          callPushNotification();
        }, child: Text("Send Notification")),
      ),
    );
  }

  void callPushNotification(){
    var url = 'https://fcm.googleapis.com/fcm/send';
    notificationService.getDeviceToken().then((value)async{
      var data = {
      'to':'cZS5kqGBj-EoHSqCLBubQL:APA91bHTWepH1BR5vkq50SaJAlD__wK6OViOE7rT0wMZukzUbfLcm2Mb9BngD6xtj82AYJWsw_erTM-VYTBmjajNOoONYYDZ2yxNxdNc0xd8QaSmjfuMVH39XZ0_hwSVAHujEVvSJo_F',  ///value.toString(),
      'priority': 'high',
      'notification':{
      'title': 'Pankaj',
      'body': 'Hello Pankaj I am Your FD',
       }
     };

      await http.post(
          Uri.parse(url),
          body: jsonEncode(data),
          headers: {
            'Content-Type':'application/json',
            'Authorization':'key=AAAA3sFjkQE:APA91bE4qlVdsjN47jVMn05gCZcVv9Ys8Y-CxgBoz2NPGeWA6mUYBkOp9iq76eH2ANp87An6nfWi7yvENgUpYzY_VArUJ2vH00EKt8ueUjBs_2UvHH_j2x6YhO5st3BfMM_RnvWq9TPa'});
    });
  }
}
