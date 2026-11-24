# TP7 & Suite TP7 : Gestion Scolarité, Absences et Statistiques
**ISET Nabeul - DSI33 & DSI31 (Workshop Framework Cross-Platform)**

Ce dépôt contient la solution complète et clé en main pour :
1. **TP7 - Persistance des données et communication avec base de données**
2. **Suite TP7 - Gestion des absences (Départements, Classes, Étudiants, Absences, Statistiques et Courbes)**

---

## Architecture du Projet

```
TP7_Projet_Complet/
├── backend/                     # Backend Spring Boot (JDK 22, Maven, JPA, REST)
│   ├── pom.xml                  # Configuré pour Java 22 & Spring Boot 3.3.5
│   └── src/main/
│       ├── java/org/isetn/
│       │   ├── ScolA7Application.java
│       │   ├── config/CorsConfig.java
│       │   ├── entities/        # User, Departement, Classe, Etudiant, Matiere, Absence, Formation
│       │   ├── repository/      # UserRepository, DepartementRepository, ClasseRepository, etc.
│       │   ├── RestControllers/ # UserController (/login, /register), AbsenceController, ScolRestController
│       │   └── projection/      # ClassProjection, EtudiantProjection
│       └── resources/
│           └── application.properties # Connexion MySQL XAMPP (localhost:3306)
├── flutter_app/                 # Application Mobile Flutter 3.x
│   ├── pubspec.yaml             # Dépendances (http, google_fonts, fl_chart)
│   └── lib/
│       ├── main.dart
│       ├── user.dart
│       ├── login.dart           # Écran de Login avec design du TP (carte verte, bouton rouge)
│       ├── register.dart        # Écran d'enregistrement avec redirection
│       ├── dashboard.dart       # Dashboard avec Drawer (ISET Nabeul, DSI33/DSI31)
│       ├── student_management.dart # Gestion des étudiants avec DropDownButton des classes
│       ├── absence_management.dart # Suite TP7: 3 listes déroulantes en cascade + CRUD absences
│       └── absence_stats.dart   # Suite TP7: Tableau récapitulatif & Courbe graphique des absences
├── database/
│   └── scol_db.sql              # Script SQL d'importation directe dans XAMPP phpMyAdmin
└── GUIDE_INSTALLATION_XAMPP_JDK22.md
```

---

## Prérequis
- **JDK 22** installé et configuré (`java -version` doit afficher version 22).
- **XAMPP** (Apache & MySQL démarrés).
- **Flutter SDK** (version 3.x ou supérieure).
- **IntelliJ IDEA**, **VS Code** ou **Android Studio**.

Consultez le fichier `GUIDE_INSTALLATION_XAMPP_JDK22.md` pour le pas-à-pas détaillé d'exécution.
