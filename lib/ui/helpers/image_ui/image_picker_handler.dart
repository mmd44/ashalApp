import 'dart:async';
import 'dart:io';
import 'package:ashal/ui/helpers/image_ui/image_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHandler {
  ImagePickerDialog imagePicker;
  AnimationController _controller;
  ImagePickerListener _listener;

  ImagePickerHandler(this._listener, this._controller);

  openCamera() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    cropImage(image);
  }

  openGallery() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    cropImage(image);
  }

  void init() {
    imagePicker = new ImagePickerDialog(this, _controller);
    imagePicker.initState();
  }

  Future cropImage(File image) async {
    if(image==null)
      return;
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      toolbarTitle: 'Cropper',
      toolbarColor: Colors.blue,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );
    _listener.userImage(croppedFile);
  }

  getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    cropImage(image);
  }
  showDialog(BuildContext context) {
    imagePicker.getImage(context);
  }
}

abstract class ImagePickerListener {
  userImage(File _image);
}