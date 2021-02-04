import 'dart:typed_data';

import 'package:flutter_chat/utils/signal_algorithm1.dart';

import '../main.dart';

class ChatMessage {
  String receiverId;
  String senderId;
  String message;
  int time;

  String iPkPair, sPkPair, pks, userId;
  int deviceId;
  String registrationId;
  String sPkId;

  ChatMessage(this.receiverId, this.senderId, this.message, this.time,
      {this.iPkPair, this.sPkPair, this.pks, this.registrationId, this.sPkId, this.userId, this.deviceId});

  factory ChatMessage.fromJson(Map<dynamic, dynamic> snapshot) {
    return ChatMessage(snapshot["receiverId"].toString(), snapshot["senderId"].toString(),
        snapshot["message"].toString(), int.parse(snapshot["time"]),
        iPkPair: snapshot["iPkPair"].toString(),
        sPkPair: snapshot["sPkPair"].toString(),
        pks: snapshot["pks"].toString(),
        deviceId: snapshot["deviceId"],
        userId: snapshot["userId"].toString(),
        registrationId: snapshot["registrationId"].toString(),
        sPkId: snapshot["sPkId"].toString());
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = new Map<String, dynamic>();
    map["receiverId"] = receiverId.toString();
    map["senderId"] = senderId.toString();
    map["message"] = message.toString();
    map["time"] = time.toString();
    map["iPkPair"] = iPkPair.toString();
    map["deviceId"] = deviceId;
    map["userId"] = userId.toString();
    map["sPkPair"] = sPkPair.toString();
    map["pks"] = pks.toString();
    map["registrationId"] = registrationId.toString();
    map["sPkId"] = sPkId.toString();
    return map;
  }

  Uint8List getIdentityKeyPair() {
    return parseKey(iPkPair);
  }

  int getRegistrationId() {
    return int.parse(base64encodeDecode.decode(encryption.decrypt64(registrationId)));
  }

  int getSpkId() {
    return int.parse(base64encodeDecode.decode(encryption.decrypt64(sPkId)));
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
}
