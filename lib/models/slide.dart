import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social/views/login.dart';
import 'package:flutter_social/views/tabs/edit.dart';
import 'package:flutter_social/views/tabs/notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SideMenu extends StatefulWidget {



  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String userID = '';

  inputData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid.toString();
    print(uid);
    setState(() {
      userID = uid.toString();
    });
  }

  @override
  void initState() {
    inputData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
       StreamBuilder(
        stream:
        Firestore.instance.collection('user2').document(userID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          return menu(
            email: snapshot.data['email'],
            name: snapshot.data['name'],
            img: snapshot.data['imgProfile'],
          );
        },
      ),
    );
  }





  Widget menu({email, name, img,}) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(name),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                  img
              ),
              backgroundColor: Colors.white,
            ),
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.idCard),
            title: Text('Feed'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp())
              );
            },
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.user),
            title: Text('Profile'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(),));
            },
          ),
          Divider(),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ListTile(
                leading: Icon(FontAwesomeIcons.cog),
                title: Text('Sign Out'),
                onTap: () {
                  FirebaseAuth.instance
                      .signOut()
                      .then((result) => Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => LoginPage())))
                      .catchError((err) => print(err));

                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}