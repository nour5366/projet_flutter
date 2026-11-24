package org.isetn.repository;

import java.util.List;
import java.util.Optional;
import org.isetn.entities.Note;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NoteRepository extends JpaRepository<Note, Integer> {
    List<Note> findByEtudiant_Nce(String nce);
    Optional<Note> findByEtudiant_NceAndMatiere_CodMat(String nce, String codMat);
}
