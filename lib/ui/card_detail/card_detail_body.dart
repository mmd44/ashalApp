import 'dart:convert';
import 'dart:io';

import 'package:ashal/core/controllers/DetailsController.dart';
import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/localization.dart';
import 'package:ashal/ui/card_detail/image_ui/image_picker_dialog.dart';
import 'package:ashal/ui/card_detail/image_ui/image_picker_handler.dart';
import 'package:ashal/ui/card_detail/sync_body.dart';
import 'package:ashal/ui/models/card_item.dart';
import 'package:ashal/ui/card_detail/subscriber_info.dart';
import 'package:ashal/ui/models/custom_button.dart';
import 'package:ashal/ui/models/text_field_with_selection.dart';
import 'package:flutter/material.dart';
import 'package:ashal/ui/theme.dart' as Theme;
import 'package:autocomplete_textfield/autocomplete_textfield.dart';


class CardDetailBody extends StatefulWidget {
  final CardItem cardItem;

  CardDetailBody(this.cardItem);

  @override
  _CardDetailBodyState createState() => _CardDetailBodyState();
}

class _CardDetailBodyState extends State<CardDetailBody> with SingleTickerProviderStateMixin implements ImagePickerListener  {
  DetailsController _controller;
  AnimationController _animationController;
  ImagePickerHandler _imagePickerHandler;
  File _image;
  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    _controller = new DetailsController();
      await _controller.init();
    _animationController = AnimationController(vsync: this,duration: Duration(seconds: 1));
    _imagePickerHandler = ImagePickerHandler(this, _animationController);
    _imagePickerHandler.init();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Theme.Colors.cardPageBackground,
      child: ListView(
        children: <Widget>[
          new Center(
            child: new Hero(
              tag: 'card-icon-${widget.cardItem.id}',
              child: new Image(
                image: new AssetImage(widget.cardItem.image),
                height: Theme.Dimens.cardHeight,
                width: Theme.Dimens.cardWidth,
              ),
            ),
          ),
          widget.cardItem.id != '1' ? SubscriberInfo() : SyncBody(),
          widget.cardItem.id != '1' ? _buildInputField() : Container(),
          widget.cardItem.id != '1' ? _buildCamButton() : Container(),
          widget.cardItem.id != '1' ? _buildButton() : Container(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.only(top:16, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(),
          ),
          Expanded(
            flex: 2,
            child: TextFieldWithSelection((String regex) async {
              List<Client> clients = await DBProvider.db.getClients(regex);
              return clients.map((client) => client.referenceId.toString()).toList();
            }
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom:20),
              child: Text('Kwh', textAlign: TextAlign.center),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildCamButton(){
    return GestureDetector(
      child: Container(
          child: (CircleAvatar(child: Icon(Icons.photo_camera)))
      ),
      onTap: () async{
        _imagePickerHandler.getImageFromCamera();
        }
    );
  }

  Widget _buildButton() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top:16, left:16, right:  16),
            child: CustomButton(
              onPressed: null,
              disabled: true,
              loading: false,
              label: Text('Confirm',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  userImage(File _image) {
    print ('imageSaved!');
    List<int> imageBytes = _image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    this._image=_image;
  }
}
