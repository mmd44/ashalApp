import 'package:shared_preferences/shared_preferences.dart';

class ProjectSharedPreferences
{
  ProjectSharedPreferences._();
  static final ProjectSharedPreferences instance = ProjectSharedPreferences._();
  SharedPreferences prefs;


  init() async
  {
    prefs = await SharedPreferences.getInstance();
  }

  get perfs
  {
    if(perfs==null)
      throw Exception("call init before get perfs");
    return prefs;
  }
  ///
  /// Instantiation of the SharedPreferences library
  ///
  static final  String _dataBaseVersion = "db_version";
  static final String _meterReadingSync = "meterReadingSync";
  static final String _meterCollectionSync = "meterCollectionSync";
  /// ------------------------------------------------------------
  /// Method that returns the meter reading is sync with backend
  /// ------------------------------------------------------------
  bool isMeterReadingSync() {
    return prefs.getBool(_meterReadingSync) ?? false;
  }

  /// ----------------------------------------------------------
  /// Method that saves the state of meter reading table
  /// ----------------------------------------------------------
  Future<bool> setMeterReadingSync(bool value) async {
    return prefs.setBool(_meterReadingSync, value);
  }

  /// ------------------------------------------------------------
  /// Method that returns the meter collection is sync with backend
  /// ------------------------------------------------------------
  bool isCollectionSync() {
    return prefs.getBool(_meterCollectionSync) ?? false;
  }

  /// ----------------------------------------------------------
  /// Method that saves the state of meter collection table
  /// ----------------------------------------------------------
  Future<bool> setCollectionSync(bool value) async {
    return prefs.setBool(_meterCollectionSync, value);
  }

  /// ------------------------------------------------------------
  /// Method that returns database current version
  /// ------------------------------------------------------------
  int getDataBaseVersion() {
    return prefs.getInt(_dataBaseVersion) ?? 1;
  }

  /// ----------------------------------------------------------
  /// Method that saves database current version
  /// ----------------------------------------------------------
  Future<bool> setDataBaseVersion(int value) async {
    return prefs.setInt(_dataBaseVersion, value);
  }
}
