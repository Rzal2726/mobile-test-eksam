import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryout_app/api_helper.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
import 'package:tryout_app/auth/login.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:tryout_app/home.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String username = 'User';
  String lastScore = 'Tidak Ada';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
      lastScore = prefs.getString('last-score') ?? 'Tidak Ada';
    });
  }

  void goToTryout() {
    context.loaderOverlay.show();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultPage()),
    ); // pastikan route ini sudah diset
    context.loaderOverlay.hide();
  }

  // Fungsi untuk menampilkan dialog konfirmasi logout
  Future<bool?> showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah kamu yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // batal logout
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed:
                  () => Navigator.of(context).pop(true), // konfirmasi logout
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    final confirm = await showLogoutConfirmationDialog(context);
    if (confirm != true) return;

    try {
      context.loaderOverlay.show();

      // Panggil API logout
      await ApiService.post('/auth/logout', {});

      // Bersihkan data lokal
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print("Logout error: $e");
      // Tampilkan snackbar error jika perlu
    } finally {
      context.loaderOverlay.hide();
    }

    // Navigasi ke halaman login setelah loading hilang
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Aplikasi TryOut"),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3F5EFB), Color(0xFFFC466B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              logout(context);
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Tuliskan fungsi custom di sini
            // Contoh: konfirmasi keluar
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: const Text('Apakah kamu yakin ingin kembali?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(), // batal
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // tutup dialog
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WelcomePage(),
                            ),
                          ); // keluar halaman sekarang (kembali)
                        },
                        child: const Text('Ya'),
                      ),
                    ],
                  ),
            );
          },
        ),
      ),
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selamat $username Kamu Telah Menyelesaikan Ujian Dengan Nilai',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    // tambahkan fungsi jika perlu
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            lastScore,
                            style: TextStyle(fontSize: 64, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Konfirmasi'),
                            content: const Text(
                              'Apakah kamu yakin ingin kembali?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(), // batal
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // tutup dialog
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WelcomePage(),
                                    ),
                                  ); // keluar halaman sekarang (kembali)
                                },
                                child: const Text('Ya'),
                              ),
                            ],
                          ),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home, size: 24, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                ),
                // const Text("Klik Tombol Di Atas Untuk Mulai Tryout"),
                // const SizedBox(height: 12),
                // Text("Nilai Terakhir: $lastScore"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper Extension for Gradient AppBar (optional)
extension GradientAppBar on Shader {
  PreferredSizeWidget createShaderAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3F5EFB), Color(0xFFFC466B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
