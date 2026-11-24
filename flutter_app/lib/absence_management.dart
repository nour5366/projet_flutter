import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'absence_stats.dart';
import 'api_config.dart';

class AbsenceManagement extends StatefulWidget {
  const AbsenceManagement({super.key});

  @override
  State<AbsenceManagement> createState() => _AbsenceManagementState();
}

class _AbsenceManagementState extends State<AbsenceManagement> {
  // Sélections en cascade conformes à Suite TP7 (p. 1)
  String? selectedDept;
  String? selectedClass;
  String? selectedEtudiantNce;

  List<Map<String, dynamic>> departements = [];
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> etudiants = [];
  List<Map<String, dynamic>> matieres = [];
  List<Map<String, dynamic>> absences = [];

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();

  String get baseUrl => ApiConfig.baseUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    setState(() => isLoading = true);
    try {
      // Chargement des départements depuis l'API
      final resDept = await http.get(Uri.parse('$baseUrl/api/departements'));
      if (resDept.statusCode == 200) {
        departements = List<Map<String, dynamic>>.from(jsonDecode(resDept.body));
      }

      // Chargement des matières depuis l'API
      final resMat = await http.get(Uri.parse('$baseUrl/api/matieres'));
      if (resMat.statusCode == 200) {
        matieres = List<Map<String, dynamic>>.from(jsonDecode(resMat.body));
      }
    } catch (e) {
      // API indisponible : données par défaut
      _showError('Erreur de connexion au serveur : vérifiez que le backend est démarré sur le port 8081.');
    }

    // Données par défaut si l'API ne répond pas
    if (departements.isEmpty) {
      departements = [
        {'codDept': 'TI', 'nomDept': "Technologies de l'Informatique"},
        {'codDept': 'GE', 'nomDept': 'Génie Électrique'},
      ];
    }
    if (matieres.isEmpty) {
      matieres = [
        {'codMat': 'AFCP', 'intMat': 'Atelier Flutter'},
        {'codMat': 'SOA', 'intMat': 'Spring Boot'},
        {'codMat': 'BD', 'intMat': 'Base de Données'},
        {'codMat': 'DEV', 'intMat': 'DevOps'},
      ];
    }

    if (departements.isNotEmpty) {
      selectedDept = departements.first['codDept'] as String;
      await loadClasses(selectedDept!);
    }
    setState(() => isLoading = false);
  }

  Future<void> loadClasses(String codDept) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/classes?codDept=$codDept'));
      if (res.statusCode == 200) {
        classes = List<Map<String, dynamic>>.from(jsonDecode(res.body));
      }
    } catch (_) {}

    if (classes.isEmpty) {
      classes = [
        {'codClass': 'DSI33', 'nomClass': 'DSI 3.3', 'codDept': 'TI'},
        {'codClass': 'DSI31', 'nomClass': 'DSI 3.1', 'codDept': 'TI'},
        {'codClass': 'DSI21', 'nomClass': 'DSI 2.1', 'codDept': 'TI'},
      ];
    }

    if (classes.isNotEmpty) {
      selectedClass = classes.first['codClass'] as String;
      await loadEtudiants(selectedClass!);
    }
    setState(() {});
  }

  Future<void> loadEtudiants(String codClass) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/etudiants?codClass=$codClass'));
      if (res.statusCode == 200) {
        etudiants = List<Map<String, dynamic>>.from(jsonDecode(res.body));
      }
    } catch (_) {}

    if (etudiants.isEmpty) {
      etudiants = [
        {'nce': 'E1', 'nom': 'Ben Foulen1', 'prenom': 'Foulen1', 'dateNais': '2003-05-14', 'lieuNais': 'Nabeul'},
        {'nce': 'E2', 'nom': 'Trabelsi', 'prenom': 'Ahmed', 'dateNais': '2003-08-22', 'lieuNais': 'Tunis'},
      ];
    }

    if (etudiants.isNotEmpty) {
      await selectEtudiant(etudiants.first['nce'] as String);
    }
    setState(() {});
  }

  Future<void> selectEtudiant(String nce) async {
    selectedEtudiantNce = nce;
    final etud = etudiants.firstWhere((e) => e['nce'] == nce, orElse: () => etudiants.first);
    _nomController.text = etud['nom'] ?? '';
    _prenomController.text = etud['prenom'] ?? '';
    await loadAbsences(nce);
  }

  /// Charge les absences d'un étudiant depuis l'API
  Future<void> loadAbsences(String nce) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/absences/by-etudiant/$nce'));
      if (res.statusCode == 200) {
        final raw = List<dynamic>.from(jsonDecode(res.body));
        absences = raw.map((item) {
          // L'API retourne {id, dateA, nha, matiere:{codMat, intMat}, etudiant:{nce,...}}
          return {
            'id': item['id'],
            'dateA': item['dateA'] ?? '',
            'codMat': item['matiere']?['codMat'] ?? item['codMat'] ?? '',
            'nha': (item['nha'] as num).toDouble(),
          };
        }).toList();
      }
    } catch (e) {
      _showError('Impossible de charger les absences : $e');
    }
    setState(() => isLoading = false);
  }

  /// Ajoute ou modifie une absence via l'API
  void showAddDialog([Map<String, dynamic>? editItem]) {
    final dateCtrl = TextEditingController(text: editItem?['dateA'] ?? '12-11-2025');
    final nhaCtrl = TextEditingController(text: (editItem?['nha'] ?? 1.5).toString());
    String currentMat = editItem?['codMat'] ?? (matieres.isNotEmpty ? matieres.first['codMat'] as String : 'AFCP');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(editItem == null ? 'Ajouter une Absence' : "Modifier l'Absence"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: currentMat,
                decoration: const InputDecoration(labelText: 'Matière (CodMat)'),
                items: matieres.map((m) {
                  return DropdownMenuItem<String>(
                    value: m['codMat'] as String,
                    child: Text('${m['codMat']} - ${m['intMat']}'),
                  );
                }).toList(),
                onChanged: (val) => setDialogState(() => currentMat = val ?? currentMat),
              ),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(labelText: 'Date Absence (JJ-MM-AAAA)'),
              ),
              TextField(
                controller: nhaCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Nombre d'heures (NHA)"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                final double nha = double.tryParse(nhaCtrl.text) ?? 1.5;
                Navigator.pop(ctx);
                if (editItem != null) {
                  await updateAbsence(editItem['id'] as int, currentMat, dateCtrl.text, nha);
                } else {
                  await createAbsence(currentMat, dateCtrl.text, nha);
                }
              },
              child: Text(editItem == null ? 'Ajouter' : 'Mettre à jour'),
            ),
          ],
        ),
      ),
    );
  }

  /// POST /api/absences — Crée une absence dans MySQL via l'API
  Future<void> createAbsence(String codMat, String dateA, double nha) async {
    if (selectedEtudiantNce == null) return;
    try {
      final body = jsonEncode({
        'nce': selectedEtudiantNce,
        'codMat': codMat,
        'dateA': dateA,
        'nha': nha,
      });
      final res = await http.post(
        Uri.parse('$baseUrl/api/absences'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (res.statusCode == 200) {
        _showSuccess('Absence ajoutée avec succès dans la base de données.');
        await loadAbsences(selectedEtudiantNce!);
      } else {
        _showError('Erreur lors de l\'ajout : ${res.body}');
      }
    } catch (e) {
      _showError('Erreur réseau : $e');
    }
  }

  /// PUT /api/absences/{id} — Met à jour une absence dans MySQL
  Future<void> updateAbsence(int id, String codMat, String dateA, double nha) async {
    try {
      final body = jsonEncode({'codMat': codMat, 'dateA': dateA, 'nha': nha});
      final res = await http.put(
        Uri.parse('$baseUrl/api/absences/$id'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (res.statusCode == 200) {
        _showSuccess('Absence modifiée avec succès.');
        await loadAbsences(selectedEtudiantNce!);
      } else {
        _showError('Erreur lors de la modification : ${res.body}');
      }
    } catch (e) {
      _showError('Erreur réseau : $e');
    }
  }

  /// DELETE /api/absences/{id} — Supprime une absence de MySQL
  Future<void> deleteAbsence(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette absence ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final res = await http.delete(Uri.parse('$baseUrl/api/absences/$id'));
      if (res.statusCode == 200) {
        _showSuccess('Absence supprimée avec succès.');
        await loadAbsences(selectedEtudiantNce!);
      } else {
        _showError('Erreur lors de la suppression : ${res.body}');
      }
    } catch (e) {
      _showError('Erreur réseau : $e');
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 6)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suite TP7 : Gestion des absences'),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Statistiques & Courbe',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AbsenceStats(
                    classe: selectedClass ?? 'DSI33',
                    dept: selectedDept ?? 'TI',
                    nce: selectedEtudiantNce ?? 'E1',
                    nom: _nomController.text,
                    prenom: _prenomController.text,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: isLoading && absences.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Étape 2 Suite TP7: 3 listes déroulantes en cascade
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          // Liste 1: Départements
                          Row(
                            children: [
                              const SizedBox(width: 120, child: Text('1. Département:', style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedDept,
                                  items: departements.map((d) {
                                    return DropdownMenuItem<String>(
                                      value: d['codDept'] as String,
                                      child: Text("${d['codDept']} - ${d['nomDept']}"),
                                    );
                                  }).toList(),
                                  onChanged: (val) async {
                                    if (val != null) {
                                      setState(() {
                                        selectedDept = val;
                                        classes = [];
                                        etudiants = [];
                                        absences = [];
                                        selectedClass = null;
                                        selectedEtudiantNce = null;
                                      });
                                      await loadClasses(val);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          // Liste 2: Classes du département sélectionné
                          Row(
                            children: [
                              const SizedBox(width: 120, child: Text('2. Classe:', style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedClass,
                                  items: classes.map((c) {
                                    return DropdownMenuItem<String>(
                                      value: c['codClass'] as String,
                                      child: Text("${c['codClass']} (${c['nomClass']})"),
                                    );
                                  }).toList(),
                                  onChanged: (val) async {
                                    if (val != null) {
                                      setState(() {
                                        selectedClass = val;
                                        etudiants = [];
                                        absences = [];
                                        selectedEtudiantNce = null;
                                      });
                                      await loadEtudiants(val);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          // Liste 3: Étudiants de la classe sélectionnée
                          Row(
                            children: [
                              const SizedBox(width: 120, child: Text('3. Étudiant:', style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedEtudiantNce,
                                  items: etudiants.map((e) {
                                    return DropdownMenuItem<String>(
                                      value: e['nce'] as String,
                                      child: Text("${e['nce']} - ${e['nom']} ${e['prenom']}"),
                                    );
                                  }).toList(),
                                  onChanged: (val) async {
                                    if (val != null) await selectEtudiant(val);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Zones de texte pour le Nom et Prénom de l'étudiant
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nomController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Nom de l'étudiant",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _prenomController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: "Prénom de l'étudiant",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tableau des absences de l'étudiant (DateA, CodMat, NHA)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tableau des Absences :',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text('Total : ${absences.length} ligne(s)', style: const TextStyle(color: Colors.grey)),
                          if (isLoading) const SizedBox(width: 10),
                          if (isLoading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
                        columns: const [
                          DataColumn(label: Text('DateA', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('CodMat', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('NHA (heures)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: absences.map((a) {
                          return DataRow(cells: [
                            DataCell(Text(a['dateA'] ?? '')),
                            DataCell(Chip(
                              label: Text(a['codMat'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              backgroundColor: a['codMat'] == 'AFCP' ? Colors.blue.shade100 : Colors.purple.shade100,
                            )),
                            DataCell(Text("${a['nha']} h")),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () => showAddDialog(a),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => deleteAbsence(a['id'] as int),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      // Bouton Ajouter (+) en bas de la fenêtre (Suite TP7 p. 1)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddDialog(),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une Absence'),
      ),
    );
  }
}
