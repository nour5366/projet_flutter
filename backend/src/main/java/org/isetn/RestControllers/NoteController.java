package org.isetn.RestControllers;

import java.util.*;
import org.isetn.entities.*;
import org.isetn.repository.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notes")
@CrossOrigin(origins = "*")
public class NoteController {
    private final NoteRepository noteRepository;
    private final EtudiantRepository etudiantRepository;
    private final MatiereRepository matiereRepository;

    public NoteController(NoteRepository noteRepository, EtudiantRepository etudiantRepository, MatiereRepository matiereRepository) {
        this.noteRepository = noteRepository; this.etudiantRepository = etudiantRepository; this.matiereRepository = matiereRepository;
    }

    @GetMapping("/etudiant/{nce}")
    public List<Map<String,Object>> getNotes(@PathVariable String nce) {
        return noteRepository.findByEtudiant_Nce(nce).stream().map(this::toMap).toList();
    }

    @PostMapping
    public ResponseEntity<?> saveNote(@RequestBody Map<String,Object> body) {
        String nce = Objects.toString(body.get("nce"), "");
        String codMat = Objects.toString(body.get("codMat"), "");
        String type = Objects.toString(body.get("typeModule"), "AUTRE").toUpperCase(Locale.ROOT);
        if (!type.equals("TP") && !type.equals("AUTRE")) return ResponseEntity.badRequest().body("typeModule doit être TP ou AUTRE");
        Optional<Etudiant> etudiant = etudiantRepository.findById(nce);
        Optional<Matiere> matiere = matiereRepository.findById(codMat);
        if (etudiant.isEmpty() || matiere.isEmpty()) return ResponseEntity.badRequest().body("Étudiant ou matière introuvable");
        try {
            Note note = noteRepository.findByEtudiant_NceAndMatiere_CodMat(nce, codMat).orElseGet(Note::new);
            note.setEtudiant(etudiant.get()); note.setMatiere(matiere.get()); note.setTypeModule(type);
            note.setTp1(number(body.get("tp1"))); note.setTp2(number(body.get("tp2")));
            note.setDs(number(body.get("ds"))); note.setExam(number(body.get("exam")));
            return ResponseEntity.ok(toMap(noteRepository.save(note)));
        } catch (IllegalArgumentException ex) { return ResponseEntity.badRequest().body(ex.getMessage()); }
    }

    private Double number(Object value) {
        if (value == null || value.toString().isBlank()) return null;
        double d = Double.parseDouble(value.toString().replace(',', '.'));
        if (d < 0 || d > 20) throw new IllegalArgumentException("Chaque note doit être comprise entre 0 et 20");
        return d;
    }
    private Map<String,Object> toMap(Note n) {
        Map<String,Object> m = new LinkedHashMap<>();
        m.put("id", n.getId()); m.put("nce", n.getEtudiant().getNce()); m.put("codMat", n.getMatiere().getCodMat());
        m.put("intMat", n.getMatiere().getIntMat()); m.put("typeModule", n.getTypeModule());
        m.put("tp1", n.getTp1()); m.put("tp2", n.getTp2()); m.put("ds", n.getDs()); m.put("exam", n.getExam());
        return m;
    }
}
