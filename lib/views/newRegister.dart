import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_social/models/updateInfo.dart';
import 'package:flutter_social/utils/colors.dart';
import 'package:flutter_social/views/login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';



class RegisterPage extends StatefulWidget {

  RegisterPage({Key key}) : super(key: key);
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  List catData; //collect data for dropdown
  List<DropdownMenuItem<String>> catToDo = []; //bring data to dropdown
  String catDataSelected; // keep data for dropdown select



  FirebaseAuth _auth = FirebaseAuth.instance;
  bool showPW = true;
  String lang = "";
  String _age = 'Birth Day';
  String gender;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _Name;
  TextEditingController _Password;
  TextEditingController _Email;
  NewUpdateInfo updateInfo = new NewUpdateInfo();
  File imageProfile;
  var proFile = 'https://firebasestorage.googleapis.com/v0/b/talkwithme-74c93.appspot.com/o/images%2Fprofile.png?alt=media&token=12ccd588-549e-43d0-a314-73f01528c29e';


  Future<void> captureImage(ImageSource imageSource) async {
    try {
      final imageFile = await ImagePicker.pickImage(source: imageSource);
      setState(() {
        imageProfile = imageFile;
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

  Future uploadImage(BuildContext context) async {
    String fileName = imageProfile.path;
    final StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('imgProfile/${fileName.toString()}');
    StorageUploadTask task = firebaseStorageRef.putFile(imageProfile);
    StorageTaskSnapshot snapshotTask = await task.onComplete;
    String downloadUrl = await snapshotTask.ref.getDownloadURL();
    if (downloadUrl != null) {
      updateInfo.updateProfilePic(downloadUrl.toString(), context).then((val) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) =>LoginPage()),
            ModalRoute.withName('/'));
      }).catchError((e) {
        print('upload error ${e}');
      });
    }
  }

  signUp(BuildContext context) async {
    _auth.createUserWithEmailAndPassword(
        email: _Email.text.trim(),
        password: _Password.text.trim())
        .then((currentUser) =>
        Firestore.instance.collection('user2')
            .document(currentUser.user.uid)
            .setData({
          'name': _Name.text.trim(),
          'age': _age.toString().trim(),
          'gender': gender.toString().trim(),
          'email': _Email.text.trim(),
          'uid': currentUser.user.uid,
          'status':'',
          'lang': lang,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'tel': '',
          'role': 'user'
        }).then((user) {
          print('user ok ${currentUser}');
          uploadImage(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context)=>LoginPage()),
              ModalRoute.withName('/'));
        }).catchError((e) {
          print('profile ${e}');
        })
    );
  }

  Widget showImage(BuildContext context) {
    return Center(
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
                  child: (imageProfile!=null)?Image.file(
                    imageProfile,
                    fit: BoxFit.fill,
                  ):Image.network(proFile),
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
    );
  }

  _handleRadioValueChange(String value) {
    setState(() {
      gender = value;
    });
  }




  @override
  void initState() {
    // TODO: implement initState
    gender = 'Man';
    _Name = TextEditingController();
    _Password = TextEditingController();
    _Email = TextEditingController();

    catData = [
      'English',
      'Chiness',
      'Japan',
      'Korea',
      'Indonesia',
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

    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    final dp = Container(
      height: 50.0,
      color: Colors.white,
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


    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Register',
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              Form(
                key: _formKey,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 1.1,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        showImage(context),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Radio(
                              groupValue: gender,
                              value: 'Man',
                              onChanged: _handleRadioValueChange,
                            ),
                            Text(
                              'ชาย',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 30.0, right: 10.0),
                              child: Radio(
                                groupValue: gender,
                                value: 'Girl',
                                onChanged: _handleRadioValueChange,
                              ),
                            ),
                            Text(
                              'หญิง',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ), //GENDER
                        SizedBox(
                          height: 12.0,
                        ),
                        TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          controller: _Name,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Plese check Your Name';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Colors.blueGrey[200],
                            ),
                            hintText: 'Name',
                            focusColor: Colors.black,
                            labelText: 'Name',
                            labelStyle: TextStyle(color: Colors.blueGrey[200]),
                            hintStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ), //FIRST NAME
                        SizedBox(
                          height: 15.0,
                        ),
                        RaisedButton(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          onPressed: () {
                            DatePicker.showDatePicker(context,
                                theme: DatePickerTheme(
                                  containerHeight: 210.0,
                                ),
                                showTitleActions: true,
                                minTime: DateTime(1950, 1, 1),
                                maxTime: DateTime(2021, 12, 31),
                                onConfirm: (date) {
                                  print('Confirm $date');
                                  _age =
                                  '${date.year} - ${date.month} - ${date.day}';
                                  setState(() {});
                                },
                                currentTime: DateTime.now(),
                                locale: LocaleType.en);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 50.0,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.date_range,
                                        size: 18.0,
                                        color: Colors.blueGrey[200],
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          '$_age',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ), //BIRTH DAY
                        SizedBox(
                          height: 10.0,
                        ),
                        TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.emailAddress,
                          controller: _Email,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Plese check Email';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.blueGrey[200],
                            ),
                            hintText: 'Email',
                            focusColor: Colors.black,
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.blueGrey[200]),
                            hintStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ), //
                        SizedBox(
                          height: 10.0,
                        ),
                        TextFormField(
                          maxLines: 1,
                          controller: _Password,
                          obscureText: showPW,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'password not empty';
                            } else if (value.length <= 5) {
                              return 'password less than 5 charecters';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.blueGrey[200],
                            ),
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.blueGrey[200]),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.blueGrey[200]),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  if (showPW == true) {
                                    showPW = false;
                                  } else {
                                    showPW = true;
                                  }
                                });
                              },
                              icon: Icon(
                                showPW
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ), //PasswordEMAIL
                        SizedBox(
                          height: 10.0,
                        ),
                        dp,
                        SizedBox(height: 20.0,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            height: 50.0,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: RaisedButton(
                              color: Colors.green,
                              onPressed: () {


                                if (_formKey.currentState.validate()) {

                                  if(catDataSelected == 'English'){
                                    lang = 'English';
                                  }else if(catDataSelected == 'Chiness'){
                                    lang = 'Chiness';
                                  }else if(catDataSelected == 'Japan'){
                                    lang = 'Japan';
                                  }else if(catDataSelected == 'Korea'){
                                    lang = 'Korea';
                                  }else if(catDataSelected == 'Indonesia'){
                                    lang = 'Indonesia';
                                  }
                                  this.lang;
                                  signUp(context);
                                }
                              },
                              elevation: 1.1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ), //CREATE ACCOUNT
                        SizedBox(
                          height: 120.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
