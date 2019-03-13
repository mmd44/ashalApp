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


  MeterCollection(this.id, this.referenceId, this.amount, this.date,
      this.multiplePayment);


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
      json["id"],
      json["referenceId"],
      json["amount"],
      DateTime.fromMicrosecondsSinceEpoch(json["date"]),
      toBoolean(json["multiplePayment"].toString()));

  Map<String, dynamic> toJson() => {
        "referenceId": referenceId,
        "amount": amount,
        "date": date.millisecondsSinceEpoch,
        "multiplePayment": multiplePayment
      };
}
