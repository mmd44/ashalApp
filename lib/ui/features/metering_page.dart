import 'dart:io';
import 'package:ashal/core/controllers/collection_controller.dart';
import 'package:ashal/core/controllers/metering_controller.dart';
import 'package:ashal/core/models/history.dart';
import 'package:ashal/localization.dart';
import 'package:ashal/ui/helpers/common/subscriber_info.dart';
import 'package:ashal/ui/helpers/image_ui/image_picker_handler.dart';
import 'package:ashal/ui/helpers/ui_helpers.dart';
import 'package:ashal/ui/models/card_item.dart';
import 'package:ashal/ui/models/card_items.dart';
import 'package:ashal/ui/models/custom_button.dart';
import 'package:ashal/ui/theme.dart' as Theme;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeteringPage extends StatefulWidget {
  final CardItem cardItem;

  MeteringPage(String id) : cardItem = CardItemsDao.getCardByID(id);

  @override
  _MeteringPageState createState() => _MeteringPageState();
}

class _MeteringPageState extends State<MeteringPage>
    with SingleTickerProviderStateMixin
    implements ImagePickerListener, InputPageView {
  MeteringController _controller;

  TextEditingController _ampController;
  TextEditingController _oldMeterController;
  TextEditingController _newMeterController;

  AnimationController _animationController;
  ImagePickerHandler _imagePickerHandler;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _controller = MeteringController(widget.cardItem, this);
    _controller.init();

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _imagePickerHandler = ImagePickerHandler(this, _animationController);
    _imagePickerHandler.init();

    _initTextFieldControllers();
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
          SubscriberInfo(_controller.client, (value) {
            _controller.setClientByReference(value);
            setState(() {});
          }),
          Visibility(
            visible: _controller.client != null,
            child: Column(
              children: <Widget>[
                _buildHistoryFields(),
                _buildNewMeteringRow(),
                _buildCamButton(),
                _buildConfirmButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 40, right: 40),
            child: CustomButton(
              onPressed: _onSubmit,
              disabled: !_controller.isMeteringValid,
              loading: _controller.isLoading,
              label: Text(
                Localization.of(context, 'confirm'),
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
        title: 'success',
        message: msg,
        onConfirm: () => Navigator.of(context).pop());
  }

  @override
  void onError(String error, {bool initTextControllers = true}) {
    if (initTextControllers) _initTextFieldControllers();
    setState(() {});
    showErrorSnackBar(error, context: context);
  }

  @override
  void onSetClientSuccess() {
    _initTextFieldControllers();
    setState(() {});
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

  Widget _buildHistoryFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 46),
      child: Column(
        children: <Widget>[
          _buildLineStatusSwitchTile(),
          _buildSubType(),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: _buildAMPField(),
          ),
          _buildIsPrepaid(),
          _buildOldMeter(),
        ],
      ),
    );
  }

  _buildLineStatusSwitchTile() {
    return Container(
      child: Row(
        children: <Widget>[
          Text(Localization.of(context, 'line_status')),
          Radio(
              value: 'on',
              groupValue: _controller.lineStatus,
              onChanged: (value) {
                setState(() {
                  print('on $value');
                  _controller.lineStatus = value;
                });
              }),
          Text(Localization.of(context, 'on')),
          Radio(
              value: 'off',
              groupValue: _controller.lineStatus,
              onChanged: (value) {
                setState(() {
                  print('off $value');
                  _controller.lineStatus = value;
                });
              }),
          Text(Localization.of(context, 'off')),
        ],
      ),
    );

//    return SwitchListTile(
//      title: Text(Localization.of(context, 'line_status')),
//      value: _controller.lineStatus,
//      onChanged: (val) {
//        setState(() {
//          _controller.lineStatus = !_controller.lineStatus;
//        });
//      },
//    );
  }

  Widget _buildAMPField() {
    return TextField(
      controller: _ampController,
      keyboardType: TextInputType.numberWithOptions(),
      decoration: Theme.TextStyles.textField.copyWith(
          hintText: Localization.of(context, 'amp'),
          helperText: Localization.of(context, 'amp'),
          errorText:
              _controller.isValidAMPField ? null : Localization.of(context, 'amp_input_error')),
      onChanged: (val) {
        int value = int.tryParse(val);
        setState(() {
          _controller.amp = value;
        });
      },
    );
  }

  Widget _buildSubType() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(Localization.of(context, 'subscription_type')),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: DropdownButton<SubscriptionType>(
                value: _controller.subType,
                items: SubscriptionType.values.map((SubscriptionType val) {
                  return new DropdownMenuItem<SubscriptionType>(
                    value: val,
                    child: Text(val.value),
                  );
                }).toList(),
                hint: Text(Localization.of(context, 'type')),
                onChanged: (newVal) {
                  _controller.subType = newVal;
                  setState(() {});
                }),
          ),
        ),
      ],
    );
  }

  void _initTextFieldControllers() {
    _ampController = TextEditingController(text: _controller.ampStr);
    _oldMeterController = TextEditingController(text: _controller.oldMetering);
    _newMeterController =
        TextEditingController(text: _controller?.newMetering?.toString() ?? '');
  }

  Widget _buildIsPrepaid() {
    return Visibility(
      visible: _controller.isTypePrepaid,
      child: Row(
        children: <Widget>[
          Text(Localization.of(context, 'is_prepaid')),
          Radio(
              value: 'yes',
              groupValue: _controller.isPrepaid,
              onChanged: (value) {
                setState(() {
                  _controller.isPrepaid = value;
                });
              }),
          Text(Localization.of(context, 'yes')),
          Radio(
              value: 'no',
              groupValue: _controller.isPrepaid,
              onChanged: (value) {
                setState(() {
                  _controller.isPrepaid = value;
                });
              }),
          Text(Localization.of(context, 'no')),
        ],
      ),
    );
  }

  Widget _buildOldMeter() {
    return Visibility(
      visible: _controller.isSubMetered,
      child: Padding(
        padding: const EdgeInsets.only(top:8, bottom: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: TextField(
                controller: _oldMeterController,
                enabled: false,
                decoration: Theme.TextStyles.textField
                    .copyWith(helperText: Localization.of(context, 'old_metering')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewMeteringRow() {
    return Visibility(
      visible: _controller.isSubMetered,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 4,
              child: _buildNewMeteringField(),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewMeteringField() {
    return TextField(
      keyboardType: TextInputType.number,
      controller: _newMeterController,
      onChanged: _controller.setNewMetering,
      style: TextStyle(fontSize: 16),
      decoration: Theme.TextStyles.textField.copyWith(
        hintText: Localization.of(context, 'reading_new_input'),
        errorText:
            _newMeterController.text.isEmpty || _controller.isValidReading
                ? null : Localization.of(context, 'reading_new_input_error'),
        prefixText: Localization.of(context, 'kwh'),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCamButton() {
    return Visibility(
      visible: _controller.isSubMetered,
      child: Padding(
        padding: const EdgeInsets.only(top:12),
        child: GestureDetector(
          child: _controller.meterImageFile != null
              ? _buildImageCaptured()
              : Container(
                  child: CircleAvatar(
                    child: Icon(Icons.camera_alt),
                  ),
                ),
          onTap: _openCam,
        ),
      ),
    );
  }

  void _openCam() {
    _imagePickerHandler.getImageFromCamera();
  }
}
