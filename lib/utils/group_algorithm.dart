import 'package:flutter_chat/utils/signal_algorithm1.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

class GroupAlgorithm {
  int senderPreKeyIndex = 0;

  encrypt(Person sender, String data) {
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
    SessionBuilder.fromSignalStore(protocolStore, sender.address).processPreKeyBundle(bundle);
    SessionCipher cipher = SessionCipher.fromStore(protocolStore, sender.address);
    CiphertextMessage encryptedMessage = cipher.encrypt(getUInt8ListFromString(data));
    return getStringFromKey(encryptedMessage.serialize());
  }

  decrypt(Person sender, String data) {
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
