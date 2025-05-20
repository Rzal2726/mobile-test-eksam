import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryout_app/api_helper.dart';
import 'package:flutter_html/flutter_html.dart';

class TryOutPage extends StatefulWidget {
  const TryOutPage({super.key});

  @override
  State<TryOutPage> createState() => _TryOutPageState();
}

class _TryOutPageState extends State<TryOutPage> {
  String username = 'User';
  String lastScore = 'Tidak Ada';
  List<dynamic> questions = [];
  int? questionNumber;
  int? currentNumber = 1;
  Map<String, dynamic>? currentQuestion;
  int? NoSoal;
  String? Soal;
  List<dynamic>? options;
  int? optionLength;

  @override
  void initState() {
    super.initState();
    loadQuestions();
    loadQuestion(currentNumber);
  }

  Future<void> loadQuestions() async {
    try {
      final result = await ApiService.get('/tryout/question');
      setState(() {
        questions = result['data'];
        questionNumber = questions.length;
      });
    } catch (e) {
      print(e);
    }
  }

  void loadQuestion(num) async {
    try {
      final result = await ApiService.get('/tryout/question/$num');
      setState(() {
        currentQuestion = result['data'];
        NoSoal = currentQuestion?['no_soal'] ?? 0;
        Soal = currentQuestion?['soal'].toString();
        options = currentQuestion?['tryout_question_option'];
        print(options);
        optionLength = options?.length;
      });
    } catch (e) {
      print(e);
    }
  }

  void nextQuestion(num) async {
    try {
      if (num < 5) {
        var number = num + 1;
        final result = await ApiService.get('/tryout/question/$number');
        setState(() {
          currentQuestion = result['data'];
          NoSoal = currentQuestion?['no_soal'] ?? 0;
          Soal = currentQuestion?['soal'].toString();
          options = currentQuestion?['tryout_question_option'];
          currentNumber = number;
          print(options);
          optionLength = options?.length;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> previousQuestion(num) async {
    try {
      if (num > 1) {
        var number = num - 1;
        final result = await ApiService.get('/tryout/question/$number');
        setState(() {
          currentQuestion = result['data'];
          NoSoal = currentQuestion?['no_soal'] ?? 0;
          Soal = currentQuestion?['soal'].toString();
          options = currentQuestion?['tryout_question_option'];
          currentNumber = number;
          print(options);
          optionLength = options?.length;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
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
                Text(
                  "Soal No.$NoSoal",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Html(data: Soal ?? ""), // pastikan Soal bertipe String
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
                          onTap: () {
                            // aksi pilih jawaban
                          },
                          title: Text(
                            '${opsi?['inisial']}. ${opsi?['jawaban']}',
                          ),
                          trailing:
                              opsi?['iscorrect'] == 1
                                  ? const Icon(Icons.check, color: Colors.green)
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
                        onPressed: () => nextQuestion(currentNumber),
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        label: const Text(
                          "Selanjutnya",
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
