import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/network/api.dart';
import 'package:ashal/core/network/network.dart';

class ClientService {
  Future<List<Client>> syncClients() {
    return HttpRequest.get(API.client)
        .then((dynamic res) {
      return Client.fromJsonList(res);
    });
  }
}