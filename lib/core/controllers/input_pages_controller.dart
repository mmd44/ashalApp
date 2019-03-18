import 'dart:convert';
import 'dart:io';

import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/meter_collection.dart';
import 'package:ashal/core/models/meter_reading.dart';

class InputPagesController {
  final int maxInputDigits = 8;

  MeterCollection _meterCollection;
  MeterReading _meterReading;

  Client _client;

  String referenceID;

  InputPageView _view;

  bool isLoading = false;

  bool get isCollectionValid =>
      _meterReading?.reading != null &&
      _meterReading?.meterImage != null;

  InputPagesController(InputPageView view) : _view = view;

  Client get client => _client;

  String get clientArea => _client?.area;
  String get clientStreet => _client?.streetAddress;
  String get clientBldg => _client?.building;
  String get clientFloor => _client?.floor;
  String get clientPhone => _client?.phone;

  init() {
    setupDB();
    //initDummy();
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

  set todayDate (DateTime dateTime) {
    _meterReading.date = dateTime;
    _meterCollection.date =dateTime;
  }

  void setClientByReference() {
    int id;

    if (referenceID != null) {
      id = int.tryParse(referenceID);
    }

    if (id != null) {
      DBProvider.db.getClient(id).then((client) {
        _client = client;
        _meterReading.referenceId = id;
        _view.onSetClientSuccess();
      }).catchError((error) {
        print('DBGetClient: $error');
      });
    } else {
      _client = null;
      _meterReading.referenceId = null;
    }
  }

  void setupDB() async {
    await DBProvider.db.initDB();
  }

  void setImage(File image) {
    List<int> imageBytes = image.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    _meterReading.meterImage = base64Image;
  }

  void setReadings(String value) {
    double readings;
    if (value != null) {
      readings = double.tryParse(value);
    }
    if (readings != null) {
      _meterReading.reading = readings;
    } else {
      _view.onReadingsError('Invalid Readings');
    }
  }

  void submit() {
    if (_client == null || referenceID == null){
      _view.onError('Invalid reference id!');
    } else {
      isLoading = true;
      _meterReading.date = DateTime.now();
      DBProvider.db.insertMeterReading(_meterReading).then((result){
        _view.onSuccess('Reading added successfully!');
      }).catchError((error) {
        print('DBinsertReadingError: $error');
        _view.onError('Adding reading failed!');
      }).whenComplete((){
        isLoading = false;
      });
    }
  }

  void resetFields() {
    _client = null;
    referenceID = null;
    _meterReading = MeterReading();
    _meterCollection = MeterCollection();
  }
}

abstract class InputPageView {
  void onSetClientSuccess();
  void onSetClientError(String msg);
  void onReadingsError(String msg);
  void onError(String error);
  void onSuccess(String msg);
}
