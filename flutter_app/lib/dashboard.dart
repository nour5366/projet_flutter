import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user.dart';
import 'student_management.dart';
import 'absence_management.dart';
import 'absence_stats.dart';
import 'moyenne_management.dart';
import 'login.dart';
import 'exercice1_absences.dart';
import 'exercice2_max_classe.dart';

class Dashboard extends StatelessWidget {
  final User? currentUser;

  const Dashboard({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3C4FB), // Fond rose mauve conforme au screenshot Page 5
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        title: const Text('ISET Nabeul', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF9C27B0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ISET NABEUL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9C27B0),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bienvenue sur le Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.deepOrange),
              title: const Text('Manage groups'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gestion des groupes')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.orange),
              title: const Text('Manage students'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentManagement()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.purple),
              title: const Text('Gestion des absences'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AbsenceManagement()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.teal),
              title: const Text('Statistiques des absences'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AbsenceStats()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate, color: Colors.indigo),
              title: const Text('Notes & moyennes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MoyenneManagement()));
              },
            ),
            const Divider(),
            // EXAMEN TP DSI32
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: const Text(
                'EXAMEN TP DSI32',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A1B9A),
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event_note, color: Color(0xFF6A1B9A)),
              title: const Text(
                ' Consultation Absences',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('classe, matière et date'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Exercice1AbsencesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium, color: Colors.amber),
              title: const Text(
                ' Classe Max Étudiants',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Calcul réel + MàJ NbrEtud'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Exercice2MaxClasseScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Dashboard",
              style: GoogleFonts.caveat(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (currentUser != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Connecté en tant que : ${currentUser!.email}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF6A1B9A)),
                ),
              ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.event_note),
                  label: const Text('Consultation Absences'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Exercice1AbsencesScreen()),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text('Classe Max Étudiants'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E24AA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Exercice2MaxClasseScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.table_chart, color: Color(0xFF6A1B9A)),
              label: const Text('Gestion des absences classique', style: TextStyle(color: Color(0xFF6A1B9A))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6A1B9A)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AbsenceManagement()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
