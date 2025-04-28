import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db_helper/database_helper.dart';
import '../models/model_absen.dart';
import '../models/model_user.dart';

class HistoryPage extends StatefulWidget {
  final UserModel user;
  const HistoryPage({super.key, required this.user});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<AbsensiModel> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final data = await DatabaseHelper().getAbsensiByUser(widget.user.id!);
    setState(() {
      _historyList = data;
      _isLoading = false;
    });
  }

  String formatDate(String date) {
    final dt = DateTime.parse(date);
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dt);
  }

  void _deleteAbsensi(int id) async {
    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin menghapus data absensi ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await DatabaseHelper().deleteAbsensi(id); // ✅ DITAMBAHKAN
      await fetchHistory(); // refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data absen berhasil dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Absensi')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _historyList.isEmpty
              ? Center(child: Text("Belum ada riwayat absensi"))
              : ListView.builder(
                itemCount: _historyList.length,
                itemBuilder: (context, index) {
                  final absen = _historyList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        absen.type == 'masuk' ? Icons.login : Icons.logout,
                        color:
                            absen.type == 'masuk' ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        "${absen.type.toUpperCase()} • ${formatDate(absen.date)}",
                      ),
                      subtitle: Text(
                        "Jam: ${absen.time}\nLokasi: ${absen.latitude}, ${absen.longitude}",
                      ),
                      trailing: IconButton(
                        // ✅ DITAMBAHKAN
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => _deleteAbsensi(absen.id!), // ✅ DITAMBAHKAN
                        tooltip: 'Hapus',
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
