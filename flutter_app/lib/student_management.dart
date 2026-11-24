import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class StudentManagement extends StatefulWidget {
  const StudentManagement({Key? key}) : super(key: key);

  @override
  State<StudentManagement> createState() => _StudentManagementState();
}

class _StudentManagementState extends State<StudentManagement> {
  String selectedClass = 'DSI33';
  final List<String> classes = ['DSI33', 'DSI31', 'DSI23', 'DSI22', 'DSI21', 'RSI31'];
  List<Map<String, dynamic>> students = [];
  bool isLoading = false;

  final String apiUrl = "${ApiConfig.baseUrl}/api/etudiants";

  @override
  void initState() {
    super.initState();
    fetchStudents(selectedClass);
  }

  Future<void> fetchStudents(String codClass) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("$apiUrl?codClass=$codClass"));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          students = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      }
    } catch (e) {
      // Mock fallback pour le dev
      setState(() {
        students = [
          {"nce": "E1", "nom": "Ben Foulen1", "prenom": "Foulen1", "dateNais": "2003-05-14", "lieuNais": "Nabeul"},
          {"nce": "E2", "nom": "Trabelsi", "prenom": "Ahmed", "dateNais": "2003-08-22", "lieuNais": "Tunis"},
          {"nce": "E3", "nom": "Gharbi", "prenom": "Sarra", "dateNais": "2004-01-10", "lieuNais": "Hammamet"},
        ];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page 12 du TP7 : DropDownButton list with classes
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Text(
                      'Classe : ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: selectedClass,
                      hint: const Text('Code Classe'),
                      items: classes.map((String c) {
                        return DropdownMenuItem<String>(
                          value: c,
                          child: Text(c, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (String? newVal) {
                        if (newVal != null) {
                          setState(() => selectedClass = newVal);
                          fetchStudents(newVal);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Étudiants de la classe $selectedClass :',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : students.isEmpty
                      ? const Center(child: Text('Aucun étudiant dans cette classe'))
                      : ListView.separated(
                          itemCount: students.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final s = students[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF1976D2),
                                child: Text(s['nce'] ?? '?', style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text("${s['nom']} ${s['prenom']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Né(e) le : ${s['dateNais']} à ${s['lieuNais']}"),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
