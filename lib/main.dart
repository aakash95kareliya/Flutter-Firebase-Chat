import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/utils/base64_encode_decode.dart';
import 'package:flutter_chat/utils/key_value_encryption.dart';
import 'package:flutter_chat/utils/signal_algorithm1.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'list_users.dart';
import 'model/users.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try{
    await Firebase.initializeApp(
        name: 'db2',
        options: FirebaseOptions(
          appId: '1:128303390154:android:6807f0db0056b661520333',
          apiKey: 'AIzaSyBUPB2tX1gbh3j_RSW-zrjAX05hJvYAVmA',
          messagingSenderId: '128303390154',
          projectId: 'fir-chat-3cc2d',
          databaseURL: 'https://fir-chat-3cc2d-default-rtdb.firebaseio.com',
        ));
  }catch(e){

  }
  runApp(new MaterialApp(
    home: MyApp(),
    routes: <String, WidgetBuilder>{
      "\ListUsers": (context) => ListUsers(),
    },
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseDatabase database = new FirebaseDatabase();
  StateModel state;

  @override
  void initState() {
    super.initState();
  }

  setStateDetails(User firebaseUser, BuildContext context) {
    setState(() {
      state.isLoading = false;
      state.user = firebaseUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    checkLogin(context);
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Builder(builder: (context) {
          return Container(
            child: Center(
              child: RaisedButton(
                onPressed: () {
                  var futureFirebaseUser = signInWithGoogle();
                  futureFirebaseUser.then((fbUser) async {
                    database.reference().child("users").child(fbUser.uid).set(setUserValue(fbUser).toJson());

                    SharedPreferences preferences = await SharedPreferences.getInstance();
                    preferences.setString("EMAIL", fbUser.email);
                    preferences.setString("UID", fbUser.uid);
                    preferences.setBool("IS_LOGIN", true);

                    Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => ListUsers()));
                  }).catchError((Object error) {
                    print("Error : " + error.toString());
                  });
                },
                child: Text("Login With Google"),
                color: Colors.deepOrange,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32))),
                textColor: Colors.white,
              ),
            ),
          );
        }),
      ),
    );
  }

  checkLogin(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getBool("IS_LOGIN") ?? false) {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => ListUsers()));
    }
  }

  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final GoogleAuthCredential googleAuthCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    var userCredential = await FirebaseAuth.instance.signInWithCredential(googleAuthCredential);
    return userCredential.user;
  }

  Users setUserValue(User fbUser) {
    Person person =
        Person(fbUser.uid, DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch ~/ 1000);
    Base64EncodeDecode base64encodeDecode = Base64EncodeDecode();
    CustomAESEncryption encryption = CustomAESEncryption();

    var ikp = base64encodeDecode.encode(person.getIdentityKeyPair());
    var pks = base64encodeDecode.encode(person.getPreKeys());
    var rId = base64encodeDecode.encode(person.getRegistrationId().toString());
    var spk = base64encodeDecode.encode(person.getSignedPreKey());

    return new Users(
        fbUser.email,
        false,
        DateTime.now().millisecondsSinceEpoch,
        fbUser.displayName,
        true,
        fbUser.phoneNumber,
        false,
        fbUser.uid,
        encryption.encrypt(ikp),
        encryption.encrypt(spk),
        encryption.encrypt(pks),
        encryption.encrypt(rId));
  }
}

class _StateDataWidget extends InheritedWidget {
  _MyAppState state;

  _StateDataWidget({
    Key key,
    @required Widget child,
    @required this.state,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

class StateModel {
  bool isLoading;
  User user;

  StateModel({this.isLoading = false, this.user});
}
