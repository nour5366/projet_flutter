import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'api_config.dart';

class Exercice1AbsencesScreen extends StatefulWidget {
  const Exercice1AbsencesScreen({super.key});

  @override
  State<Exercice1AbsencesScreen> createState() => _Exercice1AbsencesScreenState();
}

class _Exercice1AbsencesScreenState extends State<Exercice1AbsencesScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedDept;
  String? selectedClass;
  String? selectedMat;
  DateTime? selectedDate;
  final TextEditingController _dateController = TextEditingController();

  List<Map<String, dynamic>> departements = [];
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> matieres = [];

  bool isLoadingLists = false;
  bool isSearching = false;
  String? errorMessage;
  String? noStudentMessage;

  Map<String, dynamic>? searchResult;

  String get baseUrl => ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _loadInitialDropdownData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialDropdownData() async {
    setState(() {
      isLoadingLists = true;
      errorMessage = null;
    });

    try {
      // 1. Charger départements
      final resDept = await http.get(Uri.parse('$baseUrl/api/departements'));
      if (resDept.statusCode == 200) {
        departements = List<Map<String, dynamic>>.from(jsonDecode(resDept.body));
      }

      // 2. Charger matières
      final resMat = await http.get(Uri.parse('$baseUrl/api/matieres'));
      if (resMat.statusCode == 200) {
        matieres = List<Map<String, dynamic>>.from(jsonDecode(resMat.body));
      }

      if (departements.isNotEmpty) {
        selectedDept = departements.first['codDept'];
        await _loadClassesForDept(selectedDept!);
      }
    } catch (e) {
      // Fallback sécurisé en cas d'erreur réseau
      departements = [
        {'codDept': 'TI', 'nomDept': "Technologies de l'Informatique"},
        {'codDept': 'GE', 'nomDept': 'Génie Électrique'},
      ];
      matieres = [
        {'codMat': 'AFCP', 'intMat': 'Atelier Framework Cross-Platform (Flutter)'},
        {'codMat': 'SOA', 'intMat': 'Architecture Orientée Services & Spring Boot'},
        {'codMat': 'BD', 'intMat': 'Bases de Données Avancées'},
        {'codMat': 'DEV', 'intMat': 'Génie Logiciel & DevOps'},
      ];
      if (departements.isNotEmpty) {
        selectedDept = departements.first['codDept'];
        await _loadClassesForDept(selectedDept!);
      }
    } finally {
      setState(() {
        isLoadingLists = false;
      });
    }
  }

  Future<void> _loadClassesForDept(String codDept) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/classes?codDept=$codDept'));
      if (res.statusCode == 200) {
        classes = List<Map<String, dynamic>>.from(jsonDecode(res.body));
      } else {
        classes = [];
      }
    } catch (_) {
      classes = [
        {'codClass': 'DSI33', 'nomClass': 'DSI 3.3', 'codDept': 'TI'},
        {'codClass': 'DSI31', 'nomClass': 'DSI 3.1', 'codDept': 'TI'},
      ];
    }

    if (classes.isNotEmpty) {
      selectedClass = classes.first['codClass'];
    } else {
      selectedClass = null;
    }
    setState(() {});
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime initial = selectedDate ?? DateTime(2025, 11, 18);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Sélectionner la date de la séance',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _submitSearch() async {
    // Validation des champs obligatoires
    if (selectedDept == null || selectedClass == null || selectedMat == null || _dateController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Veuillez remplir tous les champs obligatoires (Département, Classe, Matière et Date).';
      });
      return;
    }

    setState(() {
      isSearching = true;
      errorMessage = null;
      noStudentMessage = null;
      searchResult = null;
    });

    final dateStr = _dateController.text.trim();
    final url = '$baseUrl/api/examen/absences-prevision?codClass=$selectedClass&codMat=$selectedMat&dateA=$dateStr';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          searchResult = data;
          final List etuds = data['etudiants'] ?? [];
          if (etuds.isEmpty) {
            noStudentMessage = data['message'] ?? 'Aucun étudiant n\'existe dans cette classe.';
          }
        });
      } else {
        final errData = jsonDecode(res.body);
        setState(() {
          errorMessage = errData['error'] ?? 'Erreur lors de la récupération des absences.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion au serveur ($baseUrl). Vérifiez que le backend Spring Boot est démarré.';
      });
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      if (departements.isNotEmpty) {
        selectedDept = departements.first['codDept'];
        _loadClassesForDept(selectedDept!);
      }
      if (matieres.isNotEmpty) {
        selectedMat = matieres.first['codMat'];
      } else {
        selectedMat = null;
      }
      selectedDate = null;
      _dateController.clear();
      searchResult = null;
      errorMessage = null;
      noStudentMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6A1B9A);
    const accentColor = Color(0xFF9C27B0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exercice 1 : Consultation des Absences',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF5F5FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Carte Formulaire de sélection
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.filter_alt, color: primaryColor),
                          SizedBox(width: 8),
                          Text(
                            'Critères de consultation',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      if (isLoadingLists)
                        const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                      else ...[
                        // 1. Liste déroulante Département
                        DropdownButtonFormField<String>(
                          value: selectedDept,
                          decoration: InputDecoration(
                            labelText: 'Département *',
                            prefixIcon: const Icon(Icons.business, color: primaryColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: departements.map((dept) {
                            final code = dept['codDept'] as String;
                            final nom = dept['nomDept'] as String? ?? code;
                            return DropdownMenuItem<String>(
                              value: code,
                              child: Text('$code - $nom', overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedDept = val;
                              });
                              _loadClassesForDept(val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // 2. Liste déroulante Classe
                        DropdownButtonFormField<String>(
                          value: selectedClass,
                          decoration: InputDecoration(
                            labelText: 'Classe *',
                            prefixIcon: const Icon(Icons.school, color: primaryColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: classes.map((cl) {
                            final code = cl['codClass'] as String;
                            final nom = cl['nomClass'] as String? ?? code;
                            return DropdownMenuItem<String>(
                              value: code,
                              child: Text('$code ($nom)'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedClass = val;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // 3. Liste déroulante Matière
                        DropdownButtonFormField<String>(
                          value: selectedMat,
                          decoration: InputDecoration(
                            labelText: 'Matière *',
                            prefixIcon: const Icon(Icons.book, color: primaryColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: matieres.map((mat) {
                            final code = mat['codMat'] as String;
                            final nom = mat['intMat'] as String? ?? code;
                            return DropdownMenuItem<String>(
                              value: code,
                              child: Text('$code - $nom', overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedMat = val;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // 4. Champ Date avec Sélecteur
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: () => _pickDate(context),
                          decoration: InputDecoration(
                            labelText: 'Date de la séance *',
                            hintText: 'jj-mm-aaaa (ex: 18-11-2025)',
                            prefixIcon: const Icon(Icons.calendar_today, color: primaryColor),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.edit_calendar, color: primaryColor),
                              onPressed: () => _pickDate(context),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Boutons d'action : Afficher & Réinitialiser
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                onPressed: isSearching ? null : _submitSearch,
                                icon: isSearching
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.search, color: Colors.white),
                                label: Text(
                                  isSearching ? 'Chargement...' : 'Afficher les absences',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: OutlinedButton.icon(
                                onPressed: _resetForm,
                                icon: const Icon(Icons.refresh, color: Colors.blueGrey),
                                label: const Text('Réinitialiser', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: const BorderSide(color: Colors.blueGrey),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Message d'erreur éventuel
            if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            // Message aucun étudiant
            if (noStudentMessage != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        noStudentMessage!,
                        style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            // Zone des Résultats (Exercice 1)
            if (searchResult != null) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête des informations demandées
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor.withValues(alpha: 0.08), accentColor.withValues(alpha: 0.04)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _infoItem('Classe', searchResult!['codClass'] ?? '-'),
                                _infoItem('Département', searchResult!['nomDept'] ?? searchResult!['codDept'] ?? '-'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _infoItem('Matière', '${searchResult!['codMat']} - ${searchResult!['intMat']}'),
                                _infoItem('Date', searchResult!['dateA'] ?? '-'),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.indigo.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.schedule, color: Colors.indigo, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'CHSM : ${searchResult!['chsm']} heures',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tableau des Absences
                      const Text(
                        'Liste des étudiants et absences enregistrées',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 10),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2.5),
                              1: FlexColumnWidth(2.5),
                              2: FlexColumnWidth(1.5),
                            },
                            children: [
                              // En-tête de table conforme à l'examen
                              TableRow(
                                decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.12)),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                    child: Text(
                                      'Nom',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                    child: Text(
                                      'Prénom',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                    child: Text(
                                      'NHA',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                              // Lignes des étudiants
                              ...((searchResult!['etudiants'] as List? ?? []).map<TableRow>((e) {
                                final double nha = (e['nha'] as num? ?? 0).toDouble();
                                final hasAbsence = nha > 0;
                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: hasAbsence ? Colors.orange.shade50.withValues(alpha: 0.4) : Colors.white,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      child: Text(
                                        e['nom'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      child: Text(
                                        e['prenom'] ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: hasAbsence ? Colors.red.shade100 : Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            hasAbsence ? '${nha.toStringAsFixed(nha.truncateToDouble() == nha ? 0 : 1)} h' : '0',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: hasAbsence ? Colors.red.shade800 : Colors.green.shade800,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}
