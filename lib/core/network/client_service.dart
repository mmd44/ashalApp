import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/meter_collection.dart';
import 'package:ashal/core/models/meter_reading.dart';
import 'package:ashal/core/network/api.dart';
import 'package:ashal/core/network/network.dart';

class ClientService {
  Future<List<Client>> syncClients() {
    return HttpRequest.get(API.client)
        .then((dynamic res) {
      return Client.fromJsonList(res);
    });
  }

  Future syncMeterCollection(List<AmountCollection> collections) {
    return HttpRequest.post(API.collection,collections)
        .then((dynamic res) {
      return res;
    });
  }

  Future syncMeterReadings(List<MeterReading> readings) {
    return HttpRequest.post(API.reading,readings)
        .then((dynamic res) {
      return res;
    });
  }
}