import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 10.0.2.2 = localhost depuis l'émulateur Android. Mettez l'IP du PC pour un vrai téléphone.
const String baseUrl = 'http://10.0.2.2:8081/api';

/// Question 1 : absences d'une classe pour une matière à une date donnée.
class AbsencePrevision extends StatefulWidget {
  const AbsencePrevision({super.key});

  @override
  State<AbsencePrevision> createState() => _AbsencePrevisionState();
}

class _AbsencePrevisionState extends State<AbsencePrevision> {
  List<dynamic> classes = [];
  List<dynamic> matieres = [];
  String? codClass;
  String? codMat;
  DateTime date = DateTime.now();
  List<dynamic> lignes = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _chargerListes();
  }

  Future<void> _chargerListes() async {
    // Adaptez ces 2 URLs à celles de votre ScolRestController si elles diffèrent.
    final c = await http.get(Uri.parse('$baseUrl/classes'));
    final m = await http.get(Uri.parse('$baseUrl/matieres'));
    setState(() {
      classes = jsonDecode(utf8.decode(c.bodyBytes));
      matieres = jsonDecode(utf8.decode(m.bodyBytes));
    });
  }

  String get dateIso =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _choisirDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => date = d);
  }

  Future<void> _afficher() async {
    if (codClass == null || codMat == null) return;
    setState(() => loading = true);
    final r = await http.get(Uri.parse(
        '$baseUrl/exam/absences?classe=$codClass&matiere=$codMat&date=$dateIso'));
    setState(() {
      lignes = jsonDecode(utf8.decode(r.bodyBytes));
      loading = false;
    });
  }

  String _chsm() {
    final m = matieres.firstWhere((x) => x['codMat'] == codMat, orElse: () => null);
    return m == null ? '' : '${m['chsm'] ?? m['CHSM'] ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absences par classe et matière')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Classe'),
              value: codClass,
              items: classes
                  .map<DropdownMenuItem<String>>((c) => DropdownMenuItem(
                        value: c['codClass'],
                        child: Text('${c['nomClass'] ?? c['codClass']}'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => codClass = v),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Matière'),
              value: codMat,
              items: matieres
                  .map<DropdownMenuItem<String>>((m) => DropdownMenuItem(
                        value: m['codMat'],
                        child: Text('${m['intMat'] ?? m['codMat']}'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => codMat = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('Date : $dateIso')),
                TextButton.icon(
                  onPressed: _choisirDate,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Choisir'),
                ),
              ],
            ),
            ElevatedButton(onPressed: _afficher, child: const Text('Afficher les absences')),
            const SizedBox(height: 12),
            if (codClass != null && codMat != null)
              Text('Classe : $codClass    Matière : $codMat    CHSM : ${_chsm()} heures',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else
              DataTable(
                border: TableBorder.all(),
                columns: const [
                  DataColumn(label: Text('Nom')),
                  DataColumn(label: Text('Prenom')),
                  DataColumn(label: Text('NHA'), numeric: true),
                ],
                rows: lignes
                    .map((l) => DataRow(cells: [
                          DataCell(Text('${l['nom']}')),
                          DataCell(Text('${l['prenom']}')),
                          DataCell(Text('${l['nha']}')),
                        ]))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}