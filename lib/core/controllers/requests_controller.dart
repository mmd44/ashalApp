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
  String get clientFloor => _client?.floor.toString();
  String get clientPhone => _client?.phone;

  init() {
    setupDB();
    //initDummy();
    resetFields();
  }

  initDummy() async {
    await DBProvider.db.reCreateDatabase();

    await DBProvider.db.insertClient(Client.from(
        id: '1',
        referenceId: 2222,
        prefix: 'Mr',
        firstName: 'John',
        familyName: 'Whick',
        organizationName: 'Ashal Co',
        sharedDescription: 'Cafe Near Road',
        area: 'Ashrafieh',
        streetAddress: 'Independence Str',
        building: 'Queen',
        floor: 10,
        category: 'Individual',
        deleted: true,
        purged: true,
        dateTimeAdded: DateTime.now(),
        dateTimeDeleted: DateTime.now(),
        phone: '70300673',
        monthlyDataReferences: ['ref1', 'ref2']));

    await DBProvider.db.insertClient(Client.from(
        id: '2',
        referenceId: 2345,
        category: 'test',
        deleted: true,
        purged: true,
        dateTimeAdded: DateTime.now(),
        dateTimeDeleted: DateTime.now(),
        phone: '03030303',
       ));

    await DBProvider.db.insertClient(Client.from(
        id: '3',
        referenceId: 4564,
        category: 'test',
        deleted: true,
        purged: true,
        dateTimeAdded: DateTime.now(),
        dateTimeDeleted: DateTime.now(),
        phone: '03030303',
       ));

    await DBProvider.db.insertClient(Client.from(
        id: '4',
        referenceId: 1234,
        category: 'test',
        deleted: true,
        purged: true,
        dateTimeAdded: DateTime.now(),
        dateTimeDeleted: DateTime.now(),
        phone: '03030303',
        monthlyDataReferences: ['ref1', 'ref2']));

    await DBProvider.db.insertClient(Client.from(
        id: '5',
        referenceId: 1232,
        category: 'test',
        deleted: true,
        purged: true,
        dateTimeAdded: DateTime.now(),
        dateTimeDeleted: DateTime.now(),
        phone: '03030303',
    ));

    await DBProvider.db.insertClient(Client.from(
        id: '6',
        referenceId: 1222,
        category: 'test',
        deleted: true,
        purged: true,
        dateTimeAdded: DateTime.now(),
        dateTimeDeleted: DateTime.now(),
        phone: '03030303',
        monthlyDataReferences: ['ref1', 'ref2']),
    );


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

  set lineStatus(String val) {
    _request.lineStatus=val;
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
    return _request?.lineStatus;
  }

  void setClientByReference(String ref) {
    resetFields();
    referenceID = ref;
    int id = int.tryParse(referenceID);
    if (id != null) {
      DBProvider.db.getClient(id).then((client) {
        _client = client;
        _request.referenceId = id;
        if (_client!=null)
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
      _view.onSuccess('requests_success');
    }).catchError((error) {
      print('DBinsertRequestError: $error');
      _view.onError('requests_error');
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
