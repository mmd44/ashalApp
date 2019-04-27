import 'package:ashal/core/controllers/collection_controller.dart';
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
          _buildHistoryFields(),
          _buildAmountTBC(),
          _buildConfirmButton(),
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
        title: 'Success',
        message: msg,
        onConfirm: () => Navigator.of(context).pop());
  }

  @override
  void onError(String error) {
    _initTextFieldControllers();
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
    _amountController = TextEditingController(text: formatAmountWithCurrency(_controller.amount));
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
            hintText: 'Line Status',
            helperText: 'Line Status',
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
          hintText: 'AMPs',
          helperText: 'AMPs',
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
            hintText: 'Sub Type',
            helperText: 'Sub Type',
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
              hintText: 'Sub Fee',
              helperText: 'Subscription Fee',
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
              hintText: 'Discount',
              helperText: 'Discount',
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
              hintText: 'Flat Price',
              helperText: 'Flat Price',
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
              hintText: 'Old Meter',
              helperText: 'Old Meter',
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
              hintText: 'New Meter',
              helperText: 'New Meter',
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
            hintText: 'Bill',
            helperText: 'Bill',
          )),
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
      onChanged: (value){
        _controller.setCollection(value);
      },
      style: TextStyle(fontSize: 16),
      decoration: cTheme.TextStyles.textField.copyWith(
        hintText: 'Enter Amount',
        errorText: _amountController.text.isEmpty || _controller.isValidCollection
            ? null
            : 'Must be less than or equal bill',
        prefixText:'LBP ',
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
}
