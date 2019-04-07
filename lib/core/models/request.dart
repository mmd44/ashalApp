

import 'dart:convert';

import 'package:ashal/core/models/parse_utils.dart';

Request requestFromJson(String str) {
  final jsonData = json.decode(str);
  return Request.fromJson(jsonData);
}

String requestToJson(Request data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Request {
  String id;
  String requestId;
  String lineStatus;
  int amp;
  String subscriptionType;
  String prepaid;
  String comment;


  Request(this.requestId, this.lineStatus, this.amp,
      this.subscriptionType, this.prepaid, this.comment);

  Request.Request(this.id, this.requestId, this.lineStatus, this.amp,
      this.subscriptionType, this.prepaid, this.comment);
  static List<Request> fromJsonList (List<dynamic> json) {
    return json.map((request) => Request.fromJson(request)).toList();
  }

  static List<Map<String, dynamic>> toJsonList (List<Request> requestList) {
    return requestList.map((request) => request.toJson()).toList();
  }

  factory Request.fromJson(Map<String, dynamic> json) => new Request.Request(
    json["id"],
    json["requestId"],
    json["lineStatus"],
    json["amp"],
    json["subscriptionType"],
    json["prepaid"],
    json["comment"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "requestId": requestId,
    "lineStatus": lineStatus,
    "amp": amp,
    "subscriptionType": subscriptionType,
    "prepaid": prepaid,
    "comment": comment
  };


}