import 'dart:convert';
import 'dart:io';

import 'package:ashal/core/controllers/input_pages_controller.dart';
import 'package:ashal/ui/card_detail/image_ui/image_picker_handler.dart';
import 'package:ashal/ui/card_detail/common/subscriber_info.dart';
import 'package:ashal/ui/helpers/ui_helpers.dart';
import 'package:ashal/ui/models/card_item.dart';
import 'package:ashal/ui/models/card_items.dart';
import 'package:ashal/ui/models/custom_button.dart';
import 'package:ashal/ui/theme.dart' as Theme;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeteringCollectionPage extends StatefulWidget {
  final CardItem cardItem;

  MeteringCollectionPage(String id) : cardItem = CardItemsDao.getCardByID(id);

  @override
  _MeteringCollectionPageState createState() => _MeteringCollectionPageState();
}

class _MeteringCollectionPageState extends State<MeteringCollectionPage>
    with SingleTickerProviderStateMixin
    implements ImagePickerListener, InputPageView {
  InputPagesController _controller;

  AnimationController _animationController;
  ImagePickerHandler _imagePickerHandler;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    _controller = new InputPagesController(this);
    _controller.init();


    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
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
          _buildTodayDate(),
          SubscriberInfo(_controller),
          _buildInputField(),
          _buildCamButton(),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration:
                    Theme.TextStyles.textField.copyWith(hintText: 'Reading'),
                onChanged: (value) {
                  _controller.setReadings(value);
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
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

  Widget _buildCamButton() {
    return GestureDetector(
        child:
            Container(child: (CircleAvatar(child: Icon(Icons.photo_camera)))),
        onTap: () async {
          _imagePickerHandler.getImageFromCamera();
        });
  }

  Widget _buildConfirmButton() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: CustomButton(
              onPressed: _onSubmit,
              disabled: !_controller.isCollectionValid,
              loading: _controller.isLoading,
              label: Text(
                'Confirm',
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

  void _onSubmit() {
    _controller.submit();
  }

  @override
  userImage(File image) {
    _controller.setImage(image);
    setState(() {});
  }

  @override
  void onSuccess(String msg) {
    setState(() {});

    showDialogMessage(context,
        title: 'Success',
        message: msg,
        onConfirm: () => Navigator.of(context).pop());
  }

  @override
  void onError(String error) {
    setState(() {});
    showErrorSnackbar(error, context: context);
  }

  @override
  void onReadingsError(String msg) {
    setState(() {});
    showErrorSnackbar(msg, context: context);
  }

  @override
  void onSetClientSuccess() {
    setState(() {});
  }

  @override
  void onSetClientError(String msg) {
    showErrorSnackbar(msg, context: context);
  }

  _buildTodayDate() {
    DateTime today = DateTime.now();
    _controller.todayDate = today;
    return Center(
      child: Text(DateFormat('yyyy-MM-dd – kk:mm').format(today)),
    );
  }
}
