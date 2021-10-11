import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flash_chat/screens/calculator.dart';
import 'package:flash_chat/screens/chatbot.dart';
import 'package:flash_chat/screens/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flash_chat/constants.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;
  String username;
  String userEmail;
  String userImage;
  final GlobalKey<State> conversationLoader = new GlobalKey<State>();

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      final userData =
          await Firestore.instance.collection('users').document(user.uid).get();
      if (user != null) {
        loggedInUser = user;
        username = userData['username'];
        userImage = userData['image_url'];
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();
    fbm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: FlatButton(
          child: Icon(
            Icons.chat_bubble,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushNamed(context, ChatBot.id);
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(username: username),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Calculator.id);
                      },
                      child: Icon(
                        Icons.calculate,
                        color: Colors.lightBlueAccent,
                        size: 30.0,
                      )),
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender':
                            username != null ? username : loggedInUser.email,
                        'date and time': DateTime.now().toString(),
                        'userImage': userImage,
                      });
                    },
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.lightBlueAccent,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  MessagesStream({this.username});

  final username;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final messages = snapshot.data.documents.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];
          final messageDateTime = message.data['date and time'];
          final userImg = message.data['userImage'];

          final currentUser = loggedInUser.email;
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: messageSender == username,
            dateTime: messageDateTime.toString().split('.')[0],
            userImage: userImg,
          );
          messageBubbles.add(messageBubble);
          messageBubbles.sort((a, b) =>
              DateTime.parse(b.dateTime).compareTo(DateTime.parse(a.dateTime)));
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {this.sender,
      this.text,
      this.isMe,
      @required this.dateTime,
      this.userImage});

  final String sender;
  final String text;
  final String dateTime;
  final bool isMe;
  final String userImage;

  @override
  Widget build(BuildContext context) {
    var addresses;
    var first;

    Future<Map<String, String>> _getPlaceMark(Position position) async {
      final CameraPosition _myLocation = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
      );
      final coordinates =
          new Coordinates(position.latitude, position.longitude);
      addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      first = addresses.first;
      return {
        'featureName': first.featureName,
        'countryName': first.countryName,
        'postalCode': first.postalCode,
        'state': first.adminArea,
        'district': first.subAdminArea,
        'username': sender,
        'userImage': userImage,
      };
    }

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            (isMe) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment:
                (isMe) ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: isMe
                ? <Widget>[
                    Text(
                      sender,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.blueAccent,
                      backgroundImage: NetworkImage(userImage),
                    ),
                  ]
                : <Widget>[
                    GestureDetector(
                      onTap: () async {
                        Position position = await Geolocator.getCurrentPosition(
                            desiredAccuracy: LocationAccuracy.high);
                        Future<Map<String, String>> placeMark =
                            _getPlaceMark(position);
                        String featureName;
                        String countryName;
                        String postalCode;
                        String state;
                        String district;
                        String username;
                        String userPhoto;
                        await placeMark.then((value) => {
                              featureName = value['featureName'],
                              countryName = value['countryName'],
                              postalCode = value['postalCode'],
                              state = value['state'],
                              district = value['district'],
                              username = value['username'],
                              userPhoto = value['userImage'],
                            });
                        Navigator.pushNamed(context, Profile.id, arguments: {
                          'location': position,
                          'featureName': featureName,
                          'countryName': countryName,
                          'postalCode': postalCode,
                          'state': state,
                          'district': district,
                          'username': username,
                          'userImage': userPhoto,
                        });
                      },
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.blueAccent,
                        backgroundImage: NetworkImage(userImage),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      sender,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
          ),
          SizedBox(
            height: 4,
          ),
          Material(
            borderRadius: (isMe)
                ? BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0)),
            elevation: 5.0,
            color: (isMe) ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(
                children: [
                  Text(
                    '$text',
                    style: TextStyle(
                      color: (isMe) ? Colors.white : Colors.lightBlueAccent,
                      fontSize: 15.0,
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    dateTime.split(':')[0] + ":" + dateTime.split(':')[1],
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Positioned(top: 0, left: 0, child: CircleAvatar())
    );
  }
}
