import 'dart:io';
import 'package:ashal/core/controllers/collection_controller.dart';
import 'package:ashal/core/controllers/input_pages_controller.dart';
import 'package:ashal/core/controllers/metering_controller.dart';
import 'package:ashal/core/models/history.dart';
import 'package:ashal/ui/helpers/image_ui/image_picker_handler.dart';
import 'package:ashal/ui/helpers/common/subscriber_info.dart';
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
          _buildHistoryFields(),
          _buildNewMeteringField(),
          _buildConfirmButton(),
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
    _initTextFieldControllers();
    setState(() {});
  }

  @override
  void onSetClientError(String msg) {
    _initTextFieldControllers();
    setState(() {});
    if (msg != null) showErrorSnackbar(msg, context: context);
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

  @override
  void showWarningDialog(String msg) {
    showDialogConfirm(
      context,
      message: msg,
      onConfirm: () => _controller.submit(bypassChecks: true),
    );
  }

  Widget _buildHistoryFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 46),
      child: Column(
        children: <Widget>[
          _buildLineStatusSwitchTile(),
          _buildSubType(),
          _buildAMPField(),
          _buildIsPrepaid(),
          _buildOldMeter(),
        ],
      ),
    );
  }

  _buildLineStatusSwitchTile() {
    return SwitchListTile(
      title: Text('Line Status'),
      value: _controller.lineStatus,
      onChanged: (val) {
        setState(() {
          _controller.lineStatus = val;
        });
      },
    );
  }

  Widget _buildAMPField() {
    return TextField(
      controller: _ampController,
      keyboardType: TextInputType.numberWithOptions(),
      decoration: Theme.TextStyles.textField.copyWith(
          hintText: 'AMPs',
          helperText: 'AMPs',
          errorText: _controller.isValidAMPField ? null : 'Must be greater than 0'),
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
          child: Text('Subscription Type'),
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
                hint: Text("Type"),
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
  }

  Widget _buildIsPrepaid() {
    return Visibility(
      visible: _controller.isTypePrepaid,
      child: Row(
        children: <Widget>[
          Text('Is Prepaid?'),
          Radio(
              value: 'yes',
              groupValue: _controller.isPrepaid,
              onChanged: (value) {
                setState(() {
                  _controller.isPrepaid = value;
                });
              }),
          Text('Yes'),
          Radio(
              value: 'no',
              groupValue: _controller.isPrepaid,
              onChanged: (value) {
                setState(() {
                  _controller.isPrepaid = value;
                });
              }),
          Text('No'),
        ],
      ),
    );
  }

  Widget _buildOldMeter() {
    return Visibility(
      visible: _controller.isSubMetered,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'Old Metering',
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: TextField(
              controller: _oldMeterController,
              enabled: false,
              decoration: Theme.TextStyles.textField
                  .copyWith(helperText: 'Old Metering'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewMeteringField() {
    return Visibility(
      visible: _controller.isSubMetered,
      child: Padding(
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
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: Theme.TextStyles.textField.copyWith(
                    hintText: 'Reading',
                    errorText: _controller.isValidReading
                        ? null
                        : 'Must be greater than or equal old metering',
                  ),
                  onChanged: (value) => _controller.setNewMetering(value),
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
            Expanded(flex: 3, child: _buildCamButton()),
          ],
        ),
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
}
