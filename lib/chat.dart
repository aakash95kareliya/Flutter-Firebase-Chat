import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/main.dart';
import 'package:flutter_chat/model/users.dart';
import 'package:flutter_chat/utils/signal_algorithm1.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/chat_message.dart';

// ignore: must_be_immutable
class ChatApp extends StatefulWidget {
  Users users;

  ChatApp(Users users) {
    this.users = users;
  }

  @override
  _ChatAppState createState() => _ChatAppState(users);
}

class _ChatAppState extends State<ChatApp> {
  SignalAlgorithm1 signalAlgorithm1 = SignalAlgorithm1();
  String email, uId;
  TextEditingController _controller = new TextEditingController();
  FirebaseDatabase _database = FirebaseDatabase.instance;
  var chatReference;
  List<ChatMessage> listChatMessage = new List();
  Users users;

  Users senderUser;

  Person senderPerson = Person();
  Person receiverPerson = Person();

  _ChatAppState(Users users) {
    this.users = users;
  }

  @override
  void initState() {
    super.initState();

    chatReference = _database.reference().child("chatMessage");
    receiverPerson = getPersonFromUser(receiverPerson, users);
    getSharedPref().then((pref) {
      email = pref.getString("EMAIL");
      uId = pref.getString("UID");
      var reference = _database.reference().child("users").child(uId);
      reference.once().then((value) {
        senderPerson = getPersonFromUser(senderPerson, Users.fromJson(value));
      });
    }).catchError((error) {
      print("Error : " + error.toString());
    });

    chatReference.onChildAdded.listen(_onEntryAdded);
  }

  Person getPersonFromUser(Person sPerson, Users users) {
    sPerson.identityKeyPair = IdentityKeyPair.fromSerialized(users.getIdentityKeyPair());
    sPerson.registrationId = users.getRegistrationId();
    sPerson.signedPreKey = SignedPreKeyRecord.fromSerialized(users.getSPkPair());
    sPerson.setAddressName(users.userId, users.lastSeenTime);
    sPerson.spkId = users.getSpkId();
    sPerson.preKeys = users.getPks().map((e) => PreKeyRecord.fromBuffer(e)).toList();
    return sPerson;
  }

  Person getPersonFromChatMessage(ChatMessage chatMessage) {
    Person sPerson = Person();
    sPerson.identityKeyPair = IdentityKeyPair.fromSerialized(chatMessage.getIdentityKeyPair());
    sPerson.registrationId = chatMessage.getRegistrationId();
    sPerson.signedPreKey = SignedPreKeyRecord.fromSerialized(chatMessage.getSPkPair());
    sPerson.setAddressName(chatMessage.userId, chatMessage.deviceId);
    sPerson.spkId = chatMessage.getSpkId();
    sPerson.preKeys = chatMessage.getPks().map((e) => PreKeyRecord.fromBuffer(e)).toList();
    return sPerson;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(users.name),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, position) {
                if (listChatMessage[position].senderId == uId) {
                  return senderMessage(listChatMessage[position]);
                } else {
                  return receiverMessage(listChatMessage[position]);
                }
              },
              itemCount: listChatMessage.length,
            ),
            flex: 90,
          ),
          Expanded(
            child: createSendMessageView(context),
            flex: 10,
          )
        ],
      ),
    );
  }

  senderMessage(ChatMessage chatMessage) {
    var recipient = getPersonFromChatMessage(chatMessage);
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: EdgeInsets.only(right: 120, top: 16, left: 16),
          decoration: BoxDecoration(
              color: Color(0XFFE7E7E7),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16))),
          child: Text(signalAlgorithm1.decrypt(recipient, senderPerson, chatMessage.message)),
        )
      ],
    );
  }

  receiverMessage(ChatMessage chatMessage) {
    var recipient = getPersonFromChatMessage(chatMessage);
    return Container(
      width: double.infinity,
      alignment: Alignment.topRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            margin: EdgeInsets.only(left: 120, top: 16, right: 16),
            decoration: BoxDecoration(
                color: Color(0XFF5EC7C7),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16))),
            child: Text(signalAlgorithm1.decrypt(recipient, receiverPerson, chatMessage.message)),
          )
        ],
      ),
    );
  }

  createSendMessageView(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: _controller,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  enabledBorder: border,
                  focusedBorder: border,
                  border: border,
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Write message here...',
                ),
              ),
            ),
            flex: 90,
          ),
          Expanded(
            child: GestureDetector(
              child: GestureDetector(
                onTap: () {
                  if (_controller.text.toString().trim().length > 0) {
                    // receiverPerson.generateNewPreKeys();
                    Person person = Person(
                        count: 1,
                        deviceId: receiverPerson.getRegistrationId(),
                        signedPreKeyId: (receiverPerson.spkId ~/ 1000));
                    person.generateNewPreKeys();
                    var strMessage = signalAlgorithm1.encrypt(person, senderPerson, _controller.text.toString());
                    ChatMessage chatMessage =
                        new ChatMessage(users.userId, uId, strMessage, DateTime.now().millisecondsSinceEpoch);
                    encryption.encodeData(chatMessage, person);
                    chatReference.child(DateTime.now().millisecondsSinceEpoch.toString()).set(chatMessage.toJson());
                    _controller.clear();
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(right: 4),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blueGrey, shape: BoxShape.circle),
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            flex: 10,
          ),
        ],
      ),
    );
  }

  var border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  _onEntryAdded(Event event) {
    setState(() {
      listChatMessage.add(new ChatMessage.fromJson(event.snapshot.value));
    });
  }

  Future<SharedPreferences> getSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences;
  }
}
