import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models.dart';

class Storage {
  static Future<void> saveListas(List<Lista> listas) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList =
        listas.map((lista) => json.encode(lista.toJson())).toList();
    await prefs.setStringList('listas', jsonList);
  }

  static Future<List<Lista>> loadListas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = prefs.getStringList('listas') ?? [];
    return jsonList.map((jsonString) => Lista.fromJson(json.decode(jsonString))).toList();
  }
}
