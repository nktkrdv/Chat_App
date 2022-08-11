import 'package:caclculator/models/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class SeePic extends StatefulWidget {
  final UserModel targetUser;
  // File? imageFile;
  const SeePic({Key? key, required this.targetUser}) : super(key: key);

  @override
  State<SeePic> createState() => _SeePicState();
}

class _SeePicState extends State<SeePic> {
  @override
  Widget build(BuildContext context) {
    return PhotoView(
        // radius: 170,
        // backgroundImage: (widget.targetUser.profilepic != null && widget.targetUser.profilepic != "") ?  : null,
        imageProvider: (widget.targetUser.profilepic != null &&
                widget.targetUser.profilepic.toString() != "")
            ? NetworkImage(widget.targetUser.profilepic.toString())
            : null);
  }
}
