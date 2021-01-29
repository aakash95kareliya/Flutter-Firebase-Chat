import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat.dart';
import 'model/users.dart';

class ListUsers extends StatefulWidget {
  @override
  _ListUsersState createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {
  FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Users> listUser = new List();
  String email, uId;

  @override
  void initState() {
    super.initState();
    getSharedPref().then((pref) {
      email = pref.getString("EMAIL");
      uId = pref.getString("UID");
    }).catchError((error) {
      print("Error : " + error.toString());
    });
    _database.reference().child("users").onChildAdded.listen(_onEntryAdded);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Friends List"),
        ),
        body: listUser.length > 0
            ? ListView.builder(
                // ignore: missing_return
                itemBuilder: (context, position) {
                  return createUser(listUser[position], context);
                },
                itemCount: listUser.length,
              )
            : createCircularIndicator());
  }

  Future<SharedPreferences> getSharedPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences;
  }

  Future<DataSnapshot> getListUser() async {
    DatabaseReference userReference =
        await _database.reference().child("users");
    return userReference.once();
  }

  _onEntryAdded(Event event) {
    setState(() {
      listUser.add(new Users.fromJson(event.snapshot));
    });
  }

  createUser(Users users, BuildContext context) {
    return GestureDetector(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 8,
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.teal),
                  alignment: Alignment.center,
                  child: Text(
                    users.name.substring(0, 1),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      users.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      users.email,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                SizedBox(
                  width: 8,
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 12, left: 16, right: 16),
              width: double.infinity,
              height: 1,
              color: Colors.black.withOpacity(0.2),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ChatApp(users)));
      },
    );
  }

  createCircularIndicator() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
