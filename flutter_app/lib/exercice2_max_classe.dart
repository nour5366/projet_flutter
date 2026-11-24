import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class Exercice2MaxClasseScreen extends StatefulWidget {
  const Exercice2MaxClasseScreen({super.key});

  @override
  State<Exercice2MaxClasseScreen> createState() => _Exercice2MaxClasseScreenState();
}

class _Exercice2MaxClasseScreenState extends State<Exercice2MaxClasseScreen> {
  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;
  String? successMessage;

  Map<String, dynamic>? classeMax;
  List<Map<String, dynamic>> allClasses = [];

  String get baseUrl => ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _loadMaxClassData();
  }

  Future<void> _loadMaxClassData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final res = await http.get(Uri.parse('$baseUrl/api/examen/classe-max-etudiants'));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          classeMax = data['classeMax'] as Map<String, dynamic>?;
          if (data['classes'] != null) {
            allClasses = List<Map<String, dynamic>>.from(data['classes']);
          }
        });
      } else {
        setState(() {
          errorMessage = 'Impossible de récupérer la classe maximale (code ${res.statusCode}).';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion au serveur ($baseUrl). Vérifiez que le backend Spring Boot est démarré.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateNbrEtud() async {
    setState(() {
      isUpdating = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final res = await http.post(Uri.parse('$baseUrl/api/examen/classe-max-etudiants/update-nbretud'));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        setState(() {
          successMessage = data['message'] ?? 'Mise à jour effectuée avec succès.';
        });
        // Rafraîchir les données pour afficher les nouvelles valeurs
        await _loadMaxClassData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(child: Text('NbrEtud mis à jour avec succès en base de données !')),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        final data = jsonDecode(res.body);
        setState(() {
          errorMessage = data['error'] ?? 'Échec de la mise à jour.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors de la mise à jour : $e';
      });
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6A1B9A);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exercice 2 : Classe avec le plus d\'étudiants',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: isLoading ? null : _loadMaxClassData,
          )
        ],
      ),
      backgroundColor: const Color(0xFFF5F5FA),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text('Calcul réel depuis la table Etudiant...', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avertissement / Note méthodologique du sujet
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.verified, color: Colors.amber, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Exigence d\'examen : Le calcul est basé exclusivement sur le comptage réel des lignes dans la table Etudiant (COUNT et GROUP BY). L\'ancienne colonne NbrEtud n\'est jamais utilisée pour déterminer la classe gagnante.',
                            style: TextStyle(fontSize: 13, color: Colors.brown, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message de succès
                  if (successMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade400),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              successMessage!,
                              style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Message d'erreur
                  if (errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
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

                  // Carte Héroïque : Classe Gagnante (Max Étudiants)
                  if (classeMax != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                                      SizedBox(width: 6),
                                      Text(
                                        'CLASSE MAXIMALE (REEL)',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${classeMax!['nbrReelEtud']} étudiants réels',
                                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Détails de la classe gagnante demandés par le sujet
                            _heroDetailRow(Icons.vpn_key, 'Code de la classe', classeMax!['codClass'] ?? '-'),
                            const SizedBox(height: 10),
                            _heroDetailRow(Icons.class_, 'Nom de la classe', classeMax!['nomClass'] ?? '-'),
                            const SizedBox(height: 10),
                            _heroDetailRow(Icons.business, 'Département', '${classeMax!['codDept']} - ${classeMax!['nomDept']}'),
                            const SizedBox(height: 10),
                            _heroDetailRow(
                              Icons.people,
                              'Nombre réel d\'étudiants (table Etudiant)',
                              '${classeMax!['nbrReelEtud']} étudiant(s)',
                            ),
                            const SizedBox(height: 10),
                            _heroDetailRow(
                              Icons.storage,
                              'Valeur actuelle dans Classe.NbrEtud',
                              '${classeMax!['nbrEtudActuel']} (en base)',
                            ),

                            const Divider(color: Colors.white30, height: 28),

                            // Bouton « Mettre à jour NbrEtud »
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isUpdating ? null : _updateNbrEtud,
                                icon: isUpdating
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(color: Colors.purple, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.sync, color: Color(0xFF6A1B9A)),
                                label: Text(
                                  isUpdating ? 'Mise à jour en cours...' : 'Mettre à jour NbrEtud',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6A1B9A),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Tableau comparatif de toutes les classes
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.table_chart, color: primaryColor),
                              SizedBox(width: 8),
                              Text(
                                'Toutes les classes (Comptage réel vs NbrEtud)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Table(
                              border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                              columnWidths: const {
                                0: FlexColumnWidth(1.8),
                                1: FlexColumnWidth(2.2),
                                2: FlexColumnWidth(1.8),
                                3: FlexColumnWidth(1.8),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.12)),
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                      child: Text('Code Classe', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                      child: Text('Nom Classe', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                      child: Text('Nb Réel', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                      child: Text('NbrEtud', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                                    ),
                                  ],
                                ),
                                ...allClasses.map((cl) {
                                  final isMax = classeMax != null && cl['codClass'] == classeMax!['codClass'];
                                  return TableRow(
                                    decoration: BoxDecoration(
                                      color: isMax ? Colors.purple.shade50 : Colors.white,
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                        child: Row(
                                          children: [
                                            if (isMax) const Icon(Icons.star, color: Colors.amber, size: 16),
                                            Text(
                                              cl['codClass'] ?? '',
                                              style: TextStyle(fontWeight: isMax ? FontWeight.bold : FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                        child: Text(cl['nomClass'] ?? ''),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isMax ? Colors.purple.shade100 : Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '${cl['nbrReelEtud']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isMax ? Colors.purple.shade900 : Colors.blue.shade900,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                        child: Center(
                                          child: Text(
                                            '${cl['nbrEtudActuel']}',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontWeight: isMax ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _heroDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label : ',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
