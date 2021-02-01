import 'dart:typed_data';

import 'package:flutter_chat/main.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

getStringFromKey(Uint8List serializedData) {
  return new String.fromCharCodes(serializedData);
}

Uint8List getUInt8ListFromString(String data) {
  List<int> list = data.codeUnits;
  Uint8List bytes = Uint8List.fromList(list);
  return bytes;
}

class Person {
  IdentityKeyPair identityKeyPair;
  int registrationId;
  List<PreKeyRecord> preKeys;
  int spkId;

  String strPreKeys = "";
  SignedPreKeyRecord signedPreKey;
  SignalProtocolAddress address;

  Person({String name = "", int deviceId = 0, int signedPreKeyId = 0}) {
    identityKeyPair = KeyHelper.generateIdentityKeyPair();
    registrationId = KeyHelper.generateRegistrationId(false);
    preKeys = KeyHelper.generatePreKeys(1, 5);
    signedPreKey = KeyHelper.generateSignedPreKey(identityKeyPair, signedPreKeyId);
    address = new SignalProtocolAddress(name, deviceId);
  }

  setAddressName(String name, int deviceId) {
    address = SignalProtocolAddress(name, deviceId);
  }

  String getIdentityKeyPair() {
    return getStringFromKey(identityKeyPair.serialize());
  }

  String getSignedPreKey() {
    return getStringFromKey(signedPreKey.serialize());
  }

  int getRegistrationId() {
    return registrationId;
  }

  String getPreKeys() {
    preKeys.forEach((element) {
      strPreKeys += base64encodeDecode.encode(getStringFromKey(element.serialize())) + " ";
    });
    return strPreKeys.trim().replaceAll(" ", ",");
  }
}

class SignalAlgorithm1 {
  int senderPreKeyIndex = 0;

  encrypt(Person sender, Person recipient, String data) {
    // senderPreKeyIndex = new Random().nextInt(recipient.preKeys.length - 1);
    InMemorySignalProtocolStore protocolStore =
        InMemorySignalProtocolStore(sender.identityKeyPair, sender.registrationId);

    PreKeyBundle bundle = new PreKeyBundle(
        sender.registrationId,
        sender.address.getDeviceId(),
        sender.preKeys[senderPreKeyIndex].id,
        sender.preKeys[senderPreKeyIndex].getKeyPair().publicKey,
        sender.spkId,
        sender.signedPreKey.getKeyPair().publicKey,
        sender.signedPreKey.signature,
        sender.identityKeyPair.getPublicKey());
    // if (protocolStore.containsSession(recipient.address)) {
    SessionBuilder.fromSignalStore(protocolStore, sender.address).processPreKeyBundle(bundle);
    // }
    SessionCipher cipher = SessionCipher.fromStore(protocolStore, sender.address);
    CiphertextMessage encryptedMessage = cipher.encrypt(getUInt8ListFromString(data));
    return getStringFromKey(encryptedMessage.serialize());
  }

  decrypt(Person sender, Person recipient, String data) {
    // senderPreKeyIndex = new Random().nextInt(sender.preKeys.length - 1);
    InMemorySignalProtocolStore protocolStore =
        InMemorySignalProtocolStore(sender.identityKeyPair, sender.registrationId);
    protocolStore.storePreKey(sender.preKeys[senderPreKeyIndex].id, sender.preKeys[senderPreKeyIndex]);
    protocolStore.storeSignedPreKey(sender.spkId, sender.signedPreKey);
    SessionCipher cipher = SessionCipher.fromStore(protocolStore, sender.address);

    if (protocolStore.containsSession(sender.address)) {
      var uInt8ListFromString = getUInt8ListFromString(data);
      var decryptedData = cipher.decryptFromSignal(SignalMessage.fromSerialized(uInt8ListFromString));
      return getStringFromKey(decryptedData);
    } else {
      var uInt8ListFromString = getUInt8ListFromString(data);
      var decryptedData = cipher.decrypt(PreKeySignalMessage(uInt8ListFromString));
      return getStringFromKey(decryptedData);
    }
  }
}
