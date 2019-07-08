import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'list_users.dart';
import 'model/users.dart';

void main() => runApp(new MaterialApp(
      home: MyApp(),
      routes: <String, WidgetBuilder>{
        "\ListUsers": (context) => ListUsers(),
      },
    ));

class MyApp extends StatefulWidget {
  StateModel state;
  Widget child;

  MyApp({this.state, @required this.child});

  static _MyAppState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_StateDataWidget)
            as _StateDataWidget)
        .state;
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleSignIn _googleSignIn = new GoogleSignIn(scopes: ['email']);
  FirebaseDatabase database = new FirebaseDatabase();
  GoogleSignInAccount _googleSignInAccount;
  StateModel state;

  @override
  void initState() {
    super.initState();
  }

  setStateDetails(FirebaseUser firebaseUser, BuildContext context) {
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
                    database
                        .reference()
                        .child("users")
                        .child(fbUser.uid)
                        .set(setUserValue(fbUser).toJson());

                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    preferences.setString("EMAIL", fbUser.email);
                    preferences.setString("UID", fbUser.uid);
                    preferences.setBool("IS_LOGIN", true);

                    Navigator.of(context).pushReplacement(new MaterialPageRoute(
                        builder: (context) => ListUsers()));
                  }).catchError((Object error) {
                    print("Error : " + error.toString());
                  });
                },
                child: Text("Login With Google"),
                color: Colors.deepOrange,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32))),
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
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => ListUsers()));
    }
  }

  Future<FirebaseUser> signInWithGoogle() async {
    _googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication authentication =
        await _googleSignInAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken);
    FirebaseAuth _auth = FirebaseAuth.instance;
    return _auth.signInWithCredential(credential);
  }

  Users setUserValue(FirebaseUser fbUser) {
    return new Users(fbUser.email, false, DateTime.now().millisecondsSinceEpoch,
        fbUser.displayName, true, fbUser.phoneNumber, false, fbUser.uid);
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
  FirebaseUser user;

  StateModel({this.isLoading = false, this.user});
}
