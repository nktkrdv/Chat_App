import 'dart:developer';
import 'dart:io';

import 'package:caclculator/models/ChatRoomModel.dart';
import 'package:caclculator/models/FirebaseHelper.dart';
import 'package:caclculator/models/UIHelper.dart';
import 'package:caclculator/models/UserModel.dart';
import 'package:caclculator/pages/ChatRoomPage.dart';
import 'package:caclculator/pages/HomePage.dart';
import 'package:caclculator/pages/LoginPage.dart';
import 'package:caclculator/pages/PhotoShow.dart';
import 'package:caclculator/pages/SearchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class PhotoShow extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  final String name;
  const PhotoShow(
      {Key? key,
      required this.userModel,
      required this.firebaseUser,
      required this.name})
      : super(key: key);

  @override
  State<PhotoShow> createState() => _PhotoShowState();
}

class _PhotoShowState extends State<PhotoShow> {
  File? imageFile;
  bool isTrue = false;
  TextEditingController fullNameController = TextEditingController();
  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = (await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20));
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo_album),
                  title: Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: Icon(Icons.camera_alt),
                  title: Text("Take a photo"),
                ),
              ],
            ),
          );
        });
  }

  void checkValues() {
    String fullname = fullNameController.text.trim();
    if (fullname == "") {
      UIHelper.showAlertDialog(
          context, "Empty Name", "Name field cannot be empty!");
    }
    if ((fullname != "" && fullname != widget.userModel.fullname) &&
        imageFile != null) {
      log("upload both");
      uploadBoth();
    } else if (fullname != widget.userModel.fullname && fullname != "") {
      log("Uploading name..");
      uploadName();
    } else if (imageFile != null) {
      log("upload photo");
      uploadPhoto();
    }
  }

  void uploadName() async {
    UIHelper.showLoadingDialog(context, "Updating Name...");

    String? fullname = fullNameController.text.trim();
    widget.userModel.fullname = fullname;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      log("Data uploaded!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomePage(
              userModel: widget.userModel, firebaseUser: widget.firebaseUser);
        }),
      );
    });
    Fluttertoast.showToast(
        msg: "Name updated Successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER);
    // UIHelper.showAlertDialog(context, "Success", "Name updated");
  }

  void uploadPhoto() async {
    UIHelper.showLoadingDialog(context, "Uploading image..");

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    // String? fullname = fullNameController.text.trim();

    // widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      log("Data uploaded!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomePage(
              userModel: widget.userModel, firebaseUser: widget.firebaseUser);
        }),
      );
    });
  }

  void uploadBoth() async {
    UIHelper.showLoadingDialog(context, "Uploading image..");

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullname = fullNameController.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      log("Data uploaded!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomePage(
              userModel: widget.userModel, firebaseUser: widget.firebaseUser);
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              SizedBox(
                height: 20,
              ),

              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                padding: EdgeInsets.all(0),
                child: PhotoView(
                  // backgroundDecoration: ,

                  // radius: 130,
                  // backgroundImage:
                  //     (imageFile != null) ? FileImage(imageFile!) : null,
                  imageProvider: (imageFile == null)
                      ? NetworkImage(widget.userModel.profilepic.toString())
                      : null,
                ),
              ),

              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  isTrue
                      ? Flexible(
                          child: TextField(
                            controller: fullNameController,
                            decoration: InputDecoration(
                              labelText: "Name",
                            ),
                          ),
                        )
                      : Text(
                          "Name: " + widget.userModel.fullname.toString(),
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                  if (!isTrue)
                    CupertinoButton(
                        child: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            isTrue = true;
                          });
                          fullNameController.text =
                              widget.userModel.fullname.toString();
                        })
                ],
              ),
              // Icon(Icons.edit),
              CupertinoButton(
                onPressed: () {
                  checkValues();
                },
                color: Theme.of(context).colorScheme.secondary,
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
