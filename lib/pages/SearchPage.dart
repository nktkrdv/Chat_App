import 'dart:developer';

import 'package:caclculator/main.dart';
import 'package:caclculator/models/ChatRoomModel.dart';
import 'package:caclculator/models/UserModel.dart';
import 'package:caclculator/pages/ChatRoomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // List unseen = [];

  TextEditingController searchController = TextEditingController();
  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      // Fetch the existing chat room
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      log("ChatRoom already exists");
      chatRoom = existingChatroom;
    } else {
      //create a new chat room
      log("Chatroom not created");
      ChatRoomModel newChatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          });

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());
      chatRoom = newChatroom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Search"),
        ),
        body: SafeArea(
            child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(labelText: "Email Address"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CupertinoButton(
                        child: Text("Search"),
                        onPressed: () {
                          setState(() {});
                        },
                        color: Theme.of(context).colorScheme.secondary),
                    SizedBox(
                      height: 20,
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .where("email",
                              isEqualTo: searchController.text.trim())
                          .where("email", isNotEqualTo: widget.userModel.email)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            log("has Data");
                            QuerySnapshot dataSnapshot =
                                snapshot.data as QuerySnapshot;

                            if (dataSnapshot.docs.length > 0) {
                              Map<String, dynamic> userMap =
                                  dataSnapshot.docs[0].data()
                                      as Map<String, dynamic>;

                              UserModel searchedUser =
                                  UserModel.fromMap(userMap);

                              return ListTile(
                                onTap: () async {
                                  ChatRoomModel? chatroomModel =
                                      await getChatRoomModel(searchedUser);

                                  if (chatroomModel != null) {
                                    Navigator.pop(context);
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                        targetUser: searchedUser,
                                        userModel: widget.userModel,
                                        firebaseUser: widget.firebaseUser,
                                        chatroom: chatroomModel,
                                      );
                                    }));
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(searchedUser.profilepic!),
                                ),
                                title: Text(searchedUser.fullname!),
                                subtitle: Text(searchedUser.email!),
                                trailing: Icon(Icons.keyboard_arrow_right),
                              );
                            } else {
                              return Text("No results Found");
                            }
                          } else if (snapshot.hasError) {
                            return Text("An error Occured!");
                          } else {
                            return Text("No results Found!");
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ))));
  }
}
