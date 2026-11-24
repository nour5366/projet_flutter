package org.isetn.RestControllers;

import java.util.List;
import java.util.Optional;
import org.isetn.entities.Classe;
import org.isetn.entities.Departement;
import org.isetn.entities.Etudiant;
import org.isetn.entities.Matiere;
import org.isetn.repository.ClasseRepository;
import org.isetn.repository.DepartementRepository;
import org.isetn.repository.EtudiantRepository;
import org.isetn.repository.MatiereRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ScolRestController {

    @Autowired
    private DepartementRepository departementRepository;

    @Autowired
    private ClasseRepository classeRepository;

    @Autowired
    private EtudiantRepository etudiantRepository;

    @Autowired
    private MatiereRepository matiereRepository;

    // --- Départements ---
    @GetMapping("/departements")
    public List<Departement> getDepartements() {
        return departementRepository.findAll();
    }

    // --- Classes (toutes ou filtrées par département) ---
    @GetMapping("/classes")
    public List<Classe> getClasses(@RequestParam(required = false) String codDept) {
        if (codDept != null && !codDept.isEmpty()) {
            return classeRepository.findByDepartement_CodDept(codDept);
        }
        return classeRepository.findAll();
    }

    // --- Étudiants (tous ou filtrés par classe) ---
    @GetMapping("/etudiants")
    public List<Etudiant> getEtudiants(@RequestParam(required = false) String codClass) {
        if (codClass != null && !codClass.isEmpty()) {
            return etudiantRepository.findByClasse_CodClass(codClass);
        }
        return etudiantRepository.findAll();
    }

    @GetMapping("/etudiants/{nce}")
    public ResponseEntity<Etudiant> getEtudiant(@PathVariable String nce) {
        return etudiantRepository.findById(nce)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/etudiants")
    public ResponseEntity<?> createEtudiant(@RequestBody Etudiant etudiant) {
        if (etudiantRepository.existsById(etudiant.getNce())) {
            return ResponseEntity.badRequest().body("NCE déjà utilisé : " + etudiant.getNce());
        }
        // Résoudre la classe si fournie
        if (etudiant.getClasse() != null && etudiant.getClasse().getCodClass() != null) {
            Optional<Classe> classeOpt = classeRepository.findById(etudiant.getClasse().getCodClass());
            classeOpt.ifPresent(etudiant::setClasse);
        }
        return ResponseEntity.ok(etudiantRepository.save(etudiant));
    }

    @PutMapping("/etudiants/{nce}")
    public ResponseEntity<?> updateEtudiant(@PathVariable String nce, @RequestBody Etudiant updated) {
        return etudiantRepository.findById(nce).map(etudiant -> {
            if (updated.getNom() != null) etudiant.setNom(updated.getNom());
            if (updated.getPrenom() != null) etudiant.setPrenom(updated.getPrenom());
            if (updated.getDateNais() != null) etudiant.setDateNais(updated.getDateNais());
            if (updated.getLieuNais() != null) etudiant.setLieuNais(updated.getLieuNais());
            if (updated.getClasse() != null && updated.getClasse().getCodClass() != null) {
                classeRepository.findById(updated.getClasse().getCodClass()).ifPresent(etudiant::setClasse);
            }
            return ResponseEntity.ok(etudiantRepository.save(etudiant));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/etudiants/{nce}")
    public ResponseEntity<?> deleteEtudiant(@PathVariable String nce) {
        if (!etudiantRepository.existsById(nce)) {
            return ResponseEntity.notFound().build();
        }
        etudiantRepository.deleteById(nce);
        return ResponseEntity.ok("Étudiant supprimé avec succès.");
    }

    // --- Matières ---
    @GetMapping("/matieres")
    public List<Matiere> getMatieres() {
        return matiereRepository.findAll();
    }

    @GetMapping("/matieres/{codMat}")
    public ResponseEntity<Matiere> getMatiere(@PathVariable String codMat) {
        return matiereRepository.findById(codMat)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
