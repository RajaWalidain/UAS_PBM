import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'main.dart'; // untuk akses RuangBelajarApp.of(context)

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final namaController = TextEditingController();
  final kelasController = TextEditingController();
  final jurusanController = TextEditingController();
  final statusController = TextEditingController();

  final List<String> _defaultAvatars = [
    // Tidak digunakan saat ini (gambar dihapus)
  ];

  String? _selectedAvatarPath;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    final profil = await DBHelper.getProfil();
    if (profil != null) {
      namaController.text = profil['nama'] ?? '';
      kelasController.text = profil['kelas'] ?? '';
      jurusanController.text = profil['jurusan'] ?? '';
      statusController.text = profil['status'] ?? '';
      _selectedAvatarPath = profil['foto'];
      debugPrint("Foto profil ditemukan: $_selectedAvatarPath");
    } else {
      debugPrint("Data profil tidak ditemukan.");
    }
    setState(() {});
  }

  Future<void> _simpanProfil() async {
    debugPrint("Menyimpan profil...");
    await DBHelper.saveProfil(
      namaController.text,
      kelasController.text,
      jurusanController.text,
      statusController.text,
      foto: _selectedAvatarPath,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Build dipanggil dengan foto: $_selectedAvatarPath");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Siswa'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
                RuangBelajarApp.of(context)?.toggleTheme(_isDarkMode);
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            // Avatar Besar Tanpa Gambar
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(namaController, 'Nama'),
            const SizedBox(height: 16),
            _buildTextField(kelasController, 'Kelas'),
            const SizedBox(height: 16),
            _buildTextField(jurusanController, 'Jurusan'),
            const SizedBox(height: 16),
            _buildTextField(statusController, 'Status'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _simpanProfil,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.person_outline),
      ),
    );
  }
}
