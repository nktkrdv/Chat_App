class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;
  String? token;
  String? status;

  UserModel({this.uid, this.email, this.fullname, this.profilepic});
  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
    token = map["token"];
    status = map["status"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic,
      "token": token,
      "status": status,
    };
  }
}
