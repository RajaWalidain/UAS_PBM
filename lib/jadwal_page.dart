import 'package:flutter/material.dart';
import 'db_helper.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  List<Map<String, dynamic>> _jadwalList = [];

  final _hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  String _hariDipilih = 'Senin';

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    final data = await DBHelper.getJadwal();
    setState(() {
      _jadwalList = data;
    });
  }

  Future<void> _tambahJadwal() async {
    final mapelController = TextEditingController();
    final jamController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Jadwal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _hariDipilih,
              items: _hariList
                  .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _hariDipilih = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Hari'),
            ),
            TextField(
              controller: mapelController,
              decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
            ),
            TextField(
              controller: jamController,
              decoration: const InputDecoration(labelText: 'Jam (contoh: 07.00)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (mapelController.text.isNotEmpty &&
                  jamController.text.isNotEmpty) {
                await DBHelper.insertJadwal(
                  _hariDipilih,
                  mapelController.text,
                  jamController.text,
                );
                await _loadJadwal();
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _hapusJadwal(int id) async {
    await DBHelper.deleteJadwal(id);
    await _loadJadwal();
  }

  @override
  Widget build(BuildContext context) {
    final jadwalHariIni = _jadwalList
        .where((item) => item['hari'] == _hariDipilih)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Pelajaran'),
        actions: [
          DropdownButton<String>(
            value: _hariDipilih,
            items: _hariList
                .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _hariDipilih = value);
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: jadwalHariIni.length,
        itemBuilder: (context, index) {
          final item = jadwalHariIni[index];
          return ListTile(
            leading: const Icon(Icons.class_),
            title: Text(item['mapel']),
            subtitle: Text('Jam ${item['jam']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _hapusJadwal(item['id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahJadwal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
