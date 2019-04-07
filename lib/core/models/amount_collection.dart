import 'dart:convert';

import 'package:ashal/core/models/parse_utils.dart';

AmountCollection meterReadingFromJson(String str) {
  final jsonData = json.decode(str);
  return AmountCollection.fromJson(jsonData);
}

String meterReadingToJson(AmountCollection data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class AmountCollection {
  int id;
  int referenceId;
  double amount;
  DateTime date;


  AmountCollection({this.id,this.referenceId, this.amount, this.date});


  AmountCollection.AmountCollectionModel(this.referenceId, this.amount, this.date);



  factory AmountCollection.fromJson(Map<String, dynamic> json) => new AmountCollection(
      id:json["id"],
      referenceId: json["referenceId"],
      amount: json["amount"],
      date: DateTime.fromMillisecondsSinceEpoch(json["date"]),
  );

  Map<String, dynamic> toJson() => {
        "id":id,
        "referenceId": referenceId,
        "amount": amount,
        "date": date?.millisecondsSinceEpoch,
      };
}
