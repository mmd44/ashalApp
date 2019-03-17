import 'dart:convert';

MeterReading meterReadingFromJson(String str) {
  final jsonData = json.decode(str);
  return MeterReading.fromJson(jsonData);
}

String meterReadingToJson(MeterReading data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class MeterReading {
  int referenceId;
  double reading;
  DateTime date;
  String meterImage;


  MeterReading({this.referenceId, this.reading, this.date, this.meterImage});


  factory MeterReading.fromJson(Map<String, dynamic> json) => new MeterReading(
      referenceId :json["referenceId"],
      reading: json["reading"],
      date: DateTime.fromMicrosecondsSinceEpoch(json["date"]),
      meterImage: json["meterImage"]);

  Map<String, dynamic> toJson() => {
        "referenceId": referenceId,
        "reading": reading,
        "date": date.millisecondsSinceEpoch,
        "meterImage": meterImage
      };
}
