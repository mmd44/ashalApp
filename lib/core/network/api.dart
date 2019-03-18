class API {

  static String ipAddress='';
  // host ToDo: set this when ip is obtained before sync
  static String host = 'https://$ipAddress:8443';

  // services
  static String metering = '$host/metering/';

  // endpoints
  static String client = "$metering/client";
}