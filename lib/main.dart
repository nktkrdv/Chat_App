import 'dart:developer';
import 'package:caclculator/models/UIHelper.dart';
import 'package:caclculator/pages/MainScreen.dart';
import 'package:caclculator/pages/NotesPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';
import 'package:soundpool/soundpool.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  await Firebase.initializeApp();
  log(message.notification!.toString());
  print('Handling a background message ${message.messageId}');
}

var uuid = Uuid();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    try {
      return MaterialApp(
        title: 'Notes App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const NotesPage(),
      );
    } on Exception catch (e) {
      return Container();
      log("NotesPage exception " + e.toString());
    }
  }
}
