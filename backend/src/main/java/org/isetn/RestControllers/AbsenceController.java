package org.isetn.RestControllers;

import java.util.*;
import org.isetn.entities.Absence;
import org.isetn.entities.Etudiant;
import org.isetn.entities.Matiere;
import org.isetn.repository.AbsenceRepository;
import org.isetn.repository.EtudiantRepository;
import org.isetn.repository.MatiereRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/absences")
@CrossOrigin(origins = "*")
public class AbsenceController {

    @Autowired
    private AbsenceRepository absenceRepository;

    @Autowired
    private EtudiantRepository etudiantRepository;

    @Autowired
    private MatiereRepository matiereRepository;

    @GetMapping
    public List<Absence> getAllAbsences() {
        return absenceRepository.findAll();
    }

    @GetMapping("/by-etudiant/{nce}")
    public List<Absence> getAbsencesByEtudiant(@PathVariable String nce) {
        return absenceRepository.findByEtudiant_Nce(nce);
    }

    @PostMapping
    public ResponseEntity<?> createAbsence(@RequestBody Map<String, Object> payload) {
        try {
            String nce = (String) payload.get("nce");
            String codMat = (String) payload.get("codMat");
            String dateA = (String) payload.get("dateA");
            Double nha = Double.valueOf(payload.get("nha").toString());

            Optional<Etudiant> etudiantOpt = etudiantRepository.findById(nce);
            Optional<Matiere> matiereOpt = matiereRepository.findById(codMat);

            if (etudiantOpt.isEmpty() || matiereOpt.isEmpty()) {
                return ResponseEntity.badRequest().body("Etudiant ou Matière introuvable");
            }

            Absence absence = new Absence();
            absence.setEtudiant(etudiantOpt.get());
            absence.setMatiere(matiereOpt.get());
            absence.setDateA(dateA);
            absence.setNha(nha);

            Absence saved = absenceRepository.save(absence);
            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Erreur: " + e.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateAbsence(@PathVariable Integer id, @RequestBody Map<String, Object> payload) {
        return absenceRepository.findById(id).map(absence -> {
            if (payload.containsKey("dateA")) {
                absence.setDateA((String) payload.get("dateA"));
            }
            if (payload.containsKey("nha")) {
                absence.setNha(Double.valueOf(payload.get("nha").toString()));
            }
            if (payload.containsKey("codMat")) {
                matiereRepository.findById((String) payload.get("codMat")).ifPresent(absence::setMatiere);
            }
            Absence updated = absenceRepository.save(absence);
            return ResponseEntity.ok(updated);
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAbsence(@PathVariable Integer id) {
        if (!absenceRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        absenceRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Absence supprimée avec succès"));
    }

    // Suite TP7 Question 4: Total des absences d'un tel étudiant dans les différentes matières
    @GetMapping("/stats/{nce}")
    public ResponseEntity<List<Map<String, Object>>> getAbsenceStatsByStudent(@PathVariable String nce) {
        List<Object[]> rawStats = absenceRepository.findTotalAbsencesByEtudiant(nce);
        List<Map<String, Object>> response = new ArrayList<>();

        for (Object[] row : rawStats) {
            Map<String, Object> item = new HashMap<>();
            item.put("codMat", row[0]);
            item.put("totalNHA", row[1]);
            response.add(item);
        }
        return ResponseEntity.ok(response);
    }
}
