import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';
import 'notification_service.dart'; // pastikan sudah import ini

class TugasPage extends StatefulWidget {
  const TugasPage({super.key});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  List<Map<String, dynamic>> _daftarTugas = [];

  @override
  void initState() {
    super.initState();
    _loadTugas();
  }

  Future<void> _loadTugas() async {
    final data = await DBHelper.getTugas();
    setState(() {
      _daftarTugas = data;
    });
  }

  Future<void> _tambahTugas() async {
    final judulController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Tugas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: judulController,
              decoration: const InputDecoration(labelText: 'Judul Tugas'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text(
                selectedDate == null
                    ? 'Pilih Deadline'
                    : DateFormat.yMMMMd().format(selectedDate!),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (judulController.text.isNotEmpty && selectedDate != null) {
                await DBHelper.insertTugas(
                  judulController.text,
                  selectedDate!.toIso8601String(),
                );

                // ⏰ Atur notifikasi 1 jam sebelum deadline
                final reminderTime =
                    selectedDate!.subtract(const Duration(hours: 1));

                final idNotif = DateTime.now().millisecondsSinceEpoch ~/ 1000;

                await NotificationService.scheduleNotification(
                  id: idNotif,
                  title: 'Pengingat Tugas',
                  body:
                      'Tugas "${judulController.text}" akan segera deadline!',
                  scheduledTime: reminderTime,
                );

                await _loadTugas();
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(int id, int status) async {
    await DBHelper.updateSelesai(id, status);
    await _loadTugas();
  }

  Future<void> _hapusTugas(int id) async {
    await DBHelper.deleteTugas(id);
    await _loadTugas();
  }

  @override
  Widget build(BuildContext context) {
    final aktif = _daftarTugas.where((t) => t['selesai'] == 0).toList();
    final selesai = _daftarTugas.where((t) => t['selesai'] == 1).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tugas Belajar'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Aktif'),
            Tab(text: 'Selesai'),
          ]),
        ),
        body: TabBarView(
          children: [
            _buildListTugas(aktif),
            _buildListTugas(selesai),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _tambahTugas,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildListTugas(List<Map<String, dynamic>> tugasList) {
    if (tugasList.isEmpty) {
      return const Center(child: Text('Belum ada tugas.'));
    }

    return ListView.builder(
      itemCount: tugasList.length,
      itemBuilder: (context, index) {
        final tugas = tugasList[index];
        final deadline = DateFormat.yMMMMd()
            .format(DateTime.parse(tugas['deadline']));

        return ListTile(
          leading: IconButton(
            icon: Icon(
              tugas['selesai'] == 1
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: tugas['selesai'] == 1 ? Colors.green : null,
            ),
            onPressed: () => _updateStatus(
              tugas['id'],
              tugas['selesai'] == 1 ? 0 : 1,
            ),
          ),
          title: Text(
            tugas['judul'],
            style: TextStyle(
              decoration: tugas['selesai'] == 1
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: Text('Deadline: $deadline'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _hapusTugas(tugas['id']),
          ),
        );
      },
    );
  }
}
