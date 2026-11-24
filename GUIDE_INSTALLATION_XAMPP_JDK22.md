# Guide d'Installation et d'Exécution Pas-à-Pas
## TP7 & Suite TP7 (Spring Boot JDK 22 + MySQL XAMPP + Flutter)

### Étape 1 : Préparation de la base de données avec XAMPP
1. Ouvrez le **Panneau de Contrôle XAMPP** (XAMPP Control Panel).
2. Démarrez les modules **Apache** et **MySQL** (boutons "Start").
3. Cliquez sur le bouton **Admin** en face de MySQL (ou ouvrez votre navigateur à l'adresse `http://localhost/phpmyadmin`).
4. Dans phpMyAdmin :
   - Cliquez sur l'onglet **Importer**.
   - Cliquez sur **Choisir un fichier** et sélectionnez `database/scol_db.sql`.
   - Cliquez sur le bouton **Exécuter** tout en bas.
5. La base `scol_db` sera créée avec toutes ses tables (`user`, `departement`, `classe`, `etudiant`, `matiere`, `absence`) et les données de test !

---

### Étape 2 : Configuration et Lancement du Backend Spring Boot (JDK 22)
1. Vérifiez que votre JDK 22 est bien configuré :
   ```bash
   java -version
   ```
   *(Doit afficher Java version "22" ou similaire).*

2. Ouvrez le dossier `backend/` dans **IntelliJ IDEA** (ou **VS Code**) en tant que projet Maven.
3. Vérifiez les paramètres du projet (Project Structure -> Project SDK) : choisir **JDK 22**.
4. Dans le fichier `src/main/resources/application.properties`, assurez-vous que les identifiants MySQL correspondent à XAMPP :
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/scol_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
   spring.datasource.username=root
   spring.datasource.password=
   server.port=8081
   ```
5. Lancez l'application :
   - Via IntelliJ : clic droit sur `ScolA7Application.java` -> **Run**.
   - Ou en ligne de commande :
     ```bash
     cd backend
     ./mvnw spring-boot:run
     ```
6. Le backend écoute sur `http://localhost:8081`.
   - Vous pouvez tester `http://localhost:8081/users` dans votre navigateur.

---

### Étape 3 : Lancement de l'Application Mobile Flutter
1. Ouvrez le dossier `flutter_app/` dans votre éditeur (VS Code ou Android Studio).
2. Téléchargez les dépendances :
   ```bash
   cd flutter_app
   flutter pub get
   ```
3. Configuration de l'IP selon votre mode d'exécution :
   - **Sur Émulateur Android officiel** : l'URL `http://10.0.2.2:8081` configurée par défaut pointe automatiquement vers votre machine hôte.
   - **Sur Appareil physique** : modifiez l'URL dans `login.dart` et `register.dart` avec l'adresse IP locale de votre PC (obtenue avec la commande `ipconfig` sur Windows, ex: `http://192.168.1.15:8081`).
   - **Sur Navigateur Web (Chrome)** : utilisez `http://localhost:8081`.
4. Lancez l'application :
   ```bash
   flutter run
   ```

---

### Étape 4 : Utilisation & Validation des Cas de Test du TP
1. **Login & Register** :
   - Email : `admin@gmail.com` | Mot de passe : `admin`
   - Ou : `foulen@gmail.com` | Mot de passe : `foulen`
   - Vous pouvez également créer un nouvel utilisateur via l'écran Register.
2. **Dashboard** :
   - Ouvrez le menu Drawer en haut à gauche (ISET Nabeul - DSI33 et DSI31).
3. **Student Management** (Page 12 du TP7) :
   - Sélectionner une classe dans la liste déroulante (ex: DSI33).
4. **Suite TP7 : Gestion des absences** :
   - Sélectionner le Département **TI**, la classe **DSI33**, l'étudiant **E1 (Ben Foulen1 Foulen1)**.
   - Constater le tableau avec les absences (AFCP: 1.5h, 4.5h ; SOA: 1.5h, 3h, 3h).
   - Cliquer sur le bouton **+** pour ajouter une absence.
   - Modifier ou supprimer une absence.
5. **Suite TP7 : Statistiques & Courbe** :
   - Cliquer sur l'icône de diagramme en haut à droite.
   - Observer le tableau récapitulatif (AFCP : 6h, SOA : 7.5h) et la courbe / histogramme dynamique !
