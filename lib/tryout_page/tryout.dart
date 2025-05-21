import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryout_app/api_helper.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
import 'package:tryout_app/auth/login.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:tryout_app/home.dart';
import 'package:tryout_app/tryout_page/result.dart';

class TryOutPage extends StatefulWidget {
  const TryOutPage({super.key});

  @override
  State<TryOutPage> createState() => _TryOutPageState();
}

class _TryOutPageState extends State<TryOutPage> {
  final TextEditingController laporanController = TextEditingController();
  String username = 'User';
  String lastScore = 'Tidak Ada';
  List<dynamic> questions = [];
  int? questionNumber;
  int? currentNumber = 1;
  int? currentQuestionId = 1;
  Map<String, dynamic>? currentQuestion;
  int? NoSoal;
  String? Soal;
  List<dynamic>? options;
  int? optionLength;
  bool selesai = false;
  Map<String, dynamic>? currentAnswer;

  @override
  void initState() {
    super.initState();
    loadQuestions();
    loadQuestion(currentNumber);
  }

  Future<void> loadQuestions() async {
    try {
      context.loaderOverlay.show();
      final result = await ApiService.get('/tryout/question');
      setState(() {
        questions = result['data'];
        questionNumber = questions.length;
      });
    } catch (e) {
      print(e);
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> loadQuestion(num) async {
    try {
      context.loaderOverlay.show();
      final result = await ApiService.get('/tryout/question/$num');
      setState(() {
        currentQuestion = result['data'];
        NoSoal = currentQuestion?['no_soal'] ?? 0;
        Soal = currentQuestion?['soal'].toString();
        options = currentQuestion?['tryout_question_option'];
        optionLength = options?.length;
        currentNumber = num;
      });
      currentAnswer = await getAnswer(currentNumber.toString());
    } catch (e) {
      print(e);
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> nextQuestion(num) async {
    try {
      context.loaderOverlay.show();
      if (num < questionNumber) {
        var number = num + 1;
        final result = await ApiService.get('/tryout/question/$number');
        setState(() {
          currentQuestion = result['data'];
          NoSoal = currentQuestion?['no_soal'] ?? 0;
          Soal = currentQuestion?['soal'].toString();
          options = currentQuestion?['tryout_question_option'];
          currentNumber = number;
          optionLength = options?.length;
        });
        currentAnswer = await getAnswer(currentNumber.toString());
      }
    } catch (e) {
      print(e);
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> previousQuestion(num) async {
    try {
      context.loaderOverlay.show();
      if (num > 1) {
        var number = num - 1;
        final result = await ApiService.get('/tryout/question/$number');
        setState(() {
          currentQuestion = result['data'];
          NoSoal = currentQuestion?['no_soal'] ?? 0;
          Soal = currentQuestion?['soal'].toString();
          options = currentQuestion?['tryout_question_option'];
          currentNumber = number;
          optionLength = options?.length;
        });
        currentAnswer = await getAnswer(currentNumber.toString());
      }
    } catch (e) {
      print(e);
    } finally {
      context.loaderOverlay.hide();
    }
  }

  Future<void> saveAnswer(
    String questionId, {
    required String jawaban,
    required int nilai,
    required bool benar,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing saved answers
    final answersString = prefs.getString('answers') ?? '{}';
    final Map<String, dynamic> savedAnswers = Map<String, dynamic>.from(
      jsonDecode(answersString),
    );

    // Update answer
    savedAnswers[questionId] = {
      'jawaban': jawaban,
      'nilai': nilai,
      'benar': benar,
    };

    // Save back to SharedPreferences
    await prefs.setString('answers', jsonEncode(savedAnswers));
  }

  Future<void> sendReport(
    BuildContext context,
    TextEditingController laporanController,
  ) async {
    final laporanText = laporanController.text.trim();

    if (laporanText.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Laporan tidak boleh kosong."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      if (context.mounted) context.loaderOverlay.show();

      final result = await ApiService.post('/tryout/lapor-soal/create', {
        'tryout_question_id': currentQuestion?['id'],
        'laporan': laporanText,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Laporan berhasil dikirim."),
            backgroundColor: Colors.green,
          ),
        );
      }

      laporanController.clear();
    } catch (e) {
      print("Error saat mengirim laporan: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengirim laporan. Silakan coba lagi."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (context.mounted) context.loaderOverlay.hide();
      context.loaderOverlay.hide();
    }
  }

  Future<Map<String, dynamic>?> getAnswer(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final answersString = prefs.getString('answers') ?? '{}';
    final Map<String, dynamic> savedAnswers = Map<String, dynamic>.from(
      jsonDecode(answersString),
    );

    final answer = savedAnswers[questionId];
    if (answer is Map<String, dynamic>) return answer;
    if (answer is Map) return Map<String, dynamic>.from(answer); // fallback
    return null;
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

  // Fungsi untuk menampilkan dialog konfirmasi logout
  Future<bool?> showSelesaiConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Selesai"),
          content: const Text("Apakah kamu yakin ingin mengakhiri ujian?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // batal logout
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed:
                  () => Navigator.of(context).pop(true), // konfirmasi logout
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );
  }

  Future<void> result(BuildContext context) async {
    final confirm = await showSelesaiConfirmationDialog(context);
    if (confirm != true) return;

    try {
      context.loaderOverlay.show();

      int nilai = 0;

      for (int i = 1; i < questions.length; i++) {
        Map<String, dynamic>? currentAnswer = await getAnswer(i.toString());

        if (currentAnswer == null) {
          context.loaderOverlay.hide();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Soal nomor ${i} belum dijawab."),
              backgroundColor: Colors.red,
            ),
          );
          return; // keluar dari fungsi jika ada jawaban yang kosong
        }

        int? currentNilai = currentAnswer['nilai'];
        nilai += currentNilai?.toInt() ?? 0;
      }

      // Bersihkan data lokal dan simpan skor
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('answers');
      await prefs.remove('last-score');
      await prefs.setString('last-score', nilai.toString());

      // Bisa lanjut navigasi ke halaman hasil, misalnya:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResultPage(nilai: nilai)));
    } catch (e) {
      print("Error saat menghitung hasil: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan saat menyelesaikan tryout."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      context.loaderOverlay.hide();
    }

    // Navigasi ke halaman login setelah loading hilang
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ResultPage()),
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
                          );
                        },
                        child: const Text('Ya'),
                      ),
                    ],
                  ),
            );
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Soal No. $NoSoal",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          () => showModalBottomSheet(
                            context: context,
                            isScrollControlled:
                                true, // Penting agar tidak terpotong saat keyboard muncul
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          "Keterangan",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: laporanController,
                                          maxLines: 4,
                                          decoration: const InputDecoration(
                                            hintText:
                                                "Tulis keteranganmu di sini...",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text("Batal"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await sendReport(
                                                  context,
                                                  laporanController,
                                                );
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Laporkan"),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                      icon: const Icon(Icons.report, color: Colors.black),
                      label: const Text(
                        "Laporkan Soal",
                        style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color.fromARGB(255, 255, 0, 0),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Html(
                  data: Soal ?? "Loading...",
                ), // pastikan Soal bertipe String
                const SizedBox(height: 16),
                const Text(
                  "Pilih Jawaban:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),

                /// Scrollable list of choices
                Expanded(
                  child: ListView.builder(
                    itemCount: optionLength,
                    itemBuilder: (context, index) {
                      final opsi = options?[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          onTap: () async {
                            await saveAnswer(
                              currentNumber.toString(),
                              jawaban: opsi['inisial'],
                              nilai: opsi['nilai'],
                              benar: opsi['iscorrect'] == 1,
                            );
                            await loadQuestion(currentNumber);
                          },
                          title: Html(
                            data:
                                '${opsi?['inisial'] ?? ''}. ${opsi?['jawaban'] ?? 'Loading...'}',
                          ),
                          trailing:
                              currentAnswer?['jawaban'] == opsi?['inisial']
                                  ? const Icon(
                                    Icons.circle_outlined,
                                    color: Color.fromARGB(255, 29, 210, 47),
                                  )
                                  : null,
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => previousQuestion(currentNumber),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        label: const Text(
                          "Sebelumnya",
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color.fromARGB(255, 0, 0, 0),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12), // jarak antar tombol
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            () =>
                                currentNumber == questions.length
                                    ? result(context)
                                    : nextQuestion(currentNumber),
                        icon:
                            currentNumber == questions.length
                                ? Icon(
                                  Icons.check,
                                  color: Color.fromARGB(255, 20, 175, 0),
                                )
                                : Icon(
                                  Icons.arrow_forward,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                        label:
                            currentNumber == questions.length
                                ? Text(
                                  "Selesai",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 20, 175, 0),
                                  ),
                                )
                                : Text(
                                  "Selanjutnya",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                        style: OutlinedButton.styleFrom(
                          side:
                              currentNumber == questions.length
                                  ? BorderSide(
                                    color: Color.fromARGB(255, 20, 175, 0),
                                    width: 2,
                                  )
                                  : BorderSide(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    width: 2,
                                  ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
