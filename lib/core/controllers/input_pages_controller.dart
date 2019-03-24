import 'dart:convert';
import 'dart:io';

import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/amount_collection.dart';
import 'package:ashal/core/models/meter_reading.dart';
import 'package:ashal/ui/models/card_item.dart';

class InputPagesController {
  final int maxInputDigits = 8;

  CardItem _cardItem;

  AmountCollection _amountCollection;
  MeterReading _meterReading;

  Client _client;

  String referenceID;

  InputPageView _view;

  bool isLoading = false;

  File meterImageFile;

  DateTime todayDate;

  bool get isCollectionValid => _amountCollection?.amount != null;

  bool get isMeteringValid =>
      _meterReading?.reading != null && _meterReading?.meterImage != null;

  InputPagesController(CardItem cardItem, InputPageView view)
      : _cardItem = cardItem,
        _view = view;

  bool get isMetering => _cardItem.id == '2';

  bool get isMultiplePayment => _amountCollection.multiplePayment;
  set multiplePayment (bool val) => _amountCollection.multiplePayment = val;

  Client get client => _client;

  String get clientArea => _client?.area;
  String get clientStreet => _client?.streetAddress;
  String get clientBldg => _client?.building;
  String get clientFloor => _client?.floor;
  String get clientPhone => _client?.phone;

  init() {
    setupDB();
    resetFields();
  }

  initDummy() async {
    await DBProvider.db.reCreateDatabase();

    await DBProvider.db.insertClient(Client.from('1', 2, 'test', true, true,
        DateTime.now(), DateTime.now(), '03030303'));
    await DBProvider.db.insertClient(Client.from('1', 234, 'test', true, true,
        DateTime.now(), DateTime.now(), '03040404'));
    await DBProvider.db.insertClient(Client.from('1', 4564, 'test', true, true,
        DateTime.now(), DateTime.now(), '03040404'));
    await DBProvider.db.insertClient(Client.from('1', 1234, 'test', true, true,
        DateTime.now(), DateTime.now(), '03040404'));
    await DBProvider.db.insertClient(Client.from('1', 1232, 'test', true, true,
        DateTime.now(), DateTime.now(), '03040404'));
    await DBProvider.db.insertClient(Client.from('1', 1222, 'test', true, true,
        DateTime.now(), DateTime.now(), '03040404'));
  }

  set meteringCollectionDates (DateTime dateTime) {
    todayDate = dateTime;
    _meterReading.date = dateTime;
    _amountCollection.date = dateTime;
  }

  void setClientByReference() {
    int id;

    if (referenceID != null) {
      id = int.tryParse(referenceID);
    }

    if (id != null) {
      DBProvider.db.getClient(id).then((client) {
        _client = client;
        isMetering ? _meterReading.referenceId = id : _amountCollection.referenceId = id;
        _view.onSetClientSuccess();
      }).catchError((error) {
        print('DBGetClient: $error');
      });
    } else {
      _client = null;
      _meterReading.referenceId = null;
      _amountCollection.referenceId = null;
    }
  }

  void setupDB() async {
    await DBProvider.db.initDB();
  }

  void setImage(File image) {
    meterImageFile = image;
    List<int> imageBytes = image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    _meterReading.meterImage = base64Image;
  }

  void setInput(String value) {
    double input;
    if (value != null) {
      input = double.tryParse(value);
    }
    if (input != null) {
      isMetering ? _meterReading.reading = input : _amountCollection.amount = input;
    } else {
      _view.onReadingsError('Invalid Input!');
    }
  }

  void submit({bypassChecks=false}) {
    if (!bypassChecks && (_client == null || referenceID == null)) {
      _view..showWarningDialog ('Invalid reference id!\nAre you sure you want to proceed?');
    } else {
      isLoading = true;
      isMetering ? insertReading () : insertCollection();
    }
  }

  void insertReading() {
    DBProvider.db.insertMeterReading(_meterReading).then((result) {
      _view.onSuccess('Reading saved successfully!');
    }).catchError((error) {
      print('DBinsertReadingError: $error');
      _view.onError('Failed to save reading!');
    }).whenComplete(() {
      isLoading = false;
    });
  }

  void insertCollection() {
    DBProvider.db.insertAmountCollection(_amountCollection).then((result) {
      _view.onSuccess('Collection saved successfully!');
    }).catchError((error) {
      print('DBinsertCollectionError: $error');
      _view.onError('Failed to save collection!');
    }).whenComplete(() {
      isLoading = false;
    });
  }

  void resetFields() {
    _client = null;
    referenceID = null;
    _meterReading = MeterReading();
    _amountCollection = AmountCollection(multiplePayment: false);
    meteringCollectionDates = DateTime.now();
  }
  
}

abstract class InputPageView {
  void onSetClientSuccess();
  void onSetClientError(String msg);
  void onReadingsError(String msg);
  void onError(String error);
  void onSuccess(String msg);
  void showWarningDialog(String msg);
}
