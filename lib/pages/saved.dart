import 'dart:developer';

import 'package:caclculator/models/ChatRoomModel.dart';
import 'package:caclculator/models/MessageModel.dart';
import 'package:caclculator/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:swipe_to/swipe_to.dart';

class stream extends StatelessWidget {
  final UserModel userModel;
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  // fina User firebaseUser;
  const stream(
      {Key? key,
      required this.userModel,
      required this.targetUser,
      required this.chatroom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .doc(chatroom.chatroomid)
              .collection("messages")
              .orderBy("createdom", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                return ListView.builder(
                  reverse: true,
                  itemCount: dataSnapshot.docs.length,
                  itemBuilder: (context, index) {
                    MessageModel currentMessage = MessageModel.fromMap(
                        dataSnapshot.docs[index].data()
                            as Map<String, dynamic>);

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
                        mainAxisAlignment:
                            (currentMessage.sender == userModel.uid)
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
                                color: (currentMessage.sender == userModel.uid)
                                    ? Colors.brown
                                    : Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      (currentMessage.submess.toString() !=
                                                  "" &&
                                              currentMessage.submess != null)
                                          ? Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 0, horizontal: 2),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 2),
                                              child: Text(
                                                (currentMessage.submess
                                                            .toString()
                                                            .length >
                                                        30)
                                                    ? currentMessage.submess
                                                            .toString()
                                                            .substring(0, 29) +
                                                        "..."
                                                    : currentMessage.submess
                                                        .toString(),
                                                maxLines: null,
                                              ),
                                              decoration: BoxDecoration(
                                                  // borderRadius:
                                                  //     BorderRadius
                                                  //         .circular(
                                                  //             5),
                                                  // border: Border.all(
                                                  //     style:
                                                  //         BorderStyle
                                                  //             .solid,
                                                  //     width: 3),
                                                  color: Colors.red[200]),
                                            )
                                          : Container(),
                                      Text(
                                        // maxline,
                                        currentMessage.text.toString(),
                                        maxLines: null,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          Row(
                            children: [
                              (currentMessage.sender == userModel.uid)
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
                                    fontSize: 10, color: Colors.white),
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
    );
  }
}
