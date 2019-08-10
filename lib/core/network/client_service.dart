import 'package:ashal/core/models/amount_collection.dart';
import 'package:ashal/core/models/meter_reading.dart';
import 'package:ashal/core/models/request.dart';
import 'package:ashal/core/models/sync_client_response.dart';
import 'package:ashal/core/models/sync_meter_reading_response.dart';
import 'package:ashal/core/network/api.dart';
import 'package:ashal/core/network/network.dart';
import 'dart:convert';

class ClientService {

  Future<ClientSyncResponse> syncClients() {

        return HttpRequest.get(API.client)
        .then((dynamic res) {
      return ClientSyncResponse.fromJson(res);
    });
  }
  ClientSyncResponse syncClientsTest() {
    dynamic res= json.decode('{"Clients": [	{		"_id": "5c7027b838bc4c079023cc2d",		"referenceId": 1001,		"category": "Individual",		"organizationName": null,		"sharedDescription": null,		"prefix": "Mr.",		"firstName": "John",		"familyName": "Cook",		"name": "Mr. John Cook",		"area": "Beirut",		"streetAddress": "Hamra",		"building": "Building 15",		"floor": 1,		"phone": "+961-1234560",		"email": "John@email.com",		"meterId": "",		"deleted": true,		"purged": false,		"dateTimeAdded": "2018-12-21T22:00:00Z",		"dateAdded": {			"month": 12,			"year": 2018		},		"dateTimeDeleted": "2019-02-22T22:00:00Z",		"dateDeleted": {			"month": 2,			"year": 2019		},		"outstanding": 0.0,		"comment": "",		"monthlyData_references": [			"1001_12_2018"		],		"Phone": [			"+961",			"1234560"		],		"Prefix": "Mr.",		"FirstName": "John",		"FamilyName": "Cook",		"Name": "Mr. John Cook"	}],"History": [	{		"_id": "5c7027b638bc4c079023cc2c",		"historyId": "1001_12_2018",		"entryDateTime": "2018-12-21T22:00:00Z",		"entryDate": {			"month": 12,			"year": 2018		},		"parentId": 1001,		"subType": "AMP",		"amp": 10,		"flatPrice": null,		"oldMeter": null,		"newMeter": null,		"subscription": null,		"discount": 0.0,		"lineStatus": "on",		"prepaid": "no",		"bill": null,		"dependentsBill": null,		"collected": null,		"forgiven": null,		"receiptIssued": "no",		"category": "Individual",		"meterReader": null,		"collector": null,		"payers": [],		"AMP": 10,		"FlatPrice": 0.0,		"OldMeter": 0.0,		"NewMeter": 0.0,		"Discount": 0.0,		"Bill": 0.0,		"DependentsBill": 0.0,		"totalBill": null,		"TotalBill": 0.0,		"Collected": 0.0,		"Forgiven": 0.0,		"SubType": "AMP",		"LineStatus": "On",		"Subscription": "",		"Prepaid": "No"	}]}');
    return ClientSyncResponse.fromJson(res);
    //    return HttpRequest.get(API.client)
//        .then((dynamic res) {
//
//
//      return ClientSyncResponse.fromJson(res);
//    });
  }

  Future<String> syncMeterCollection(List<AmountCollection> collections) {
    return HttpRequest.post(API.collection,collections)
        .then((dynamic res) {
      return res;
    });
  }

  Future<MeterSyncResponse> syncMeterReadings(List<MeterReading> readings) {
    return HttpRequest.post(API.reading,readings)
        .then((dynamic res) {
      return MeterSyncResponse.fromJson(res);
    });
  }

  Future<String> syncRequests(List<Request> requests) {
    return HttpRequest.post(API.requests,requests)
        .then((dynamic res) {
      return res;
    });
  }
}