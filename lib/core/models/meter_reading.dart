import 'dart:convert';

MeterReading meterReadingFromJson(String str) {
  final jsonData = json.decode(str);
  return MeterReading.fromJson(jsonData);
}

String meterReadingToJson(MeterReading data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class MeterReading
{
  int id;
  int referenceId;
  double reading;
  DateTime date;
  String meterImage;
  String subType;
  int amp;
  String lineStatus;
  String prepaid;


  MeterReading(this.id, this.referenceId, this.reading, this.date,
       this.subType, this.amp, this.lineStatus, this.prepaid,this.meterImage);

  factory MeterReading.fromJson(Map<String, dynamic> json) => new MeterReading(
      json["id"],
      json["referenceId"],
      json["reading"],
      DateTime.fromMillisecondsSinceEpoch(json["date"]),
      json["subType"],
      json["amp"],
      json["lineStatus"],
      json["prepaid"],
      json["meterImage"]);

  Map<String, dynamic> toJson() => {
    "id": id,
    "referenceId": referenceId,
    "reading": reading,
    "date": date?.millisecondsSinceEpoch,
    "meterImage": meterImage,
    "subType": subType,
    "amp": amp,
    "lineStatus": lineStatus,
    "prepaid": prepaid,
  };
}
