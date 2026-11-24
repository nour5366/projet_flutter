import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.0.2.2:8081/api';

/// Question 2 : classe avec le plus grand nombre d'étudiants
/// (comptés dans la table Etudiant) + bouton de mise à jour de NbrEtud.
class PlusGrandeClasse extends StatefulWidget {
  const PlusGrandeClasse({super.key});

  @override
  State<PlusGrandeClasse> createState() => _PlusGrandeClasseState();
}

class _PlusGrandeClasseState extends State<PlusGrandeClasse> {
  Map<String, dynamic>? classe;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() => loading = true);
    final r = await http.get(Uri.parse('$baseUrl/exam/classe-max'));
    setState(() {
      classe = jsonDecode(utf8.decode(r.bodyBytes));
      loading = false;
    });
  }

  Future<void> _mettreAJour() async {
    if (classe == null || classe!.isEmpty) return;
    final r = await http.put(
        Uri.parse('$baseUrl/exam/classe/${classe!['codClass']}/maj-nbretud'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(r.statusCode == 200
          ? 'NbrEtud mis à jour avec ${classe!['nb']}'
          : 'Erreur ${r.statusCode}'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classe avec le plus d\'étudiants')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : (classe == null || classe!.isEmpty)
                ? const Text('Aucune donnée')
                : Card(
                    margin: const EdgeInsets.all(24),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Classe : ${classe!['nomClass']} (${classe!['codClass']})',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text('Nombre d\'étudiants : ${classe!['nb']}',
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _mettreAJour,
                            icon: const Icon(Icons.sync),
                            label: const Text('Mettre à jour NbrEtud'),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}