import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpul_kampus/api_client.dart';

/// Jawaban JSON palsu dari server.
http.Response jsonRes(Object data, [int status = 200]) => http.Response(
  jsonEncode(data),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// ApiClient yang berbicara dengan server palsu, tanpa jaringan.
ApiClient apiPalsu(Future<http.Response> Function(http.Request) server) =>
    ApiClient(client: MockClient(server));

/// Pengganti SharedPreferencesAsync yang menyimpan di memori.
class PrefPalsu implements SharedPreferencesAsync {
  final Map<String, String> isi = {};

  @override
  dynamic noSuchMethod(Invocation i) {
    final a = i.positionalArguments;
    if (i.memberName == #getString) {
      return Future<String?>.value(isi[a[0] as String]);
    }
    if (i.memberName == #setString) {
      isi[a[0] as String] = a[1] as String;
      return Future<void>.value();
    }
    if (i.memberName == #remove) {
      isi.remove(a[0] as String);
      return Future<void>.value();
    }
    return super.noSuchMethod(i);
  }
}
