import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/amount_collection.dart';
import 'package:ashal/core/models/meter_reading.dart';
import 'package:ashal/core/models/request.dart';
import 'package:ashal/core/models/syn_client_response.dart';
import 'package:ashal/core/network/api.dart';
import 'package:ashal/core/network/network.dart';

class ClientService {
  Future<ClientSyncResponse> syncClients() {
    return HttpRequest.get(API.client)
        .then((dynamic res) {
      return ClientSyncResponse.fromJson(res);
    });
  }

  Future<ClientSyncResponse> syncMeterCollection(List<AmountCollection> collections) {
    return HttpRequest.post(API.collection,collections)
        .then((dynamic res) {
      return ClientSyncResponse.fromJson(res);
    });
  }

  Future<ClientSyncResponse> syncMeterReadings(List<MeterReading> readings) {
    return HttpRequest.post(API.reading,readings)
        .then((dynamic res) {
      return ClientSyncResponse.fromJson(res);
    });
  }

  Future syncRequests(List<Request> requests) {
    return HttpRequest.post(API.requests,requests)
        .then((dynamic res) {
      return res;
    });
  }
}