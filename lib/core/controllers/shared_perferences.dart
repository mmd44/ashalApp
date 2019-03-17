import 'package:shared_preferences/shared_preferences.dart';

class ProjectSharedPreferences {
  ///
  /// Instantiation of the SharedPreferences library
  ///
  static final  String _dataBaseVersion = "db_version";
  static final String _meterReadingSync = "meterReadingSync";
  static final String _meterCollectionSync = "meterCollectionSync";
  /// ------------------------------------------------------------
  /// Method that returns the meter reading is sync with backend
  /// ------------------------------------------------------------
  static Future<bool> isMeterReadingSync() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_meterReadingSync) ?? false;
  }

  /// ----------------------------------------------------------
  /// Method that saves the state of meter reading table
  /// ----------------------------------------------------------
  static Future<bool> setMeterReadingSync(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_meterReadingSync, value);
  }

  /// ------------------------------------------------------------
  /// Method that returns the meter collection is sync with backend
  /// ------------------------------------------------------------
  static Future<bool> isCollectionSync() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_meterCollectionSync) ?? false;
  }

  /// ----------------------------------------------------------
  /// Method that saves the state of meter collection table
  /// ----------------------------------------------------------
  static Future<bool> setCollectionSync(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_meterCollectionSync, value);
  }

  /// ------------------------------------------------------------
  /// Method that returns database current version
  /// ------------------------------------------------------------
  static Future<int> getDataBaseVersion() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_dataBaseVersion) ?? 1;
  }

  /// ----------------------------------------------------------
  /// Method that saves database current version
  /// ----------------------------------------------------------
  static Future<bool> setDataBaseVersion(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(_dataBaseVersion, value);
  }
}
