import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewUpdateInfo {
  Future updateProfilePic(picUrl, context) {
    var userInfo = new UserUpdateInfo();
    userInfo.photoUrl = picUrl;
    FirebaseAuth.instance.currentUser().then((user){
      user.updateProfile(userInfo);
      FirebaseAuth.instance.currentUser().then((user) {
        user.updateProfile(userInfo);
        Firestore.instance
            .collection('user2')
            .where('uid', isEqualTo: user.uid)
            .getDocuments()
            .then((docs) {
          Firestore.instance
              .document('user2/${docs.documents[0].documentID}')
              .updateData({'imgProfile': picUrl}).then((val) {
            print('ok');
          }).then((user) {
            print('ok wow');
          }).catchError((e) {
            print('can\'t change pages ${e}');
          });
        }).catchError((e) {
          print('users error ${e}');
        });
      }).catchError((e) {
        print('update pic er ${e}');
      });
    }).catchError((e){
      print('first er $e');
    });
  }


}