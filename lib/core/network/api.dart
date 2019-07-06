class API {

  static String ipAddress='';
  // host ToDo: set this when ip is obtained before sync
  static String host = 'http://$ipAddress:8889';

  // endpoints
  static String client = "$host/sync_clients";
  static String collection = "$host/sync_collection";
  static String reading = "$host/sync_meter_reading";
  static String requests = "$host/sync_requests";
}