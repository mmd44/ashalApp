import 'dart:convert';

import 'package:ashal/core/models/meter_collection.dart';

Client clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Client.fromJson(jsonData);
}

String clientToJson(Client data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Client {
  String id;
  int referenceId;
  String category;
  String organizationName;
  String prefix;
  String firstName;
  String familyName;
  String name;
  String area;
  String streetAddress;
  String building;
  String floor;
  String phone;
  String email;
  String meterId;
  bool deleted;
  bool purged;
  DateTime dateTimeAdded;
  DateTime dateTimeDeleted;
  double outstanding;
  String comment;
  List<String> monthlyDataReferences;

  Client.from(this.id, this.referenceId, this.category, this.deleted,
      this.purged, this.dateTimeAdded, this.dateTimeDeleted, this.phone);

  Client(
      this.id,
      this.referenceId,
      this.category,
      this.organizationName,
      this.prefix,
      this.firstName,
      this.familyName,
      this.name,
      this.area,
      this.streetAddress,
      this.building,
      this.floor,
      this.phone,
      this.email,
      this.meterId,
      this.deleted,
      this.purged,
      this.dateTimeAdded,
      this.dateTimeDeleted,
      this.outstanding,
      this.comment);

  static List<Client> fromJsonList (List<dynamic> json) {
    return json.map((client) => Client.fromJson(client)).toList();
  }

  factory Client.fromJson(Map<String, dynamic> json) => new Client(
      json["id"],
      json["referenceId"],
      json["category"],
      json["organizationName"],
      json["prefix"],
      json["firstName"],
      json["familyName"],
      json["name"],
      json["area"],
      json["streetAddress"],
      json["building"],
      json["floor"],
      json["phone"],
      json["email"],
      json["meterId"],
      MeterCollection.toBoolean(json["deleted"].toString()),
      MeterCollection.toBoolean(json["purged"].toString()),
      json["dateTimeAdded"]!=null?DateTime.fromMicrosecondsSinceEpoch(json["dateTimeAdded"]):null,
      json["dateTimeDeleted"]!=null?DateTime.fromMicrosecondsSinceEpoch(json["dateTimeDeleted"]):null,
      json["outstanding"],
      json["comment"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "referenceId": referenceId,
        "category": category,
        "organizationName": organizationName,
        "prefix": prefix,
        "firstName": firstName,
        "familyName": familyName,
        "name": name,
        "area": area,
        "streetAddress": streetAddress,
        "building": building,
        "floor": floor,
        "phone": phone,
        "email": email,
        "meterId": meterId,
        "deleted": deleted,
        "purged": purged,
        "dateTimeAdded": dateTimeAdded?.millisecondsSinceEpoch,
        "dateTimeDeleted": dateTimeDeleted?.millisecondsSinceEpoch,
        "outstanding": outstanding,
        "comment": comment
      };
}
