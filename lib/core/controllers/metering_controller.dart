import 'dart:convert';
import 'dart:io';
import 'package:ashal/core/controllers/input_pages_controller.dart';
import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/history.dart';
import 'package:ashal/core/models/meter_reading.dart';
import 'package:ashal/ui/models/card_item.dart';

class MeteringController {
  final int maxInputDigits = 8;

  MeterReading _meterReading;

  Client _client;
  History _clientLastHistory;

  String referenceID;

  InputPageView _view;

  bool isLoading = false;

  File meterImageFile;

  DateTime todayDate;

  bool get isMeteringValid =>
      _meterReading?.reading != null && _meterReading?.meterImage != null;

  MeteringController(CardItem cardItem, InputPageView view) : _view = view;

  Client get client => _client;

  String get clientArea => _client?.area;
  String get clientStreet => _client?.streetAddress;
  String get clientBldg => _client?.building;
  String get clientFloor => _client?.floor;
  String get clientPhone => _client?.phone;

  init() {
    setupDB();
    initDummy();
    resetFields();
  }

  initDummy() async {
    await DBProvider.db.reCreateDatabase();

    await DBProvider.db.insertClient(Client.from(
        '1', 2, 'test', true, true, DateTime.now(), DateTime.now(), '03030303',
        monthlyDataReferences: ['ref1', 'ref2']));
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
    await DBProvider.db
        .insertHistory([History.from(id: '1', historyId: 'ref1'),]);
  }

  set meteringDate(DateTime dateTime) {
    todayDate = dateTime;
    _meterReading.date = dateTime;
  }

  set meteringLineStatus(bool val) {
    switch (val) {
      case true:
        _meterReading.lineStatus = 'on';
        break;
      case false:
        _meterReading.lineStatus = 'off';
    }
  }

  get meteringLineStatus {
    if (_meterReading.lineStatus == null) return false;
    switch (_meterReading.lineStatus) {
      case 'on':
        return true;
      case 'off':
        return false;
    }
  }

  void setClientByReference(String ref) {
    referenceID = ref;
    int id = int.tryParse(referenceID);
    if (id != null) {
      DBProvider.db.getClient(id).then((client) {
        _client = client;
        _meterReading.referenceId = id;
        _view.onSetClientSuccess();

        if (_client.monthlyDataReferences != null &&
            _client.monthlyDataReferences[0] != null)
          return DBProvider.db.getLastHistory(id);
        else
          throw Exception('No history available!');
      }).then((history) {
        _clientLastHistory = history;
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
      _meterReading.reading = input;
    } else {
      _view.onReadingsError('Invalid Input!');
    }
  }

  void submit({bypassChecks = false}) {
    if (!bypassChecks && (_client == null || referenceID == null)) {
      _view
        ..showWarningDialog(
            'Invalid reference id!\nAre you sure you want to proceed?');
    } else {
      isLoading = true;
      insertReading();
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

  void resetFields() {
    _client = null;
    referenceID = null;
    _meterReading = MeterReading();
    meteringDate = DateTime.now();
  }
}
