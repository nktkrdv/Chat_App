import 'package:caclculator/models/FirebaseHelper.dart';
import 'package:caclculator/models/UserModel.dart';
import 'package:caclculator/pages/HomePage.dart';
import 'package:caclculator/pages/LoginPage.dart';
import 'package:caclculator/pages/SignUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import '../models/UIHelper.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  TextEditingController notesController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() async {
    String notes = notesController.text.trim();
    // String password = passwordController.text.trim();

    if (notes == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
    } else if (notes == "5272") {
      logIn();
    } else {
      UIHelper.showAlertDialog(context, "Saved", "Notes: " + notes);
    }
  }

  void logIn() async {
    // Go to HomePage
    UIHelper.showLoadingDialog(context, "Wait");
    print("Log In Successful!");
    Navigator.popUntil(context, (route) => route.isFirst);
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) {
    //     return LoginPage();
    //   }),
    // );
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Logged In
      UserModel? thisUserModel =
          await FirebaseHelper.getUserModelById(currentUser.uid);
      if (thisUserModel != null) {
        //logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return HomePage(
              firebaseUser: currentUser,
              userModel: thisUserModel,
            );
          }),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return LoginPage();
          }),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return LoginPage();
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image(image: AssetImage('assets/images/notepic.png')),
                  Text(
                    "Note Saver",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 45,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: notesController,
                    decoration:
                        InputDecoration(labelText: "Enter Note to Save!"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      checkValues();
                    },
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text("Save"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
