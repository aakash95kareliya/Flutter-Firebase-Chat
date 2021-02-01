import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat/main.dart';
import 'dart:typed_data';
import 'package:flutter_chat/utils/signal_algorithm1.dart';

class Users {
  String email;
  bool groupUser;
  int lastSeenTime;
  String name;
  bool online;
  String phoneNumber;
  bool typing;
  String userId;
  String iPkPair, sPkPair, pks;
  String registrationId;
  String spkId;

  Users(this.email, this.groupUser, this.lastSeenTime, this.name, this.online, this.phoneNumber, this.typing,
      this.userId, this.iPkPair, this.sPkPair, this.pks, this.registrationId, this.spkId);

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
        snapshot.value["ipkPair"],
        snapshot.value["sPkPair"],
        snapshot.value["pks"],
        snapshot.value["registrationId"],
        snapshot.value["spkId"]);
  }

  Uint8List getIdentityKeyPair() {
    return parseKey(iPkPair);
  }

  int getRegistrationId() {
    return int.parse(base64encodeDecode.decode(encryption.decrypt64(registrationId)));
  }
  int getSpkId() {
    return int.parse(base64encodeDecode.decode(encryption.decrypt64(spkId)));
  }

  Uint8List getSPkPair() {
    return parseKey(sPkPair);
  }

  List<Uint8List> getPks() {
    String strKey = encryption.decrypt64(pks);
    return strKey.split(",").map((e) => getUInt8ListFromString(base64encodeDecode.decode(e))).toList();
  }

  Uint8List parseKey(String key) {
    return getUInt8ListFromString(base64encodeDecode.decode(encryption.decrypt64(key)));
  }

  toJson() {
    return {
      "email": email,
      "groupUser": groupUser,
      "lastSeenTime": lastSeenTime,
      "name": name,
      "online": online,
      "phoneNumber": phoneNumber,
      "ipkPair": iPkPair,
      "sPkPair": sPkPair,
      "pks": pks,
      "registrationId": registrationId,
      "typing": typing,
      "userId": userId,
      "spkId": spkId,
    };
  }
}
