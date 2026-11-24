package org.isetn.RestControllers;

import java.util.*;
import org.isetn.entities.Classe;
import org.isetn.entities.ClassMat;
import org.isetn.entities.Departement;
import org.isetn.entities.Matiere;
import org.isetn.repository.AbsenceRepository;
import org.isetn.repository.ClassMatRepository;
import org.isetn.repository.ClasseRepository;
import org.isetn.repository.DepartementRepository;
import org.isetn.repository.MatiereRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping({"/api/examen", "/api/exam"})
@CrossOrigin(origins = "*")
public class ExamenController {

    @Autowired
    private AbsenceRepository absenceRepository;

    @Autowired
    private ClasseRepository classeRepository;

    @Autowired
    private DepartementRepository departementRepository;

    @Autowired
    private MatiereRepository matiereRepository;

    @Autowired
    private ClassMatRepository classMatRepository;

    /**
     * EXERCICE 1 : Prévision / consultation des absences d'une classe pour une matière et une date.
     * Jointures sur Etudiant, Absence, Classe, Departement, Matiere, ClassMat.
     * Supporte à la fois :
     * - codClass, codMat, dateA
     * - classe, matiere, date
     */
    @GetMapping({"/absences-prevision", "/absences"})
    public ResponseEntity<?> getAbsencesPrevision(
            @RequestParam(required = false) String codClass,
            @RequestParam(required = false) String classe,
            @RequestParam(required = false) String codMat,
            @RequestParam(required = false) String matiere,
            @RequestParam(required = false) String dateA,
            @RequestParam(required = false) String date) {

        String targetClass = (codClass != null && !codClass.trim().isEmpty()) ? codClass : classe;
        String targetMat = (codMat != null && !codMat.trim().isEmpty()) ? codMat : matiere;
        String targetDate = (dateA != null && !dateA.trim().isEmpty()) ? dateA : date;

        // Validation des champs obligatoires
        if (targetClass == null || targetClass.trim().isEmpty() ||
            targetMat == null || targetMat.trim().isEmpty() ||
            targetDate == null || targetDate.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of(
                "error", "Champs obligatoires manquants : Classe, Matière et Date sont requis."
            ));
        }

        String trimmedDate = targetDate.trim();
        // Support flexible du format : DD-MM-YYYY vs YYYY-MM-DD
        String altDate = trimmedDate;
        if (trimmedDate.contains("-")) {
            String[] parts = trimmedDate.split("-");
            if (parts.length == 3) {
                if (parts[0].length() == 4) { // YYYY-MM-DD -> DD-MM-YYYY
                    altDate = parts[2] + "-" + parts[1] + "-" + parts[0];
                } else if (parts[2].length() == 4) { // DD-MM-YYYY -> YYYY-MM-DD
                    altDate = parts[2] + "-" + parts[1] + "-" + parts[0];
                }
            }
        }

        List<Object[]> rows = absenceRepository.findAbsencesPrevision(targetClass, targetMat, trimmedDate, altDate);

        Optional<Classe> classeOpt = classeRepository.findById(targetClass);
        Optional<Matiere> matiereOpt = matiereRepository.findById(targetMat);
        Optional<ClassMat> classMatOpt = classMatRepository.findByCodMatAndCodClass(targetMat, targetClass);

        String nomClass = classeOpt.map(Classe::getNomClass).orElse(targetClass);
        String codDept = "";
        String nomDept = "";
        if (classeOpt.isPresent() && classeOpt.get().getDepartement() != null) {
            Departement d = classeOpt.get().getDepartement();
            codDept = d.getCodDept();
            nomDept = d.getNomDept();
        } else {
            Departement d = departementRepository.findAll().stream().findFirst().orElse(null);
            if (d != null) {
                codDept = d.getCodDept();
                nomDept = d.getNomDept();
            }
        }

        String intMat = matiereOpt.map(Matiere::getIntMat).orElse(targetMat);
        Double chsm = classMatOpt.map(ClassMat::getChsm).orElse(45.0);

        List<Map<String, Object>> etudiantsList = new ArrayList<>();
        for (Object[] row : rows) {
            Map<String, Object> etud = new HashMap<>();
            etud.put("nce", row[0]);
            etud.put("nom", row[1]);
            etud.put("prenom", row[2]);
            Number nhaNum = (Number) row[3];
            etud.put("nha", nhaNum != null ? nhaNum.doubleValue() : 0.0);
            etudiantsList.add(etud);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("codClass", targetClass);
        response.put("nomClass", nomClass);
        response.put("codDept", codDept);
        response.put("nomDept", nomDept);
        response.put("codMat", targetMat);
        response.put("intMat", intMat);
        response.put("chsm", chsm);
        response.put("dateA", trimmedDate);
        response.put("totalEtudiants", etudiantsList.size());
        response.put("etudiants", etudiantsList);

        if (etudiantsList.isEmpty()) {
            response.put("message", "Aucun étudiant n'existe dans cette classe.");
        }

        return ResponseEntity.ok(response);
    }

    /**
     * EXERCICE 2 : Récupérer la classe ayant le plus grand nombre d'étudiants.
     * Règle stricte : Ne JAMAIS utiliser Classe.nbrEtud, mais compter réellement dans Etudiant via COUNT et GROUP BY.
     */
    @GetMapping({"/classe-max-etudiants", "/classe-max"})
    public ResponseEntity<?> getClasseMaxEtudiants() {
        List<Object[]> rawList = classeRepository.findClassesWithRealStudentCount();

        if (rawList == null || rawList.isEmpty()) {
            return ResponseEntity.ok(Map.of("message", "Aucune classe trouvée."));
        }

        List<Map<String, Object>> allClasses = new ArrayList<>();
        Map<String, Object> maxClass = null;

        for (int i = 0; i < rawList.size(); i++) {
            Object[] row = rawList.get(i);
            Map<String, Object> item = new HashMap<>();
            item.put("codClass", row[0]);
            item.put("nomClass", row[1]);
            item.put("codDept", row[2]);
            item.put("nomDept", row[3]);
            item.put("nbrEtudActuel", ((Number) row[4]).intValue());
            int nbrReel = ((Number) row[5]).intValue();
            item.put("nbrReelEtud", nbrReel);
            item.put("nb", nbrReel); // alias pour compatibilité

            allClasses.add(item);
            if (i == 0) {
                maxClass = item;
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("classeMax", maxClass);
        result.put("classes", allClasses);
        // Propriétés à la racine pour compatibilité directe avec les deux UIs
        if (maxClass != null) {
            result.put("codClass", maxClass.get("codClass"));
            result.put("nomClass", maxClass.get("nomClass"));
            result.put("codDept", maxClass.get("codDept"));
            result.put("nomDept", maxClass.get("nomDept"));
            result.put("nb", maxClass.get("nbrReelEtud"));
            result.put("nbrReelEtud", maxClass.get("nbrReelEtud"));
            result.put("nbrEtudActuel", maxClass.get("nbrEtudActuel"));
        }

        return ResponseEntity.ok(result);
    }

    /**
     * EXERCICE 2 : Bouton « Mettre à jour NbrEtud ».
     * Recalcule le nombre réel d'étudiants depuis Etudiant, identifie la classe ayant le max,
     * et met à jour uniquement la colonne NbrEtud de cette classe dans Classe.
     */
    @RequestMapping(value = {"/classe-max-etudiants/update-nbretud", "/classe/{codClass}/maj-nbretud"},
                    method = {RequestMethod.POST, RequestMethod.PUT})
    public ResponseEntity<?> updateNbrEtudForMaxClasse(@PathVariable(required = false) String codClass) {
        List<Object[]> rawList = classeRepository.findClassesWithRealStudentCount();

        if (rawList == null || rawList.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Aucune classe trouvée en base."));
        }

        // Classe gagnante calculée en temps réel depuis la table Etudiant
        Object[] maxRow = rawList.get(0);
        String codClassMax = (codClass != null && !codClass.trim().isEmpty()) ? codClass : (String) maxRow[0];
        String nomClassMax = (String) maxRow[1];
        String nomDept = (String) maxRow[3];
        int nbrReelEtud = ((Number) maxRow[5]).intValue();
        int ancienNbrEtud = ((Number) maxRow[4]).intValue();

        // Si une classe spécifique a été demandée via l'URL /classe/{codClass}/maj-nbretud, trouver son nbrReelEtud
        if (codClass != null && !codClass.trim().isEmpty()) {
            for (Object[] r : rawList) {
                if (codClass.equals(r[0])) {
                    nomClassMax = (String) r[1];
                    nomDept = (String) r[3];
                    ancienNbrEtud = ((Number) r[4]).intValue();
                    nbrReelEtud = ((Number) r[5]).intValue();
                    break;
                }
            }
        }

        // Mise à jour en base
        int rowsUpdated = classeRepository.updateNbrEtudForClass(codClassMax, nbrReelEtud);

        // Relecture depuis la base de données pour vérifier la persistance réelle
        Optional<Classe> recheck = classeRepository.findById(codClassMax);
        Integer updatedValue = recheck.map(Classe::getNbrEtud).orElse(null);

        boolean success = rowsUpdated > 0 && updatedValue != null && updatedValue == nbrReelEtud;

        Map<String, Object> response = new HashMap<>();
        response.put("success", success);
        response.put("codClass", codClassMax);
        response.put("nomClass", nomClassMax);
        response.put("nomDept", nomDept);
        response.put("nbrReelEtud", nbrReelEtud);
        response.put("ancienNbrEtud", ancienNbrEtud);
        response.put("nouveauNbrEtud", updatedValue);
        response.put("nb", nbrReelEtud);
        response.put("message", "Mise à jour réussie : La colonne NbrEtud de la classe '" + codClassMax +
                                "' a été mise à jour avec succès à " + nbrReelEtud + " (nombre réel calculé depuis la table Etudiant).");

        return ResponseEntity.ok(response);
    }
}
