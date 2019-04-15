import 'dart:convert';

import 'package:ashal/core/enum.dart';
import 'package:ashal/core/models/parse_utils.dart';

History historyFromJson(String str) {
  final jsonData = json.decode(str);
  return History.fromJson(jsonData);
}

String historyToJson(History data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class History {
  String id;
  String historyId;
  DateTime entryDateTime;
  int parentId;
  SubscriptionType subType;
  var amp;
  var flatPrice;
  var oldMeter;
  var newMeter;
  var subscription;
  double discount;
  String lineStatus;
  String prepaid;
  var bill;
  var dependentsBill;
  var collected;
  var forgiven;
  String receiptIssued;
  String category;
  var meterReader;
  var collector;
  List<String> payers;

  History(
      this.id,
      this.historyId,
      this.entryDateTime,
      this.parentId,
      this.subType,
      this.amp,
      this.flatPrice,
      this.oldMeter,
      this.newMeter,
      this.subscription,
      this.discount,
      this.bill,
      this.dependentsBill,
      this.collected,
      this.forgiven,
      this.receiptIssued,
      this.category,
      this.meterReader,
      this.collector,
      this.payers,
      this.lineStatus,
      this.prepaid);

  History.from(
      {this.id,
      this.historyId,
      this.entryDateTime,
      this.parentId,
      this.subType,
      this.amp,
      this.flatPrice,
      this.oldMeter,
      this.newMeter,
      this.subscription,
      this.discount,
      this.bill,
      this.dependentsBill,
      this.collected,
      this.forgiven,
      this.receiptIssued,
      this.category,
      this.meterReader,
      this.collector,
      this.payers,
      this.lineStatus,
      this.prepaid});

  static List<History> fromJsonList(List<dynamic> json) {
    return json.map((history) => History.fromJson(history)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<History> historyList) {
    return historyList.map((history) => history.toJson()).toList();
  }

  factory History.fromJson(Map<String, dynamic> json) => new History(
      json["id"],
      json["historyId"],
      json["entryDateTime"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["entryDateTime"])
          : null,
      json["parentId"],
      SubscriptionType(json["subType"]),
      json["amp"],
      json["flatPrice"],
      json["oldMeter"],
      json["newMeter"],
      json["subscription"],
      json["discount"],
      json["bill"],
      json["dependentsBill"],
      json["collected"],
      toBoolean(json["forgiven"], false),
      json["receiptIssued"],
      json["category"],
      json["meterReader"],
      json["collector"],
      List.from(json['payers'] != null ? jsonDecode(json["payers"]) : []),
      json["lineStatus"],
      json["prepaid"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "historyId": historyId,
        "entryDateTime": entryDateTime?.millisecondsSinceEpoch,
        "parentId": parentId,
        "subType": subType?.value ?? '',
        "amp": amp,
        "flatPrice": flatPrice,
        "oldMeter": oldMeter,
        "newMeter": newMeter,
        "subscription": subscription,
        "discount": discount,
        "bill": bill,
        "dependentsBill": dependentsBill,
        "collected": collected,
        "forgiven": forgiven,
        "receiptIssued": receiptIssued,
        "category": category,
        "meterReader": meterReader,
        "collector": collector,
        "payers": jsonEncode(payers ?? []),
        "lineStatus": lineStatus,
        "prepaid": prepaid
      };
}

class SubscriptionType extends Enum {
  static const amp = SubscriptionType._internal('AMP');
  static const flat = SubscriptionType._internal('Flat Price');
  static const meter = SubscriptionType._internal('Metered');

  static const List<SubscriptionType> values = [amp, flat, meter];

  const SubscriptionType._internal(String value) : super.internal(value);

  factory SubscriptionType(String raw) =>
      values.singleWhere((val) => val.value == raw, orElse: () => null);
}
