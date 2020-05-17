import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social/views/login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'updateInfo.dart';



final String _kanit = 'Kanit';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController telController = TextEditingController();
  File _image;
  String image;
  String userID = '';
  List<DocumentSnapshot> snapshots;
  String img, name, tel, email,status;
  NewUpdateInfo updateInfo = new NewUpdateInfo();


  List catData; //collect data for dropdown
  List<DropdownMenuItem<String>> catToDo = []; //bring data to dropdown
  String catDataSelected; // keep data for dropdown select

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

  Future uploadImage(BuildContext context) async {
    String fileName = _image.path;
    final StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('CustomerProfile/${fileName.toString()}');
    StorageUploadTask task = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot snapshotTask = await task.onComplete;
    String downloadUrl = await snapshotTask.ref.getDownloadURL();
    if (downloadUrl != null) {
      updateInfo.updateProfilePic(downloadUrl.toString(), context).then((val) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => EditProfile()),
            ModalRoute.withName('/'));
      }).catchError((e) {
        print('upload error ${e}');
      });
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

  TextEditingController _controller = TextEditingController();
  DocumentSnapshot _currentDocument;


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

    catData = [
      'online',
      'offline',
    ];
    for (int i = 0; i < catData.length; i++) {
      catToDo.add(
        DropdownMenuItem(
          child: Text(
            catData[i],
            style: TextStyle(
              color: Colors.blueGrey[300],
            ),
          ),
          value: catData[i],
        ),
      );
    }
    //catDataSelected = catData[0];
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
            status: snapshot.data['status'],
          );
        },
      ),
    );
  }

  Widget profile({img, name, tel, email, status}) {

    final dp = Container(
      height: 60.0,
      color: Colors.yellow[50],
      child: (
          DropdownMenuItem(
            child: DropdownButton(
              hint: Text('Languages'),
              items: catToDo,
              value: catDataSelected,
              isExpanded: true,
              onChanged: (data) {
                setState(() {
                  catDataSelected = data;
                });
              },
            ),
          )),
    );
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
              SizedBox(height: 12),
              buildTextFieldName(name),
              buildTextFieldTel(tel),
              buildTextFieldEmail(email),
              SizedBox(height: 20),
              dp,
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
                            onPressed: (){
                              _updateData();
                              uploadImage(context);
                            },

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
            readOnly: true,
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
