import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social/views/login.dart';
import 'package:flutter_social/views/tabs/edit.dart';
import 'package:flutter_social/views/tabs/notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SideMenu extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('AccountName'),
            accountEmail: Text('email@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://www.ninenik.com/images/ninenik_page_logo.jpg"
              ),
              backgroundColor: Colors.white,
            ),
          ),
          ListTile(
            leading: Icon(FontAwesomeIcons.idCard),
            title: Text('Feed'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp(),)
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