class API {

  static String ipAddress='';
  // host ToDo: set this when ip is obtained before sync
  static String host = 'http://$ipAddress:8080/lib-service';

  // services
  static String metering = '$host/metering/';

  // endpoints
  static String client = "$metering/client";
  static String collection = "$metering/collection";
  static String reading = "$metering/reading";
}