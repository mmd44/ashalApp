import 'package:ashal/core/controllers/collection_controller.dart';
import 'package:ashal/core/controllers/requests_controller.dart';
import 'package:ashal/core/models/history.dart';
import 'package:ashal/ui/helpers/common/subscriber_info.dart';
import 'package:ashal/ui/helpers/ui_helpers.dart';
import 'package:ashal/ui/models/custom_button.dart';
import 'package:ashal/ui/theme.dart' as Theme;
import 'package:ashal/ui/models/card_item.dart';
import 'package:ashal/ui/models/card_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestsPage extends StatefulWidget {
  final CardItem cardItem;

  RequestsPage(String id) : cardItem = CardItemsDao.getCardByID(id);

  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> implements InputPageView {
  RequestsController _controller;

  TextEditingController _ampController;
  TextEditingController _commentController;
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _controller = RequestsController(widget.cardItem, this);
    _controller.init();

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
                _buildConfirmButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildTodayDate() {
    return Center(
      child: Text(DateFormat('dd-MM-yyyy').format(
        DateTime.now(),
      )),
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
          _buildCommentField()
        ],
      ),
    );
  }

  _buildLineStatusSwitchTile() {
    return SwitchListTile.adaptive(
        title: Text('Line Status'),
        value: _controller.lineStatus,
        onChanged: (val) {
          setState(() {
            _controller.lineStatus = !_controller.lineStatus;
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
          errorText:
              _controller.isValidAMPField ? null : 'Must be greater than 0'),
      onChanged: (val) {
        int value = int.tryParse(val);
        setState(() {
          _controller.amp = value;
        });
      },
    );
  }

  Widget _buildCommentField() {
    return Padding(
      padding: const EdgeInsets.only(top:10.0),
      child: TextField(
        controller: _commentController,
        keyboardType: TextInputType.multiline,
        maxLines:null,
        decoration: Theme.TextStyles.textField.copyWith(
            hintText: 'Comment',
            helperText: 'Comment',
            errorText:null),
        onChanged: (val) {
          setState(() {
            _controller.comment = val;
          });
        },
      ),
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
    _commentController=TextEditingController();
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

  Widget _buildConfirmButton() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 40, right: 40),
            child: CustomButton(
              onPressed: _onSubmit,
              //disabled: !_controller.isMeteringValid,
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

  @override
  void onSuccess(String msg) {
    setState(() {});
    showDialogMessage(context,
        title: 'Success',
        message: msg,
        onConfirm: () => Navigator.of(context).pop());
  }
}
