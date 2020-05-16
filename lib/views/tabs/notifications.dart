
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_social/models/chat.dart';
import 'package:flutter_social/models/slide.dart';


import 'package:flutter_social/src/pages/call.dart';
import 'package:flutter_social/views/languages.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../main.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.name}): super(key: key);
  final String name;
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: SideMenu(),
      appBar: new AppBar(
        title: new Text("User"),
      ),
      body: ListPage(),
    );
  }
}



class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {

  Future _data;

  Future getPost() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection('user1').getDocuments();
    return qn.documents;
  }

  navigateToDetail(DocumentSnapshot post){
    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(post: post,)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _data = getPost();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
          future: _data,
          builder: (_, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(
                child: Text("Loading.."),
              );
            }else{
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index){
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                        NetworkImage(
                          snapshot.data[index].data['imgProfile'],
                        ),
                      ),
                      title: Text(snapshot.data[index].data['name'],),
                      onTap: () => navigateToDetail(snapshot.data[index]),

                    );
                  });
            }
          },
        ));
  }
}

class DetailPage extends StatefulWidget {

  final DocumentSnapshot post;
  DetailPage({this.post});
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  TextEditingController writeCon = new TextEditingController();
  String userID = '';
  Future _data;

  inputData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid.toString();
    print(uid);
    setState(() {
      userID = uid.toString();
    });
  }

  Future<void> onJoin() async {
    // update input validation


    // await for camera and mic permissions before pushing video page
    await _handleCameraAndMic();
    // push video page with given channel name
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          channelName: userID,
        ),
      ),
    );

  }

  final db = Firestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    inputData();
    _data = getReviwe();
  }

  Future getReviwe() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection('user1').document(widget.post.data['uid']).collection('review').getDocuments();
    return qn.documents;
  }

  _updateData() async {
    await db
        .collection('user1')
        .document(widget.post.data['uid'])
        .updateData({
    }).then((value) {
      db
          .collection("user1")
          .document(widget.post.data['uid'])
          .collection("review")
          .add({"review": writeCon.text.trim()});
    });

  }

  _call() async {

    print(widget.post.data['uid']);
    Firestore.instance.collection('user1').document(userID).snapshots();

    await db
        .collection('user1')
        .document(widget.post.data['uid'])
        .updateData({
      "room" : FieldValue.arrayUnion([userID])
    });

  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.data['name']),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
//                  Image.network(widget.post.data['imgProfile'],width: 150.0,),
                  CircleAvatar(
                    radius: 60.0,
                    child:ClipOval(
                      child: new SizedBox(
                        width: 150.0,
                        height: 150.0,
                        child:Image.network(widget.post.data['imgProfile']),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 222,
                    height: 220,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.post.data['name'],
                          style: TextStyle(fontSize: 32),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          widget.post.data['name'],
                          style: TextStyle(fontSize: 19, color: Colors.grey),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(icon: Icon(Icons.chat),color: Colors.blue, onPressed: (){

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Chat(peerAvatar: widget.post.data['imgProfile'],peerId: widget.post.data['uid'],peerName: widget.post.data['name'],),
                                  ));
                            }),
                            IconButton(icon: Icon(Icons.call),highlightColor: Color(0xffFFECDD), onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CallPage(channelName: widget.post.data['uid']),
                                  ));
                            }),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 26,
              ),
              Text(
                "About",
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Dr. Stefeni Albert is a cardiologist in Nashville & affiliated with multiple hospitals in the  area.He received his medical degree from Duke University School of Medicine and has been in practice for more than 20 years. ",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(
                height: 24,
              ),

            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _handleCameraAndMic() async {
  await PermissionHandler().requestPermissions(
    [PermissionGroup.camera, PermissionGroup.microphone],
  );
}

class IconTile extends StatelessWidget {
  String imgAssetPath;
  Color backColor;

  IconTile({this.imgAssetPath, this.backColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16),
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
            color: backColor, borderRadius: BorderRadius.circular(15)),
        child: Image.asset(
          imgAssetPath,
          width: 20,
        ),
      ),
    );
  }
}

class Review extends StatefulWidget {

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {

  String message;
  String title;
  String channelId = "1000";
  String channelName = "FLUTTER_NOTIFICATION_CHANNEL";
  String channelDescription = "FLUTTER_NOTIFICATION_CHANNEL_DETAIL";

  @override
  initState() {
    message = "No message.";

    var initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');

    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) {
          print("onDidReceiveLocalNotification called.");
        });
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) {
          // when user tap on notification.
          print("onSelectNotification called.");
          setState(() {
            message = payload;
          });
        });
    super.initState();
  }

  sendNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('10000',
        'FLUTTER_NOTIFICATION_CHANNEL', 'FLUTTER_NOTIFICATION_CHANNEL_DETAIL',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(111, 'Hello, benznest.',
        'This is a your notifications. ', platformChannelSpecifics,
        payload: 'I just haven\'t Met You Yet');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('111'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              message,
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          sendNotification();
        },
        tooltip: 'Increment',
        child: Icon(Icons.send),
      ),
    );
  }
}





