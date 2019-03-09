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

  factory MeterCollectionModel.fromJson(Map<String, dynamic> json) => new MeterCollectionModel(
      json["id"],
      json["referenceId"],
      json["amount"],
      json["date"],
      json["multiplePayment"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "referenceId": referenceId,
        "amount": amount,
        "date": date,
        "multiplePayment": multiplePayment
      };
}
