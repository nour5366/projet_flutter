import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'api_config.dart';

class AbsenceStats extends StatefulWidget {
  final String? classe;
  final String? dept;
  final String? nce;
  final String? nom;
  final String? prenom;
  const AbsenceStats({super.key, this.classe, this.dept, this.nce, this.nom, this.prenom});
  @override
  State<AbsenceStats> createState() => _AbsenceStatsState();
}

class _AbsenceStatsState extends State<AbsenceStats> {
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> stats = [];
  String? selectedClass;
  String? selectedStudent;
  Map<String, dynamic>? studentInfo;
  bool loading = false;
  bool initialLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/classes'));
      if (response.statusCode != 200) throw Exception('Chargement des classes (${response.statusCode})');
      final data = List<Map<String, dynamic>>.from(jsonDecode(response.body).map((e) => Map<String, dynamic>.from(e)));
      if (!mounted) return;
      setState(() { classes = data; initialLoading = false; });
      if (widget.classe != null && data.any((e) => (e['codClass'] ?? e['cod_class']) == widget.classe)) {
        await _selectClass(widget.classe!);
        if (widget.nce != null && students.any((e) => e['nce'].toString() == widget.nce)) {
          await _selectStudent(widget.nce!);
        }
      }
    } catch (e) {
      if (mounted) setState(() { initialLoading = false; error = 'Impossible de charger les classes : $e'; });
    }
  }

  Future<void> _selectClass(String code) async {
    setState(() { selectedClass = code; selectedStudent = null; studentInfo = null; students = []; stats = []; error = null; });
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/etudiants?codClass=${Uri.encodeQueryComponent(code)}'));
      if (response.statusCode != 200) throw Exception('Erreur ${response.statusCode}');
      final data = List<Map<String, dynamic>>.from(jsonDecode(response.body).map((e) => Map<String, dynamic>.from(e)));
      if (mounted) setState(() => students = data);
    } catch (e) { if (mounted) setState(() => error = 'Impossible de charger les étudiants : $e'); }
  }

  Future<void> _selectStudent(String nce) async {
    setState(() { selectedStudent = nce; loading = true; stats = []; error = null; });
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('${ApiConfig.baseUrl}/api/etudiants/${Uri.encodeComponent(nce)}')),
        http.get(Uri.parse('${ApiConfig.baseUrl}/api/absences/stats/${Uri.encodeComponent(nce)}')),
      ]);
      if (responses[0].statusCode != 200 || responses[1].statusCode != 200) throw Exception('Erreur serveur (${responses[0].statusCode}/${responses[1].statusCode})');
      final info = Map<String, dynamic>.from(jsonDecode(responses[0].body));
      final raw = List<dynamic>.from(jsonDecode(responses[1].body));
      final result = raw.map((e) => <String, dynamic>{'codMat': e['codMat'].toString(), 'totalNHA': (e['totalNHA'] as num).toDouble()}).toList();
      if (!mounted) return;
      setState(() { studentInfo = info; stats = result; loading = false; });
    } catch (e) { if (mounted) setState(() { loading = false; error = 'Impossible de charger les absences : $e'; }); }
  }

  double get total => stats.fold(0.0, (sum, item) => sum + (item['totalNHA'] as double));
  double get maxY => stats.isEmpty ? 5 : (stats.map((e) => e['totalNHA'] as double).reduce((a,b) => a > b ? a : b) + 2).ceilToDouble();
  String _s(dynamic value) => value?.toString() ?? '-';

  @override
  Widget build(BuildContext context) {
    final classeObj = studentInfo?['classe'] as Map<String, dynamic>?;
    final deptObj = classeObj?['departement'] as Map<String, dynamic>?;
    return Scaffold(
      appBar: AppBar(title: const Text('Total & courbe des absences'), backgroundColor: const Color(0xFF6A1B9A), foregroundColor: Colors.white,
        actions: [IconButton(onPressed: selectedStudent == null ? null : () => _selectStudent(selectedStudent!), icon: const Icon(Icons.refresh), tooltip: 'Actualiser')]),
      body: initialLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          DropdownButtonFormField<String>(value: selectedClass, decoration: const InputDecoration(labelText: 'Classe', border: OutlineInputBorder()),
            items: classes.map((e) { final code = (e['codClass'] ?? e['cod_class']).toString(); return DropdownMenuItem(value: code, child: Text('$code - ${e['nomClass'] ?? e['nom_class'] ?? ''}')); }).toList(),
            onChanged: (v) { if (v != null) _selectClass(v); }),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: selectedStudent, decoration: const InputDecoration(labelText: 'Étudiant', border: OutlineInputBorder()),
            items: students.map((e) => DropdownMenuItem(value: e['nce'].toString(), child: Text('${e['nce']} - ${e['nom']} ${e['prenom']}'))).toList(),
            onChanged: students.isEmpty ? null : (v) { if (v != null) _selectStudent(v); }),
          if (error != null) ...[const SizedBox(height: 12), Text(error!, style: const TextStyle(color: Colors.red))],
          if (loading) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
          if (!loading && studentInfo != null) ...[
            const SizedBox(height: 16),
            Card(color: Colors.purple.shade50, child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Classe : ${_s(classeObj?['codClass'])}     Département : ${_s(deptObj?['codDept'])}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
              const Divider(), Text('Étudiant : ${_s(studentInfo?['nce'])}'), Text('Nom : ${_s(studentInfo?['nom'])}'), Text('Prénom : ${_s(studentInfo?['prenom'])}'),
            ]))),
            const SizedBox(height: 16), const Text('Total des absences par matière', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (stats.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Aucune absence enregistrée pour cet étudiant.'))
            else Card(child: Column(children: [
              DataTable(columns: const [DataColumn(label: Text('CodMat')), DataColumn(label: Text('Total NHA'))], rows: stats.map((e) => DataRow(cells: [DataCell(Text(e['codMat'])), DataCell(Text('${e['totalNHA']} h'))])).toList()),
              Padding(padding: const EdgeInsets.all(14), child: Align(alignment: Alignment.centerRight, child: Text('Total des absences / semestre : ${total.toStringAsFixed(2)} h', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)))),
            ])),
            const SizedBox(height: 22), const Text('Courbe des absences par matière', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (stats.isNotEmpty) Card(child: Padding(padding: const EdgeInsets.fromLTRB(12, 20, 20, 12), child: SizedBox(height: 270, child: LineChart(LineChartData(
              minY: 0, maxY: maxY, gridData: const FlGridData(show: true), borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v,m) => Text('${v.toInt()}h', style: const TextStyle(fontSize: 10)))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36, getTitlesWidget: (v,m) { final i=v.toInt(); return i>=0 && i<stats.length ? Padding(padding: const EdgeInsets.only(top: 8), child: Text(stats[i]['codMat'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))) : const SizedBox.shrink(); })),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
              lineBarsData: [LineChartBarData(isCurved: true, color: const Color(0xFF6A1B9A), barWidth: 3, dotData: const FlDotData(show: true), spots: stats.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['totalNHA'] as double)).toList())],
            ))))),
          ],
        ])),
    );
  }
}
