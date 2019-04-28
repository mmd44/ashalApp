import 'package:ashal/core/controllers/collection_controller.dart';
import 'package:ashal/core/controllers/requests_controller.dart';
import 'package:ashal/core/models/history.dart';
import 'package:ashal/localization.dart';
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
          _buildHistoryFields(),
          _buildConfirmButton()
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
        title: Text(Localization.of(context, 'line_status')),
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

  Widget _buildCommentField() {
    return Padding(
      padding: const EdgeInsets.only(top:10.0),
      child: TextField(
        controller: _commentController,
        keyboardType: TextInputType.multiline,
        maxLines:null,
        decoration: Theme.TextStyles.textField.copyWith(
            hintText: Localization.of(context, 'comment'),
            helperText: Localization.of(context, 'comment'),
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
    _commentController=TextEditingController();
  }

  Widget _buildIsPrepaid() {
    return Visibility(
      visible: _controller.isTypePrepaid,
      child: Row(
        children: <Widget>[
          Text(Localization.of(context, "is_prepaid")),
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
  void onError(String error, {bool initTextControllers = true}) {
    if (initTextControllers) _initTextFieldControllers();
    setState(() {});
    showErrorSnackBar(Localization.of(context, error), context: context);
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
        title: Localization.of(context, 'success'),
        message: Localization.of(context, msg),
        onConfirm: () => Navigator.of(context).pop());
  }
  @override
  void updateView() {
    setState(() {});
  }
}
