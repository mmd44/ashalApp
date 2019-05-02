import 'dart:convert';
import 'package:ashal/core/models/parse_utils.dart';

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
  String sharedDescription;
  String prefix;
  String firstName;
  String familyName;
  String name;
  String area;
  String streetAddress;
  String building;
  int floor;
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

  Client.from(
      {this.id,
      this.referenceId,
      this.category,
      this.organizationName,
      this.sharedDescription,
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
      this.comment,
      this.monthlyDataReferences});

  Client(
      this.id,
      this.referenceId,
      this.category,
      this.organizationName,
      this.sharedDescription,
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
      this.comment,
      this.monthlyDataReferences);

  static List<Client> fromJsonList(List<dynamic> json) {
    print("FROM JSON CLIENT $json");
    return json.map((client) => Client.fromJson(client)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<Client> clients) {
    return clients.map((client) => client.toJson()).toList();
  }

  factory Client.fromJson(Map<String, dynamic> json) => Client(
        json["_id"],
        json["referenceId"],
        json["category"],
        json["organizationName"],
        json["sharedDescription"],
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
        toBoolean(json["deleted"].toString(), false),
        toBoolean(json["purged"].toString(), false),
        json["dateTimeAdded"] != null
            ? DateTime.parse(json["dateTimeAdded"])
            : null,
        json["dateTimeDeleted"] != null
            ? DateTime.parse(json["dateTimeDeleted"])
            : null,
        json["outstanding"],
        json["comment"],
        [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "referenceId": referenceId,
        "category": category,
        "organizationName": organizationName,
        "sharedDescription": sharedDescription,
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
        "comment": comment,
        "monthlyDataReferences": jsonEncode(monthlyDataReferences ?? []),
      };
}
