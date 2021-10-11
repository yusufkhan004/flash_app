import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn);

  final void Function(File pickedImage) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;
  void _imgFromGallery() async {
    final pickedImageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imagePickFn(_pickedImage);
  }

  void _imgFromCamera() async {
    final pickedImageFile =
        await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imagePickFn(_pickedImage);
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            _showPicker(context);
          },
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            backgroundImage:
                _pickedImage != null ? FileImage(_pickedImage) : null,
          ),
        ),
      ],
    );
  }
}
