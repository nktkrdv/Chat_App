// ignore: file_names
import 'dart:developer';
import 'dart:io';

import 'package:caclculator/models/ChatRoomModel.dart';
import 'package:caclculator/models/FirebaseHelper.dart';
import 'package:caclculator/models/UIHelper.dart';
import 'package:caclculator/models/UserModel.dart';
import 'package:caclculator/pages/ChatRoomPage.dart';
import 'package:caclculator/pages/LoginPage.dart';
import 'package:caclculator/pages/PhotoShow.dart';
import 'package:caclculator/pages/SearchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? stat = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setStatus("Online");
    WidgetsBinding.instance.addObserver(this);
  }

  void setStatus(String status) async {
    if (status.length > 20) {
      stat = status.substring(0, 19);
    } else {
      stat = status;
    }
    _firestore.collection("users").doc(_auth.currentUser?.uid).update({
      "status": stat,
    });
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.resumed) {
      //online
      // setState(() {
      setStatus("Online");
      // });
    } else {
      // setState(() {
      setStatus(DateTime.now().toString());
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat App"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return PhotoShow(
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser,
                      name: widget.userModel.fullname.toString(),
                    );
                  }),
                );
              },
              icon: CircleAvatar(
                backgroundImage:
                    NetworkImage(widget.userModel.profilepic.toString()),
              )),
          IconButton(
            onPressed: () async {
              setStatus(DateTime.now().toString());
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("participants.${widget.userModel.uid}", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data()
                              as Map<String, dynamic>);

                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;

                      List<String> participantKeys = participants.keys.toList();
                      participantKeys.remove(widget.userModel.uid);

                      return FutureBuilder(
                        future:
                            FirebaseHelper.getUserModelById(participantKeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData.data != null) {
                              UserModel targetUser = userData.data as UserModel;

                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                        chatroom: chatRoomModel,
                                        firebaseUser: widget.firebaseUser,
                                        userModel: widget.userModel,
                                        targetUser: targetUser,
                                      );
                                    }),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      targetUser.profilepic.toString()),
                                ),
                                title: Text(targetUser.fullname.toString()),
                                subtitle: Row(
                                  children: [
                                    (targetUser.status == "Online")
                                        ? Icon(Icons.circle,
                                            color: Colors.amber)
                                        : Container(),
                                    (chatRoomModel.lastMessage.toString() != "")
                                        ? Text(chatRoomModel.lastMessage
                                            .toString())
                                        : Text(
                                            "Say hi to your new friend!",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                  ],
                                ),
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text("No Chats"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
