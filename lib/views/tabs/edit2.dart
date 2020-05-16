import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social/views/login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

final String _kanit = 'Kanit';

class EditProfile2 extends StatefulWidget {
  @override
  _EditProfile2State createState() => _EditProfile2State();
}

class _EditProfile2State extends State<EditProfile2> {

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController telController = TextEditingController();
  File _image;
  String image;
  String userID = '';
  List<DocumentSnapshot> snapshots;
  String img, name, tel, email;

  inputData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid.toString();
    print(uid);
    setState(() {
      userID = uid.toString();
    });
  }

  _signout() {
    FirebaseAuth.instance
        .signOut()
        .then((result) => Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage())))
        .catchError((err) => print(err));
  }

  Future<void> captureImage(ImageSource imageSource) async {
    try {
      final imageFile = await ImagePicker.pickImage(source: imageSource);
      setState(() {
        _image = imageFile;
      });
    } catch (e) {
      print(e);
    }
  }

  void _showActionSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 设置最小的弹出
              children: <Widget>[
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text("Camera"),
                  onTap: () async {
                    captureImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.photo_library),
                  title: new Text("Gallery"),
                  onTap: () async {
                    captureImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  final db = Firestore.instance;
  _updateData() async {
    await db
        .collection('user2')
        .document(userID)
        .updateData({
      'name': nameController.text.trim(),
      'tel': telController.text.trim(),
    });
  }


  @override
  void initState() {
    inputData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'โปรไฟล์',
          style: TextStyle(fontFamily: _kanit),
        ),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: StreamBuilder(
        stream:
        Firestore.instance.collection('user2').document(userID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          return profile(
            email: snapshot.data['email'],
            name: snapshot.data['name'],
            img: snapshot.data['imgProfile'],
            tel: snapshot.data['tel'],
          );
        },
      ),
    );
  }

  Widget profile({img, name, tel, email}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 12),
              Center(
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 50.0,),
                    Align(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey,
                        child: ClipOval(
                          child: new SizedBox(
                            width: 150.0,
                            height: 150.0,
                            child: (_image!=null)?Image.file(
                              _image,
                              fit: BoxFit.fill,
                            ):Image.network(img),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 60.0),
                      child: IconButton(
                        icon: Icon(
                          FontAwesomeIcons.camera,
                          size: 30.0,
                        ),
                        onPressed: () {
                          _showActionSheet();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                Text(firstname,style: TextStyle(fontFamily: _kanit, fontSize: 22.0),),
//                SizedBox(width: 20.0),
//                Text(lastname,style: TextStyle(fontFamily: _kanit, fontSize: 22.0),),
//              ],
//            ),
              SizedBox(height: 12),
//            _form(
//              title: 'ชื่อ',
//              content: name,
//            ),
//            _form(
//              title: 'tel',
//              content: tel,
//            ),
//            _form(
//              title: 'อีเมลล์',
//              content: email,
//            ),
              buildTextFieldName(name),
              buildTextFieldTel(tel),
             buildTextFieldEmail(email),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width:100.0,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: _kanit,
                                fontSize: 18.0,
                              ),
                            ),
                            onPressed: _updateData,
                          ),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20.0,
                                // has the effect of softening the shadow
                                spreadRadius: 4.0,
                                // has the effect of extending the shadow
                                offset: Offset(
                                  8.0, // horizontal, move right 10
                                  8.0, // vertical, move down 10
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 20.0,),
                        Container(
                          width: 100.0,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: _kanit,
                                fontSize: 18.0,
                              ),
                            ),
                            onPressed: _signout,
                          ),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20.0,
                                // has the effect of softening the shadow
                                spreadRadius: 4.0,
                                // has the effect of extending the shadow
                                offset: Offset(
                                  8.0, // horizontal, move right 10
                                  8.0, // vertical, move down 10
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 100.0,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: _kanit,
                                fontSize: 18.0,
                              ),
                            ),
                            onPressed: _signout,
                          ),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20.0,
                                // has the effect of softening the shadow
                                spreadRadius: 4.0,
                                // has the effect of extending the shadow
                                offset: Offset(
                                  8.0, // horizontal, move right 10
                                  8.0, // vertical, move down 10
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.red,
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 20.0,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildTextFieldName(name) {
    nameController.text = name;
    return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: name,
              prefixIcon: Icon(Icons.account_box),
              labelText: "name",
            ),
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 18,)));
  }

  Container buildTextFieldEmail(email) {
    emailController.text = email;
    return Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextField(
            controller: emailController,
            decoration: InputDecoration(
                hintText: email,
              prefixIcon: Icon(Icons.mail),
              labelText: "email",
            ),
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontSize: 18)));
  }


  Container buildTextFieldTel(tel) {
    telController.text = tel;
    return Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
            color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
        child: TextField(
            controller: telController,
            decoration: InputDecoration(
              hintText: email,
              prefixIcon: Icon(Icons.phone),
              labelText: "tel",
            ),
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: 18)));
  }

  Widget _form({
    title,
    content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontFamily: _kanit,
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
            ),
          ),
          Text(
            content,
            style: TextStyle(
              fontFamily: _kanit,
              fontSize: 18.0,
              color: Colors.black54,
            ),
          ),
          Divider(
            thickness: 2,
            color: Colors.black45,
          ),
        ],
      ),
    );
  }
}
