import 'dart:math';
import 'dart:typed_data';

import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

getStringFromKey(Uint8List serializedData) {
  return new String.fromCharCodes(serializedData);
}

getUInt8ListFromString(String data) {
  List<int> list = data.codeUnits;
  Uint8List bytes = Uint8List.fromList(list);
  return bytes;
}

class Person {
  IdentityKeyPair identityKeyPair;
  int registrationId;
  List<PreKeyRecord> preKeys;

  String strPreKeys="";
  SignedPreKeyRecord signedPreKey;
  SignalProtocolAddress address;

  Person(String name, int deviceId, int signedPreKeyId) {
    identityKeyPair = KeyHelper.generateIdentityKeyPair();
    registrationId = KeyHelper.generateRegistrationId(false);
    preKeys = KeyHelper.generatePreKeys(1, 5);
    signedPreKey = KeyHelper.generateSignedPreKey(identityKeyPair, signedPreKeyId);
    address = new SignalProtocolAddress(name, deviceId);
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
      strPreKeys += getStringFromKey(element.serialize()) + " ";
    });
    strPreKeys.trim().replaceAll(" ", ",");
    return strPreKeys;
  }
}

class SignalAlgorithm1 {
  int senderPreKeyIndex = 0;

  encrypt(Person sender, Person recipient, String data) {
    senderPreKeyIndex = new Random().nextInt(recipient.preKeys.length - 1);
    InMemorySignalProtocolStore protocolStore =
        InMemorySignalProtocolStore(sender.identityKeyPair, sender.registrationId);
    SessionBuilder sessionBuilder = SessionBuilder.fromSignalStore(protocolStore, recipient.address);

    PreKeyBundle bundle = new PreKeyBundle(
        recipient.registrationId,
        recipient.address.getDeviceId(),
        recipient.preKeys[senderPreKeyIndex].id,
        recipient.preKeys[senderPreKeyIndex].getKeyPair().publicKey,
        recipient.signedPreKey.id,
        recipient.signedPreKey.getKeyPair().publicKey,
        recipient.signedPreKey.signature,
        recipient.identityKeyPair.getPublicKey());

    sessionBuilder.processPreKeyBundle(bundle);

    SessionCipher cipher = SessionCipher.fromStore(protocolStore, recipient.address);
    CiphertextMessage encryptedMessage = cipher.encrypt(getUInt8ListFromString(data));
    return getStringFromKey(encryptedMessage.serialize());
  }

  decrypt(Person sender, Person recipient, String data) {
    InMemorySignalProtocolStore protocolStore =
        InMemorySignalProtocolStore(recipient.identityKeyPair, recipient.registrationId);
    protocolStore.storePreKey(recipient.preKeys[senderPreKeyIndex].id, recipient.preKeys[senderPreKeyIndex]);
    protocolStore.storeSignedPreKey(recipient.signedPreKey.id, recipient.signedPreKey);

    SessionCipher cipher = SessionCipher.fromStore(protocolStore, sender.address);
    var uInt8ListFromString = getUInt8ListFromString(data);
    var decryptedData = cipher.decrypt(PreKeySignalMessage(uInt8ListFromString));
    return getStringFromKey(decryptedData);
  }
}
