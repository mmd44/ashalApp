import 'dart:convert';

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
  bool multiplePayment;


  AmountCollection({this.referenceId, this.amount, this.date,
      this.multiplePayment,this.id});


  AmountCollection.AmountCollectionModel(this.referenceId, this.amount, this.date,
      this.multiplePayment);

  static bool toBoolean(String str, [bool strict])
  {
    if(str==null) return true;

    if (strict == true) {
      return str == '1' || str == 'true';
    }
    return str != '0' && str != 'false' && str != '';
  }

  factory AmountCollection.fromJson(Map<String, dynamic> json) => new AmountCollection(
      referenceId: json["referenceId"],
      amount: json["amount"],
      date: DateTime.fromMicrosecondsSinceEpoch(json["date"]),
      multiplePayment: toBoolean(json["multiplePayment"].toString()),
      id:json["id"]);

  Map<String, dynamic> toJson() => {
        "id":id,
        "referenceId": referenceId,
        "amount": amount,
        "date": date.millisecondsSinceEpoch,
        "multiplePayment": multiplePayment
      };
}
