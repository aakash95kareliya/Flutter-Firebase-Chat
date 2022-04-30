import 'package:encrypt/encrypt.dart' as encryption;
import 'package:encrypt/encrypt.dart';
import 'package:flutter_chat/model/chat_message.dart';
import 'package:flutter_chat/utils/signal_algorithm1.dart';

import '../main.dart';

class CustomAESEncryption {
  Encrypter encrypter;
  var iv;

  CustomAESEncryption() {
    final key = encryption.Key.fromUtf8("{key}");
    iv = encryption.IV.fromUtf8("{iv_key}");
    encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: "PKCS7"));
  }

  String encrypt(String input) {
    return encrypter.encrypt(input, iv: iv).base64;
  }

  String decrypt(encryption.Encrypted data) {
    return encrypter.decrypt(data, iv: iv);
  }

  String decrypt64(String data) {
    return encrypter.decrypt64(data, iv: iv);
  }

  encodeData(ChatMessage chatMessage, Person person) {
    var ikp = base64encodeDecode.encode(person.getIdentityKeyPair());
    var pks = person.getPreKeys();
    var rId = base64encodeDecode.encode(person.getRegistrationId().toString());
    var spk = base64encodeDecode.encode(person.getSignedPreKey());
    var spkId = base64encodeDecode.encode(person.spkId.toString());

    ikp = Encrypted.from64(encrypt(ikp)).base64;
    pks = Encrypted.from64(encrypt(pks)).base64;
    rId = Encrypted.from64(encrypt(rId)).base64;
    spkId = Encrypted.from64(encrypt(spkId)).base64;
    spk = Encrypted.from64(encrypt(spk)).base64;
    chatMessage.iPkPair = ikp;
    chatMessage.sPkPair = spk;
    chatMessage.sPkId = spkId;
    chatMessage.pks = pks;
    chatMessage.userId = person.address.getName();
    chatMessage.deviceId = person.address.getDeviceId();
    chatMessage.registrationId = rId;
  }
}
