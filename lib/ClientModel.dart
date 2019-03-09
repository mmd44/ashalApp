import 'dart:convert';

ClientModel clientFromJson(String str) {
  final jsonData = json.decode(str);
  return ClientModel.fromJson(jsonData);
}

String clientToJson(ClientModel data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class ClientModel {
  int id;
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

  ClientModel(
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
      this.comment,
      this.monthlyDataReferences);

  factory ClientModel.fromJson(Map<String, dynamic> json) => new ClientModel(
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
      json["deleted"],
      json["purged"],
      json["dateTimeAdded"],
      json["dateTimeDeleted"],
      json["outstanding"],
      json["comment"],
      json["monthlyDataReferences"]);

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
        "dateTimeAdded": dateTimeAdded,
        "dateTimeDeleted": dateTimeDeleted,
        "outstanding": outstanding,
        "comment": comment,
        "monthlyDataReferences": monthlyDataReferences
      };
}
