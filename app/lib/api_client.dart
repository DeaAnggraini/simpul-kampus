import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiGagal implements Exception {
  ApiGagal(this.pesan, {this.status});
  final String pesan;
  final int? status;
  @override
  String toString() => pesan;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  String? token;

  /// Dipanggil bila server menjawab 401 saat sudah login (sesi habis).
  Future<void> Function()? saatSesiHabis;

  Future<Map<String, dynamic>> kirim(
    String metode,
    String jalur, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl/$jalur').replace(queryParameters: query);
    final req = http.Request(metode, uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Content-Type'] = 'application/json';
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    if (body != null) req.body = jsonEncode(body);

    final http.Response res;
    try {
      final stream = await _client
          .send(req)
          .timeout(const Duration(seconds: 10));
      res = await http.Response.fromStream(stream);
    } on Exception {
      throw ApiGagal(
        'Server tidak dapat dihubungi. Periksa XAMPP dan alamat API.',
      );
    }

    final Map<String, dynamic> data;
    try {
      data = res.body.isEmpty
          ? {}
          : jsonDecode(res.body) as Map<String, dynamic>;
    } on FormatException {
      throw ApiGagal(
        'Jawaban server bukan JSON. Periksa kode PHP.',
        status: res.statusCode,
      );
    }

    if (res.statusCode >= 400) {
      if (res.statusCode == 401 && token != null && jalur != 'keluar.php') {
        await saatSesiHabis?.call();
      }
      throw ApiGagal(
        data['pesan'] as String? ?? 'Terjadi kesalahan (${res.statusCode}).',
        status: res.statusCode,
      );
    }
    return data;
  }
}

/// MySQL kadang mengirim angka sebagai teks. Terima keduanya.
int keInt(Object? nilai) => nilai is int ? nilai : int.parse('$nilai');
