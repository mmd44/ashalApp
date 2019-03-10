import 'dart:convert';

MeterReadingModel meterReadingFromJson(String str) {
  final jsonData = json.decode(str);
  return MeterReadingModel.fromJson(jsonData);
}

String meterReadingToJson(MeterReadingModel data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class MeterReadingModel {
  int referenceId;
  double reading;
  DateTime date;
  String meterImage;

  MeterReadingModel(this.referenceId, this.reading, this.date, this.meterImage);


  factory MeterReadingModel.fromJson(Map<String, dynamic> json) => new MeterReadingModel(
      json["referenceId"],
      json["reading"],
      DateTime.fromMicrosecondsSinceEpoch(json["date"]),
      json["meterImage"]);

  Map<String, dynamic> toJson() => {
        "referenceId": referenceId,
        "reading": reading,
        "date": date.millisecondsSinceEpoch,
        "meterImage": meterImage
      };
}
