import 'dart:convert';

MeterCollection meterReadingFromJson(String str) {
  final jsonData = json.decode(str);
  return MeterCollection.fromJson(jsonData);
}

String meterReadingToJson(MeterCollection data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class MeterCollection {
  int id;
  int referenceId;
  double amount;
  DateTime date;
  bool multiplePayment;


  MeterCollection({this.referenceId, this.amount, this.date,
      this.multiplePayment,this.id});


  MeterCollection.MeterCollectionModel(this.referenceId, this.amount, this.date,
      this.multiplePayment);

  static bool toBoolean(String str, [bool strict])
  {
    if(str==null) return true;

    if (strict == true) {
      return str == '1' || str == 'true';
    }
    return str != '0' && str != 'false' && str != '';
  }

  factory MeterCollection.fromJson(Map<String, dynamic> json) => new MeterCollection(
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
