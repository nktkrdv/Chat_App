class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;
  String? submess;

  MessageModel(
      {this.messageid,
      this.sender,
      this.text,
      this.seen,
      this.createdon,
      this.submess});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdom"].toDate();
    submess = map["submess"];
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdom": createdon,
      "submess": submess,
    };
  }
}
