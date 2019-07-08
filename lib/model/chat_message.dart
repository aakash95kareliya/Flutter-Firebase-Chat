import 'package:firebase_database/firebase_database.dart';

class ChatMessage {
  String receiverId;
  String senderId;
  String message;
  int time;

  ChatMessage(this.receiverId, this.senderId, this.message, this.time);

  factory ChatMessage.fromJson(Map<dynamic, dynamic> snapshot) {
    return ChatMessage(snapshot["receiverId"].toString(),
        snapshot["senderId"].toString(),
        snapshot["message"].toString(),
        int.parse(snapshot["time"]));
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map["receiverId"] = receiverId.toString();
    map["senderId"] = senderId.toString();
    map["message"] = message.toString();
    map["time"] = time.toString();
    return map;
  }
}
