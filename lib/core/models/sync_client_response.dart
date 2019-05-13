

import 'dart:convert';

import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/history.dart';

ClientSyncResponse clientSyncResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return ClientSyncResponse.fromJson(jsonData);
}

String clientSyncResponseToJson(Client data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}
class ClientSyncResponse
{
  List<Client> client;
  List<History> history;

  ClientSyncResponse(this.client, this.history);

  factory ClientSyncResponse.fromJson(Map<String, dynamic> jsonObject) => new ClientSyncResponse(
      Client.fromJsonListServer(json.decode(jsonObject["Clients"])),
      History.fromJsonListServer(json.decode(jsonObject["History"])),
  );

}