import 'package:absen_sqflite/db_helper/database_helper.dart';
import 'package:absen_sqflite/models/model_absen.dart';
import 'package:absen_sqflite/models/model_user.dart';
import 'package:absen_sqflite/pref_handler/preference_handler.dart';
import 'package:absen_sqflite/theme/theme_provider.dart';
import 'package:absen_sqflite/views/history_page.dart';
import 'package:absen_sqflite/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final UserModel user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbHelper = DatabaseHelper();
  bool _hasAbsenMasuk = false;
  bool _hasAbsenPulang = false;

  List<AbsensiModel> _todayAbsen = [];

  @override
  void initState() {
    super.initState();
    _fetchTodayAbsen(); // load absen hari ini saat halaman dibuka
  }

  Future<void> _fetchTodayAbsen() async {
    final data = await dbHelper.getAbsensiTodayByUser(widget.user.id!);
    final masuk = await dbHelper.hasAbsenToday(widget.user.id!, 'masuk');
    final pulang = await dbHelper.hasAbsenToday(widget.user.id!, 'pulang');

    setState(() {
      _todayAbsen = data;
      _hasAbsenMasuk = masuk;
      _hasAbsenPulang = pulang;
    });
  }

  String getTodayFormatted() {
    final now = DateTime.now();
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
  }

  Future<void> _recordAbsensi(String type) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Layanan lokasi tidak aktif. Aktifkan GPS')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Izin lokasi ditolak')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Izin lokasi ditolak permanen. Ubah di pengaturan'),
        ),
      );
      return;
    }

    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final now = DateTime.now();
      final data = AbsensiModel(
        userId: widget.user.id!,
        type: type,
        date: DateFormat('yyyy-MM-dd').format(now),
        time: DateFormat('HH:mm:ss').format(now),
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      await dbHelper.insertAbsensi(data);
      await _fetchTodayAbsen(); // refresh tampilan container setelah absen
      showSuccessDialog(type);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Absen $type berhasil!")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mendapatkan lokasi: $e")));
    }
  }

  void _logout() async {
    await SharedPrefsHelper.clearSession();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  void showSuccessDialog(String type) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Berhasil!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type == 'masuk' ? Icons.login : Icons.logout,
                  size: 60,
                  color: type == 'masuk' ? Colors.green : Colors.red,
                ),
                SizedBox(height: 12),
                Text("Absensi $type berhasil"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nama = widget.user.name;

    return Scaffold(
      // backgroundColor: Color(0xFFF4F6F8),
      appBar: AppBar(
        // actions: [
        //   Consumer<ThemeProvider>(
        //     builder: (context, provider, _) {
        //       return Switch(
        //         value: provider.isDarkMode,
        //         onChanged: (_) => provider.toggleTheme(),
        //         activeColor: Colors.white,
        //       );
        //     },
        //   ),
        //   IconButton(onPressed: _logout, icon: Icon(Icons.logout)),
        // ],
        title: Text("Dashboard Absensi"),
        backgroundColor: Colors.indigo[600],
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                activeColor: Colors.white,
              );
            },
          ),
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout),
            tooltip: "Keluar",
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.indigo[100],
                child: Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 12),
              Text("Selamat datang,", style: TextStyle(fontSize: 16)),
              Text(
                nama,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                getTodayFormatted(),
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 24),

              /// === KARTU TOMBOL ABSEN ===
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                // color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        "Silakan Absen",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed:
                            _hasAbsenMasuk
                                ? null
                                : () => _recordAbsensi('masuk'),
                        icon: Icon(Icons.login),
                        label: Text("Absen Masuk"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed:
                            _hasAbsenPulang
                                ? null
                                : () => _recordAbsensi('pulang'),
                        icon: Icon(Icons.logout),
                        label: Text("Absen Pulang"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HistoryPage(user: widget.user),
                            ),
                          );
                          await _fetchTodayAbsen(); // ✅ Segarkan data setelah kembali dari History
                        },

                        icon: Icon(Icons.history),
                        label: Text("Lihat Riwayat"),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,

                          minimumSize: Size(double.infinity, 50),
                          side: BorderSide(color: Colors.indigo),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              /// === KARTU RIWAYAT HARI INI ===
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Absensi Hari Ini",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(thickness: 1.2),
                    _todayAbsen.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text("Belum ada absensi hari ini"),
                          ),
                        )
                        : ListView.separated(
                          itemCount: _todayAbsen.length,
                          separatorBuilder: (_, __) => Divider(),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final absen = _todayAbsen[index];
                            final isMasuk = absen.type == 'masuk';
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                isMasuk ? Icons.login : Icons.logout,
                                size: 30,
                                color: isMasuk ? Colors.green : Colors.red,
                              ),
                              title: Text(
                                isMasuk ? "Absen Masuk" : "Absen Pulang",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                "Jam: ${absen.time}\nLokasi: ${absen.latitude}, ${absen.longitude}",
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
