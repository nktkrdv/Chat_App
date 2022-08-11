import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:caclculator/models/UIHelper.dart';
import 'package:caclculator/pages/MainScreen.dart';
import 'package:caclculator/pages/SeePic.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:caclculator/main.dart';
import 'package:caclculator/models/ChatRoomModel.dart';
import 'package:caclculator/models/MessageModel.dart';
import 'package:caclculator/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:soundpool/soundpool.dart';
// import 'package:overlay_support/overlay_support.dart';
import 'package:swipe_to/swipe_to.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {Key? key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  bool typing = false;
  bool swipeTrue = false;
  String swipeMessage = "";
  List unseen = [];
  bool show = false;
  FocusNode focusNode = FocusNode();
  TextEditingController messageController = TextEditingController();
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String? mtoken = " ";
  @override
  void initState() {
    super.initState();
    try {
      requestPermission();
      loadFCM();
      listenFCM();
      getToken();
    } on Exception catch (e) {
      UIHelper.showAlertDialog(context, "Error", "Notification Error");
    }

    FirebaseMessaging.instance.subscribeToTopic("Animal");
    focusNode.addListener(() {
      if (show) {
        setState(() {
          show = false;
        });
      }
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void loadFCM() async {
    if (!foundation.kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !foundation.kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void getToken() async {
    try {
      await FirebaseMessaging.instance.getToken().then((token) {
        setState(() {
          mtoken = token;
        });

        saveToken(token!);
      });
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAkuBgaK4:APA91bGSj2gfVydo2QRztLGoCYDX0yfViJUfyitkYZ8v5QsSjjZI62dSnSVLj_9n2bwRTc1mi8f5WUmYvVaTYTpXMPvYUMncFYll0fDAV2sKDK0rUS_G2fhKOyhLLOHL4ukyMdnaJKT_',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
    Fluttertoast.showToast(
        msg: "Message Sent!", toastLength: Toast.LENGTH_LONG);
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .update({
      'token': token,
    });
  }

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      // Send Message
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false,
          submess: (swipeTrue) ? swipeMessage : "");

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("Message Sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(widget.targetUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SeePic(targetUser: widget.targetUser);
                    }));
                  },
                  icon: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        NetworkImage(widget.targetUser.profilepic.toString()),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.targetUser.fullname.toString()),
                    Text(
                      textAlign: TextAlign.left,
                      widget.targetUser.status.toString(),
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  alignment: Alignment.center,
                  onPressed: () async {
                    DocumentSnapshot snap = await FirebaseFirestore.instance
                        .collection("users")
                        .doc(widget.targetUser.uid)
                        .get();

                    String token = snap['token'];
                    print(token);
                    log(token);

                    sendPushMessage(
                        token,
                        "Just sit and study, we are here for you!",
                        "Study Time!");
                  },
                  icon: Icon(Icons.add_alert),
                )
              ],
            );
          } else {
            return Container();
          }
        },
      )),
      body: SafeArea(
        child: Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // This is where the chats will go
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("chatrooms")
                        .doc(widget.chatroom.chatroomid)
                        .collection("messages")
                        .orderBy("createdom", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;

                          return ListView.builder(
                            reverse: true,
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context, index) {
                              MessageModel currentMessage =
                                  MessageModel.fromMap(dataSnapshot.docs[index]
                                      .data() as Map<String, dynamic>);

                              return SwipeTo(
                                onRightSwipe: () {
                                  log("swiped right");
                                  // setState(() {
                                  //   swipeTrue = true;
                                  //   swipeMessage = currentMessage.text.toString();
                                  // });
                                },
                                // onLeftSwipe: () {
                                //   log("swiped left");
                                // },
                                child: Row(
                                  mainAxisAlignment: (currentMessage.sender ==
                                          widget.userModel.uid)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 7,
                                          horizontal: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (currentMessage.sender ==
                                                  widget.userModel.uid)
                                              ? Colors.brown
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                (currentMessage.submess
                                                                .toString() !=
                                                            "" &&
                                                        currentMessage
                                                                .submess !=
                                                            null)
                                                    ? Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 0,
                                                                horizontal: 2),
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                vertical: 2),
                                                        child: Text(
                                                          (currentMessage
                                                                      .submess
                                                                      .toString()
                                                                      .length >
                                                                  30)
                                                              ? currentMessage
                                                                      .submess
                                                                      .toString()
                                                                      .substring(
                                                                          0,
                                                                          29) +
                                                                  "..."
                                                              : currentMessage
                                                                  .submess
                                                                  .toString(),
                                                          maxLines: null,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .red[200]),
                                                      )
                                                    : Container(),
                                                Text(
                                                  // maxline,
                                                  currentMessage.text
                                                      .toString(),
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                    Row(
                                      children: [
                                        (currentMessage.sender ==
                                                widget.userModel.uid)
                                            ? (currentMessage.seen == true)
                                                ? Icon(
                                                    Icons.check_circle,
                                                    color: Colors.blue,
                                                    size: 20,
                                                  )
                                                : Icon(
                                                    Icons.check_circle_outline,
                                                    size: 13,
                                                    color: Colors.white,
                                                  )
                                            : Container(),
                                        Text(
                                          maxLines: null,
                                          textAlign: TextAlign.start,
                                          currentMessage.createdon
                                              .toString()
                                              .substring(11, 16),
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                                "An error occured! Please check your internet connection."),
                          );
                        } else {
                          return Center(
                            child: Text("Say hi to your new friend"),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),

              Container(
                color: Colors.brown[300],
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: WillPopScope(
                  onWillPop: () {
                    if (show) {
                      setState(() {
                        show = false;
                      });
                    } else {
                      Navigator.pop(context);
                    }
                    return Future.value(false);
                  },
                  child: Stack(children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Column(
                                  children: [
                                    (swipeTrue)
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  swipeMessage,
                                                  maxLines: null,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      swipeTrue = false;
                                                      swipeMessage = "";
                                                    });
                                                  },
                                                  icon: Icon(Icons.cancel)),
                                            ],
                                          )
                                        : Container(),
                                    TextField(
                                      focusNode: focusNode,
                                      controller: messageController,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                          fillColor: Colors.amber,
                                          prefixIcon: IconButton(
                                              onPressed: () {
                                                focusNode.unfocus();
                                                // focusNode.canRequestFocus = false;
                                                setState(() {
                                                  show = !show;
                                                });
                                              },
                                              icon: Icon(Icons.emoji_emotions)),
                                          border: InputBorder.none,
                                          hintText: "Enter message"),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  sendMessage();
                                  if (swipeTrue) {
                                    setState(() {
                                      swipeTrue = false;
                                      swipeMessage = "";
                                    });
                                  }
                                },
                                icon: Icon(
                                  Icons.send,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          // SizedBox(child: Container(child: emojiSelect())),
                          show
                              ? SizedBox(height: 200, child: emojiSelect())
                              : Container(),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget emojiSelect() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        // setState(() {
        messageController.text = messageController.text + emoji.emoji;
        // initState();
        // focusNode.canRequestFocus = false;
        // });
        // Do something when emoji is tapped
      },
      onBackspacePressed: () {},
      config: Config(
        columns: 7,
        emojiSizeMax: 32 *
            (Platform.isIOS
                ? 1.30
                : 0.75), // Issue: https://github.com/flutter/flutter/issues/28894
        verticalSpacing: 0,
        horizontalSpacing: 0,
        gridPadding: EdgeInsets.zero,
        initCategory: Category.RECENT,
        bgColor: Color(0xFFF2F2F2),
        indicatorColor: Colors.blue,
        iconColor: Colors.grey,
        iconColorSelected: Colors.blue,
        progressIndicatorColor: Colors.blue,
        backspaceColor: Colors.blue,
        skinToneDialogBgColor: Colors.white,
        skinToneIndicatorColor: Colors.grey,
        enableSkinTones: true,
        showRecentsTab: true,
        recentsLimit: 28,
        noRecents: const Text(
          'No Recents',
          style: TextStyle(fontSize: 20, color: Colors.black26),
          textAlign: TextAlign.center,
        ),
        tabIndicatorAnimDuration: kTabScrollDuration,
        categoryIcons: const CategoryIcons(),
        buttonMode: ButtonMode.MATERIAL,
      ),
    );
  }
}
