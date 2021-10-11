import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import "package:google_maps_flutter/google_maps_flutter.dart";
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flash_chat/screens/location.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

final _firestore = Firestore.instance;

class Profile extends StatefulWidget {
  static String id = 'profile_screen';
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _auth = FirebaseAuth.instance;
  Map<String, Object> data = {};
  Future<Map<String, String>> place;
  Position position;
  String featureName;
  String countryName;
  String postalCode;
  String state;
  String district;
  String username;
  String userImage;
  String _message = "";
  int _progress = 0;
  bool showProgress = false;
  // void getUserName() async {
  //   try {
  //     final user = await _auth.currentUser();
  //     // if (user != null) {
  //     final userData =
  //         await Firestore.instance.collection('users').document(user.uid).get();
  //     username = userData['username'];
  //     userImage = userData['image_url'];
  //     // }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   getUserName();
  // }

  void _downloadImage() async {
    try {
      // Saved with this method.
      var imageId = await ImageDownloader.downloadImage(userImage,
          destination: AndroidDestinationType.directoryDownloads
            ..subDirectory('$username.jpg'));
      if (imageId == null) {
        Alert(
          context: context,
          type: AlertType.warning,
          title: "There was a problem downloading image",
          buttons: [
            DialogButton(
              child: Text(
                "Okay",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
        return;
      }
      setState(() {
        _message = "Image download successful";
      });
    } on PlatformException catch (error) {
      setState(() {
        _message = error.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    ImageDownloader.callback(onProgressUpdate: (String imageId, int progress) {
      setState(() {
        _progress = progress;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context).settings.arguments;
    position = data['location'];
    featureName = data['featureName'];
    postalCode = data['postalCode'];
    district = data['district'];
    state = data['state'];
    countryName = data['countryName'];
    username = data['username'];
    userImage = data['userImage'];
    var deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(username.toUpperCase()),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Stack(children: <Widget>[
                Container(
                  width: deviceWidth,
                  height: deviceWidth,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Image.network(
                      userImage,
                      scale: 1.0,
                      //                    width: deviceWidth,
                      //                    height: deviceWidth,
                    ),
                  ),
                ),
                Container(
                  width: deviceWidth,
                  margin: EdgeInsets.only(top: deviceWidth + 10),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.lightBlueAccent),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        '@' + username,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                        ),
                      ),
                      showProgress
                          ? _progress == 100
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : Text(
                                  '$_progress %',
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.white),
                                )
                          : FlatButton(
                              onPressed: () {
                                setState(() {
                                  showProgress = true;
                                });
                                _downloadImage();
                              },
                              child: Icon(
                                Icons.download,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                    ],
                  ),
                )
              ]),
              Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        _message,
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.location_on,
                        size: 30,
                      ),
                      title: Text(
                        featureName,
                      ),
                      subtitle: Text(
                        '$postalCode, $district, $state',
                      ),
                    ),
                    MaterialButton(
                      child: Text(
                        'Show on map',
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, Location.id,
                            arguments: {'location': position});
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
