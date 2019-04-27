import 'dart:io';
import 'package:ashal/core/controllers/collection_controller.dart';
import 'package:ashal/core/database.dart';
import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/history.dart';
import 'package:ashal/core/models/request.dart';
import 'package:ashal/ui/models/card_item.dart';

class RequestsController {
  final int maxInputDigits = 8;

  Request _request;

  Client _client;
  History _clientLastHistory;

  String referenceID;

  InputPageView _view;

  bool isLoading = false;
  bool isValidAMPField = false;
  bool isValidReading = false;

  File meterImageFile;

  DateTime todayDate;

  RequestsController(CardItem cardItem, InputPageView view) : _view = view;

  Client get client => _client;
  History get lastHistory => _clientLastHistory;

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

    ///Dummy History
    await DBProvider.db.insertHistory([
      History.from(
        id: '1',
        historyId: 'ref1',
        entryDateTime: DateTime.now(),
        parentId: 2,
        subType: SubscriptionType('Metered'),
        amp: 20,
        lineStatus: 'on',
        prepaid: 'no',
        oldMeter: 170,
        newMeter: 270,
        payers: ['Ali', 'Hussein'],
      ),
    ]);
  }

  set meteringDate(DateTime dateTime) {
    todayDate = dateTime;
    _request.date = dateTime;
  }

  set lineStatus(bool val) {
    switch (val) {
      case true:
        _request.lineStatus = 'on';
        break;
      case false:
        _request.lineStatus = 'off';
        break;
    }
  }

  set amp(int val) {
    if (val != null && val >= 0) {
      _request.amp = val;
      isValidAMPField = true;
    } else {
      _request.amp = null;
      isValidAMPField = false;
    }
  }

  set comment(String val) {
    _request.comment=val;
  }

  String get ampStr => _request?.amp?.toString() ?? '';

  set subType(SubscriptionType val) {
    _request.subType = val;
  }

  SubscriptionType get subType => _request?.subType ?? null;

  set isPrepaid(String val) => _request.prepaid = val;
  String get isPrepaid => _request?.prepaid ?? '';

  String get oldMetering => _clientLastHistory?.oldMeter?.toString() ?? '';

  bool get isTypePrepaid =>
      [SubscriptionType.amp, SubscriptionType.flat].contains(_request?.subType);

  bool get isSubMetered => _request?.subType == SubscriptionType.meter;

  get lineStatus {
    if (_request?.lineStatus == null) return false;
    switch (_request?.lineStatus) {
      case 'on':
        return true;
      case 'off':
        return false;
    }
  }

  void setClientByReference(String ref) {
    resetFields();
    referenceID = ref;
    int id = int.tryParse(referenceID);
    if (id != null) {
      DBProvider.db.getClient(id).then((client) {
        _client = client;
        _request.referenceId = id;
        if (_client?.monthlyDataReferences != null &&
            _client.monthlyDataReferences.length > 0)
          return DBProvider.db.getLastHistory(id);
        else
          return null;
      }).then((history) {
        print('history $history');
        if (history != null) setupHistoryFields(history);
        _view.onSetClientSuccess();
      }).catchError((error) {
        resetFields();
        _view.onError(error.toString());
        print('DBGetClient: ${error.toString()}');
      });
    } else {
      _view.onError(null);
      resetFields();
    }
  }

  void setupDB() async {
    await DBProvider.db.initDB();
  }

  void submit({bypassChecks = false}) {
    isLoading = true;
    insertRequest();
  }

  void insertRequest() {
    DBProvider.db.insertRequest(_request).then((result) {
      _view.onSuccess('Request saved successfully!');
    }).catchError((error) {
      print('DBinsertRequestError: $error');
      _view.onError('Failed to save request!');
    }).whenComplete(() {
      isLoading = false;
    });
  }

  void resetFields() {
    _client = null;
    _clientLastHistory = null;
    referenceID = null;
    _request = Request();
    meteringDate = DateTime.now();
  }

  void setupHistoryFields(History history) {
    _clientLastHistory = history;
    subType = history.subType;
    amp = history.amp;
    isPrepaid = history.prepaid;
    _request.lineStatus = history.lineStatus;
  }
}
