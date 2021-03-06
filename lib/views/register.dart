import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social/_routing/routes.dart';
import 'package:flutter_social/utils/colors.dart';
import 'package:flutter_social/views/login.dart';
import 'package:line_icons/line_icons.dart';

class RegisterPage extends StatefulWidget {

  RegisterPage({Key key}) : super(key: key);
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController telController = TextEditingController();

  List catData; //collect data for dropdown
  List<DropdownMenuItem<String>> catToDo = []; //bring data to dropdown
  String catDataSelected; // keep data for dropdown select

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

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
  }

  final _formKey = GlobalKey<FormState>();
  int _genderRadioBtnVal = -1;

  void _handleGenderChange(int value) {
    setState(() {
      _genderRadioBtnVal = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = Padding(
      padding: EdgeInsets.only(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          )
        ],
      ),
    );

    signUp(lang) {

      String name = nameController.text.trim();
      String tel =telController.text.trim();
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String confirmPassword = confirmpasswordController.text.trim();
      String img ="https://firebasestorage.googleapis.com/v0/b/talkwithme-74c93.appspot.com/o/images%2Fprofile.png?alt=media&token=12ccd588-549e-43d0-a314-73f01528c29e";


      if (password == confirmPassword && password.length >= 6) {
        _auth.createUserWithEmailAndPassword(email: email, password: password).then((currentUser) => Firestore.instance
            .collection("user2")
            .document(currentUser.user.uid)
            .setData({
          "uid": currentUser.user.uid,
          "name": name,
          "tel": tel,
          "email": email,
          "imgProfile":img,
          "lang":lang,
        })).then((result) => {
        print("Password and Confirm-password is not match."),
        Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
        builder: (context) => LoginPage()),(_) => false),

        })
            .catchError((error) {
          print(error.message);
        });
      } else {
        print("Password and Confirm-password is not match.");
      }
    }

    final pageTitle = Container(
      child: Text(
        "Tell us about you.",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 40.0,
        ),
      ),
    );

    final formFieldSpacing = SizedBox(
      height: 30.0,
    );

    final dp = Container(
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

    Container buildTextFieldName() {
      return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
          child: TextField(
              controller: nameController,
              decoration: InputDecoration.collapsed(hintText: "name"),
              keyboardType: TextInputType.text,
              style: TextStyle(fontSize: 18)));
    }

    Container buildTextFieldEmail() {
      return Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
              color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
          child: TextField(
              controller: emailController,
              decoration: InputDecoration.collapsed(hintText: "Email"),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: 18)));
    }

    Container buildTextFieldTel() {
      return Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
              color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
          child: TextField(
              controller: telController,
              decoration: InputDecoration.collapsed(hintText: "Tel"),
              keyboardType: TextInputType.phone,
              style: TextStyle(fontSize: 18)));
    }

    Container buildTextFieldPassword() {
      return Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
              color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
          child: TextField(
            controller: passwordController,
              obscureText: true,
              decoration: InputDecoration.collapsed(hintText: "Password"),
              style: TextStyle(fontSize: 18)));
    }

    Container buildTextFieldPasswordConfirm() {
      return Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
              color: Colors.yellow[50], borderRadius: BorderRadius.circular(16)),
          child: TextField(
            controller: confirmpasswordController,
              obscureText: true,
              decoration: InputDecoration.collapsed(hintText: "Re-password"),
              style: TextStyle(fontSize: 18)));
    }

    final gender = Padding(
      padding: EdgeInsets.only(top: 0.0),
      child: Row(
        children: <Widget>[
          Radio(
            value: 0,
            groupValue: _genderRadioBtnVal,
            onChanged: _handleGenderChange,
          ),
          Text("Male"),
          Radio(
            value: 1,
            groupValue: _genderRadioBtnVal,
            onChanged: _handleGenderChange,
          ),
          Text("Female"),
          Radio(
            value: 2,
            groupValue: _genderRadioBtnVal,
            onChanged: _handleGenderChange,
          ),
          Text("Other"),
        ],
      ),
    );

    final submitBtn = Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
        height: 60.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          border: Border.all(color: Colors.white),
        ),
        child: Material(
          borderRadius: BorderRadius.circular(7.0),
          color: primaryColor,
          elevation: 10.0,
          shadowColor: Colors.white70,
          child: MaterialButton(
            onPressed: () {
              String lang;
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
              signUp(lang);
            },
            child: Text(
              'CREATE ACCOUNT',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          color: Color(0xFFCAFFD8),
          padding: EdgeInsets.only(top: 40.0),
          child: Column(
            children: <Widget>[
              appBar,
              Container(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    pageTitle,
                    buildTextFieldName(),
                    buildTextFieldEmail(),
                    buildTextFieldTel(),
                    buildTextFieldPassword(),
                    buildTextFieldPasswordConfirm(),
                    gender,
                    dp,
                    submitBtn
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        prefixIcon: Icon(
          icon,
          color: Colors.black38,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black38),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
      keyboardType: TextInputType.text,
      style: TextStyle(color: Colors.black),
      cursorColor: Colors.black,
    );
  }
}
