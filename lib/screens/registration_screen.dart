import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash_chat/components/user_image_picker.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;

  String name = "";
  String email = "";
  bool showSpinner = false;
  String password = "";
  File userImageFile;

  void _pickedImage(File image) {
    setState(() {
      userImageFile = image;
    });
  }

  Future<Map<String, dynamic>> extraData(url) async {
    Map<String, dynamic> data = <String, dynamic>{
      'username': name,
      'email': email,
      'image_url': url,
    };
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 100.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              UserImagePicker(_pickedImage),
              SizedBox(
                height: 24.0,
              ),
              TextField(
                key: ValueKey('name'),
                keyboardType: TextInputType.name,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  name = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter Username',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter Your Email',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter Your Password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                  colour: Colors.blueAccent,
                  buttonTitle: 'Register',
                  onTap: () async {
                    if (userImageFile == null) {
                      Alert(
                        context: context,
                        type: AlertType.error,
                        title: "Please select image",
                      ).show();
                      return;
                    } else if (name.length == 0 ||
                        email.length == 0 ||
                        password.length == 0) {
                      Alert(
                              context: context,
                              type: AlertType.warning,
                              title: "Please fill the form completely")
                          .show();
                    } else {
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        final newUser = await _auth
                            .createUserWithEmailAndPassword(
                                email: email, password: password)
                            .catchError((error) {
                          if (error.code == 'email-already-in-use') {
                            Alert(
                              context: context,
                              type: AlertType.warning,
                              title: error.message,
                              desc: "Try Logging In",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Cool",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  width: 120,
                                )
                              ],
                            ).show();
                          }
                        });

                        if (newUser != null) {
                          final ref = FirebaseStorage.instance
                              .ref()
                              .child('user_image')
                              .child(newUser.user.uid + '.jpg');
                          await ref.putFile(userImageFile).onComplete;
                          final url = await ref.getDownloadURL();

                          await Firestore.instance
                              .collection('users')
                              .document(newUser.user.uid)
                              .setData(await extraData(url));
                          Navigator.pushNamed(context, ChatScreen.id);
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      } catch (e) {
                        print(e);
                      }
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
