import 'dart:convert';

MeterCollectionModel meterReadingFromJson(String str) {
  final jsonData = json.decode(str);
  return MeterCollectionModel.fromJson(jsonData);
}

String meterReadingToJson(MeterCollectionModel data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class MeterCollectionModel {
  int id;
  int referenceId;
  double amount;
  DateTime date;
  bool multiplePayment;


  MeterCollectionModel(this.id, this.referenceId, this.amount, this.date,
      this.multiplePayment);


  MeterCollectionModel.MeterCollectionModel(this.referenceId, this.amount, this.date,
      this.multiplePayment);

  static bool toBoolean(String str, [bool strict]) {
    if (strict == true) {
      return str == '1' || str == 'true';
    }
    return str != '0' && str != 'false' && str != '';
  }

  factory MeterCollectionModel.fromJson(Map<String, dynamic> json) => new MeterCollectionModel(
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
