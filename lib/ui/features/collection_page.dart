import 'package:ashal/core/controllers/collection_controller.dart';
import 'package:ashal/core/controllers/input_pages_controller.dart';
import 'package:ashal/ui/helpers/common/subscriber_info.dart';
import 'package:ashal/ui/helpers/ui_helpers.dart';
import 'package:ashal/ui/models/card_item.dart';
import 'package:ashal/ui/models/card_items.dart';
import 'package:ashal/ui/models/custom_button.dart';
import 'package:ashal/ui/theme.dart' as Theme;
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
          _buildAmountTBC(),
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

  @override
  void showWarningDialog(String msg) {
    showDialogConfirm(
      context,
      message: msg,
      onConfirm: () => _controller.submit(bypassChecks: true),
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
    _billController = TextEditingController(text: _controller.newMetering);
  }

  Widget _buildHistoryFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 46),
      child: Column(
        children: <Widget>[
          _buildLineStatusField(),
          _buildSubTypeField(),
          _buildSubFeeField(),
          _buildDiscountField(),
          _buildFlatPriceField(),
          _buildAMPField(),
          _buildOldMeteringField(),
          _buildNewMeteringField(),
          _buildBillField(),
        ],
      ),
    );
  }

  Widget _buildLineStatusField() {
    return TextField(
        enabled: false,
        controller: _lineStatusController,
        decoration: Theme.TextStyles.textField.copyWith(
          hintText: 'Line Status',
          helperText: 'Line Status',
        ));
  }

  Widget _buildAMPField() {
    return Visibility(
      visible: false,
      child: TextField(
        controller: _ampController,
        keyboardType: TextInputType.numberWithOptions(),
        decoration: Theme.TextStyles.textField.copyWith(
          hintText: 'AMPs',
          helperText: 'AMPs',
        ),
      ),
    );
  }

  Widget _buildSubTypeField() {
    return TextField(
        enabled: false,
        controller: _subTypeController,
        decoration: Theme.TextStyles.textField.copyWith(
          hintText: 'Sub Type',
          helperText: 'Subscription Type',
        ));
  }

  Widget _buildSubFeeField() {
    return Visibility(
      visible: _controller.isSubMetered,
      child: TextField(
          enabled: false,
          controller: _subFeeController,
          decoration: Theme.TextStyles.textField.copyWith(
            hintText: 'Sub Fee',
            helperText: 'Subscription Fee',
          )),
    );
  }

  Widget _buildDiscountField() {
    return Visibility(
      visible: !_controller.isSubFlatPrice,
      child: TextField(
          enabled: false,
          controller: _discountController,
          decoration: Theme.TextStyles.textField.copyWith(
            hintText: 'Discount',
            helperText: 'Discount',
          )),
    );
  }

  Widget _buildFlatPriceField() {
    return Visibility(
      visible: _controller.isSubFlatPrice,
      child: TextField(
          enabled: false,
          controller: _flatPriceController,
          decoration: Theme.TextStyles.textField.copyWith(
            hintText: 'Flat Price',
            helperText: 'Flat Price',
          )),
    );
  }

  Widget _buildOldMeteringField() {
    return Visibility(
      visible: _controller.isSubMetered,
      child: TextField(
          enabled: false,
          controller: _oldMeterController,
          decoration: Theme.TextStyles.textField.copyWith(
            hintText: 'Old Meter',
            helperText: 'Old Meter',
          )),
    );
  }

  Widget _buildNewMeteringField() {
    return Visibility(
      visible: _controller.isSubMetered,
      child: TextField(
          enabled: false,
          controller: _newMeterController,
          decoration: Theme.TextStyles.textField.copyWith(
            hintText: 'New Meter',
            helperText: 'New Meter',
          )),
    );
  }

  Widget _buildBillField() {
    return TextField(
        enabled: false,
        controller: _billController,
        decoration: Theme.TextStyles.textField.copyWith(
          hintText: 'Bill',
          helperText: 'Bill',
        ));
  }

  Widget _buildAmountTBC() {
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
                    errorText: _controller.isValidCollection
                        ? null
                        : 'Must be less than or equal bill',
                  ),
                  onChanged: (value) => _controller.setCollection,
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
          ],
        ),
      ),
    );
  }
}
