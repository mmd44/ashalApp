import 'package:ashal/core/controllers/collection_controller.dart';
import 'package:ashal/core/models/history.dart';
import 'package:ashal/localization.dart';
import 'package:ashal/ui/helpers/common/subscriber_info.dart';
import 'package:ashal/ui/helpers/string_helper.dart';
import 'package:ashal/ui/helpers/ui_helpers.dart';
import 'package:ashal/ui/models/card_item.dart';
import 'package:ashal/ui/models/card_items.dart';
import 'package:ashal/ui/models/custom_button.dart';
import 'package:ashal/ui/theme.dart' as cTheme;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CollectionPage extends StatefulWidget {
  final CardItem cardItem;

  CollectionPage(String id) : cardItem = CardItemsDao.getCardByID(id);

  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>
    with SingleTickerProviderStateMixin
    implements InputPageView {
  CollectionController _controller;

  TextEditingController _ampController;
  TextEditingController _oldMeterController;
  TextEditingController _newMeterController;
  TextEditingController _lineStatusController;
  TextEditingController _subTypeController;
  TextEditingController _subFeeController;
  TextEditingController _discountController;
  TextEditingController _flatPriceController;
  TextEditingController _billController;
  TextEditingController _collectedAmountController;
  TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _controller = CollectionController(widget.cardItem, this);
    _controller.init();
    _initTextFieldControllers();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: cTheme.Colors.cardPageBackground,
      child: ListView(
        children: <Widget>[
          new Center(
            child: new Hero(
              tag: 'card-icon-${widget.cardItem.id}',
              child: new Image(
                image: new AssetImage(widget.cardItem.image),
                height: cTheme.Dimens.cardHeight,
                width: cTheme.Dimens.cardWidth,
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
                _buildDate(),
                _buildHistoryFields(),
                _buildAmountTBC(),
                _buildConfirmButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSubmit() {
    _controller.submit();
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

  void _initTextFieldControllers() {
    _ampController = TextEditingController(text: _controller.ampStr);
    _oldMeterController = TextEditingController(text: _controller.oldMetering);
    _newMeterController = TextEditingController(text: _controller.newMetering);
    _lineStatusController = TextEditingController(text: _controller.lineStatus);
    _subTypeController = TextEditingController(text: _controller.subType);
    //_subFeeController = TextEditingController(text: _controller.subFee);
    _discountController = TextEditingController(text: _controller.discount);
    _flatPriceController = TextEditingController(text: _controller.flatPrice);
    _billController = TextEditingController(text: _controller.bill);
    _collectedAmountController =
        TextEditingController(text: _controller.collectedAmount);
    _amountController = TextEditingController(
        text: formatAmountWithCurrency(_controller.amount));
  }

  Widget _buildHistoryFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 46),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(flex: 1, child: _buildLineStatusField()),
              Expanded(flex: 1, child: _buildSubTypeField()),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(flex: 1, child: _buildAMPField()),
              Visibility(
                  visible: _controller.isSubFlatPrice,
                  child: Expanded(flex: 1, child: _buildFlatPriceField())),
            ],
          ),
          _buildSubFeeField(),
          _buildDiscountField(),
          Row(
            children: <Widget>[
              Expanded(flex: 1, child: _buildOldMeteringField()),
              Expanded(flex: 1, child: _buildNewMeteringField()),
            ],
          ),
          _buildBillField(),
          _buildCollectedAmountField()
        ],
      ),
    );
  }

  Widget _buildLineStatusField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
          enabled: false,
          controller: _lineStatusController,
          decoration: cTheme.TextStyles.textField.copyWith(
            hintText: Localization.of(context, 'line_status'),
            helperText: Localization.of(context, 'line_status'),
          )),
    );
  }

  Widget _buildAMPField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        enabled: false,
        controller: _ampController,
        decoration: cTheme.TextStyles.textField.copyWith(
          hintText: Localization.of(context, 'amp'),
          helperText: Localization.of(context, 'amp'),
        ),
      ),
    );
  }

  Widget _buildSubTypeField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
          enabled: false,
          controller: _subTypeController,
          decoration: cTheme.TextStyles.textField.copyWith(
            hintText: Localization.of(context, 'sub_type'),
            helperText: Localization.of(context, 'sub_type'),
          )),
    );
  }

  Widget _buildSubFeeField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Visibility(
        visible: _controller.isSubMetered,
        child: TextField(
            enabled: false,
            controller: _subFeeController,
            decoration: cTheme.TextStyles.textField.copyWith(
              hintText: Localization.of(context, 'subscription_fee'),
              helperText: Localization.of(context, 'subscription_fee'),
            )),
      ),
    );
  }

  Widget _buildDiscountField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Visibility(
        visible: !_controller.isSubFlatPrice,
        child: TextField(
            enabled: false,
            controller: _discountController,
            decoration: cTheme.TextStyles.textField.copyWith(
              hintText: Localization.of(context, 'discount'),
              helperText: Localization.of(context, 'discount'),
            )),
      ),
    );
  }

  Widget _buildFlatPriceField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Visibility(
        visible: _controller.isSubFlatPrice,
        child: TextField(
            enabled: false,
            controller: _flatPriceController,
            decoration: cTheme.TextStyles.textField.copyWith(
              hintText: Localization.of(context, 'flat_price'),
              helperText: Localization.of(context, 'flat_price'),
            )),
      ),
    );
  }

  Widget _buildOldMeteringField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Visibility(
        visible: _controller.isSubMetered,
        child: TextField(
            enabled: false,
            controller: _oldMeterController,
            decoration: cTheme.TextStyles.textField.copyWith(
              hintText: Localization.of(context, 'old_meter'),
              helperText: Localization.of(context, 'old_meter'),
            )),
      ),
    );
  }

  Widget _buildNewMeteringField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Visibility(
        visible: _controller.isSubMetered,
        child: TextField(
            enabled: false,
            controller: _newMeterController,
            decoration: cTheme.TextStyles.textField.copyWith(
              hintText: Localization.of(context, 'new_meter'),
              helperText: Localization.of(context, 'new_meter'),
            )),
      ),
    );
  }

  Widget _buildBillField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
          enabled: false,
          controller: _billController,
          decoration: cTheme.TextStyles.textField.copyWith(
              hintText: Localization.of(context, 'bill'),
              helperText: Localization.of(context, 'bill'))),
    );
  }

  Widget _buildCollectedAmountField() {
    return Visibility(
      visible: true,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
            enabled: false,
            controller: _collectedAmountController,
            decoration: cTheme.TextStyles.textField.copyWith(
              hintText: Localization.of(context, 'collected_amount'),
              helperText: Localization.of(context, 'collected_amount'),
            )),
      ),
    );
  }

  Widget _buildAmountTBC() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 3,
            child: _buildAmount(),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmount() {
    return TextField(
      keyboardType: TextInputType.number,
      controller: _amountController,
      onChanged: (value) {
        _controller.setCollection(value);
      },
      style: TextStyle(fontSize: 16),
      decoration: cTheme.TextStyles.textField.copyWith(
        hintText: Localization.of(context, 'enter_amount'),
        errorText:
            _amountController.text.isEmpty || _controller.isValidCollection
                ? null
                : Localization.of(context, 'error_meter_amount'),
        prefixText: Localization.of(context, 'currency'),
        border: OutlineInputBorder(),
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
              disabled: !_controller.isCollectionValid,
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

  static DateFormat dateFormatter = new DateFormat("y-M-d");
  Widget _buildDate() {
    List<DropdownMenuItem<History>> defaultV = new List();
    defaultV.add(new DropdownMenuItem<History>(value: null, child: Text("")));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 55),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(Localization.of(context, 'select_date')),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: DropdownButton<History>(
                  value: _controller.selectedHistory,
                  items: _controller.clientHistoryList == null
                      ? defaultV
                      : _controller.clientHistoryList.map((History val) {
                          return new DropdownMenuItem<History>(
                            value: val,
                            child: Text(val.entryDateTime != null
                                ? dateFormatter.format(val.entryDateTime)
                                : ""),
                          );
                        }).toList(),
                  hint: Text(Localization.of(context, 'date')),
                  onChanged: (newVal) async {
                    await _controller.setupClientSelectedHistory(newVal);
                    setState(() {
                      _initTextFieldControllers();
                    });
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
