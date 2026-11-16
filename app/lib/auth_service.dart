import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class Pengguna {
  const Pengguna({required this.id, required this.nama, required this.peran});
  final int id;
  final String nama;
  final String peran;

  factory Pengguna.dariJson(Map<String, dynamic> j) =>
      Pengguna(id: keInt(j['id']), nama: j['nama'] as String, peran: j['peran'] as String);

  Map<String, dynamic> keJson() => {'id': id, 'nama': nama, 'peran': peran};
}

class AuthService extends ChangeNotifier {
  AuthService(this._api, {SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  final ApiClient _api;
  final SharedPreferencesAsync _prefs;

  Pengguna? _pengguna;
  Pengguna? get pengguna => _pengguna; // null berarti belum masuk

  /// Dipanggil sekali saat aplikasi dibuka: pulihkan sesi yang tersimpan.
  Future<void> muat() async {
    final token = await _prefs.getString('token');
    final teks = await _prefs.getString('pengguna');
    if (token != null && teks != null) {
      _api.token = token;
      _pengguna = Pengguna.dariJson(jsonDecode(teks) as Map<String, dynamic>);
      notifyListeners();
    }
  }

  Future<void> masuk(String nim, String sandi) async {
    final data = await _api.kirim('POST', 'masuk.php',
        body: {'nim': nim, 'sandi': sandi});
    final pengguna = Pengguna.dariJson(data['pengguna'] as Map<String, dynamic>);
    _api.token = data['token'] as String;
    await _prefs.setString('token', _api.token!);
    await _prefs.setString('pengguna', jsonEncode(pengguna.keJson()));
    _pengguna = pengguna;
    notifyListeners();
  }

  Future<void> keluar() async {
    try {
      await _api.kirim('POST', 'keluar.php'); // hapus token di server
    } on ApiGagal {
      // token mungkin sudah kedaluwarsa, tetap keluar di aplikasi
    }
    _api.token = null;
    await _prefs.remove('token');
    await _prefs.remove('pengguna');
    _pengguna = null;
    notifyListeners();
  }
}