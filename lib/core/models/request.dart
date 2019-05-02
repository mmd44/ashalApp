

import 'dart:convert';

import 'package:ashal/core/models/history.dart';
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
  int referenceId;
  String lineStatus;
  int amp;
  SubscriptionType subType;
  String prepaid;
  String comment;
  DateTime date;


  Request({this.referenceId, this.lineStatus, this.amp,
      this.subType, this.prepaid, this.comment,this.date});

  Request.Request({this.id, this.referenceId, this.lineStatus, this.amp,
      this.subType, this.prepaid, this.comment,this.date});
  static List<Request> fromJsonList (List<dynamic> json) {
    return json.map((request) => Request.fromJson(request)).toList();
  }

  static List<Map<String, dynamic>> toJsonList (List<Request> requestList) {
    return requestList.map((request) => request.toJson()).toList();
  }

  factory Request.fromJson(Map<String, dynamic> json) => new Request.Request(
      id:json["id"],
      referenceId:json["referenceId"],
      lineStatus:json["lineStatus"],
      amp:json["amp"],
      subType:SubscriptionType(json["subType"]),
      prepaid:json["prepaid"],
      comment:json["comment"],
      date:DateTime.fromMillisecondsSinceEpoch(json["date"])
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "referenceId": referenceId,
    "lineStatus": lineStatus,
    "amp": amp,
    "subType": subType.value,
    "prepaid": prepaid,
    "comment": comment,
    "date": date?.millisecondsSinceEpoch
  };


}