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
    super.initState();
    _init();
  }

  void _init() async {
    _controller = new InputPagesController(widget.cardItem, this);
    _controller.init();

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
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
          _controller.isMetering
              ? _buildTodayDate()
              : Container(width: 0, height: 0),
          SubscriberInfo(_controller),
          _buildInputField(),
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
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: Theme.TextStyles.textField.copyWith(
                    hintText: _controller.isMetering ? 'Reading' : 'Amount'),
                onChanged: (value) => _controller.setInput(value),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(_controller.isMetering ? 'Kwh' : 'L.L',
                  textAlign: TextAlign.center),
            ),
          ),
          Expanded(
            flex: 3,
            child: _controller.isMetering
                ? _buildCamButton()
                : _buildMultiplePaymentCheckbox(),
          ),
        ],
      ),
    );
  }

  Widget _buildCamButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        child: _controller.meterImageFile != null
            ? _buildImageCaptured()
            : Container(child: (CircleAvatar(child: Icon(Icons.camera)))),
        onTap: _openCam,
      ),
    );
  }

  void _openCam() {
    _imagePickerHandler.getImageFromCamera();
  }

  Widget _buildConfirmButton() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 40, right: 40),
            child: CustomButton(
              onPressed: _onSubmit,
              disabled: _controller.isMetering
                  ? !_controller.isMeteringValid
                  : !_controller.isCollectionValid,
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
    return Center(
      child: Text(DateFormat('dd-MM-yyyy').format(
        _controller.todayDate,
      )),
    );
  }

  _buildImageCaptured() {
    return InkWell(
      onTap: _openCam,
      child: Center(
        child: _buildImageFile(),
      ),
    );
  }

  _buildImageFile() {
    return new Container(
      width: 70,
      height: 70,
      decoration: new BoxDecoration(
        color: const Color(0xff7c94b6),
        image: new DecorationImage(
          image: new FileImage(_controller.meterImageFile),
          fit: BoxFit.fill,
        ),
        borderRadius: new BorderRadius.all(new Radius.circular(150.0)),
        border: new Border.all(
          color: Theme.Colors.primary,
          width: 0.0,
        ),
      ),
    );
  }

  _buildMultiplePaymentCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: <Widget>[
          Checkbox(
            onChanged: (value) {
              setState(() {
                _controller.multiplePayment = value;
              });
            },
            value: _controller.isMultiplePayment,
            activeColor: const Color(0xff00bbff),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(
            'Multiple\nPayments?',
            style: TextStyle(
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void showWarningDialog(String msg) {
    showDialogConfirm(
      context,
      message: msg,
      onConfirm: () => _controller.submit(bypassChecks: true),
    );
  }
}
