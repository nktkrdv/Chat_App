// // import 'dart:html';

// // import 'package:caclculator/pages/LoginPage.dart';
// // import 'package:caclculator/pages/CompleteProfile.dart';
// import 'package:caclculator/pages/LoginPage.dart';
// import 'package:caclculator/pages/NotesPage.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:uuid/uuid.dart';
// // import 'pages/HomePage.dart';
// // import 'pages/SignUpPage.dart';

// var uuid = Uuid();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//   print('Handling a background message ${message.messageId}');
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: NotesPage(),
//     );
//   }
// }


// Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: Colors.grey[300],
//               backgroundImage:
//                   NetworkImage(widget.targetUser.profilepic.toString()),
//             ),
//             SizedBox(
//               width: 10,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.targetUser.fullname.toString()),
//                 Text(
//                   textAlign: TextAlign.left,
//                   widget.targetUser.status.toString(),
//                   style: TextStyle(
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),