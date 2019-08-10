

import 'dart:convert';

import 'package:ashal/core/models/client.dart';
import 'package:ashal/core/models/history.dart';

MeterSyncResponse meterSyncResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return MeterSyncResponse.fromJson(jsonData);
}

String meterSyncResponseToJson(Client data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}
class MeterSyncResponse
{
  List<History> history;

  MeterSyncResponse(this.history);

  factory MeterSyncResponse.fromJson(dynamic jsonObject) => new MeterSyncResponse(
      History.fromJsonListServer(jsonObject)
  );

}