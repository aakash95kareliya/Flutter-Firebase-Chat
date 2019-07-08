import 'package:firebase_database/firebase_database.dart';

class Users {
  String email;
  bool groupUser;
  int lastSeenTime;
  String name;
  bool online;
  String phoneNumber;
  bool typing;
  String userId;

  Users(this.email, this.groupUser, this.lastSeenTime, this.name, this.online,
      this.phoneNumber, this.typing, this.userId);

  factory Users.fromJson(DataSnapshot snapshot) {
    return Users(
      snapshot.value["email"],
      snapshot.value["groupUser"],
      snapshot.value["lastSeenTime"],
      snapshot.value["name"],
      snapshot.value["online"],
      snapshot.value["phoneNumber"],
      snapshot.value["typing"],
      snapshot.value["userId"],
    );
  }

  toJson() {
    return {
      "email": email,
      "groupUser": groupUser,
      "lastSeenTime": lastSeenTime,
      "name": name,
      "online": online,
      "phoneNumber": phoneNumber,
      "typing": typing,
      "userId": userId,
    };
  }
}
