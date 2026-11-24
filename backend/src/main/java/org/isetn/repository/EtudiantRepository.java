package org.isetn.repository;

import java.util.List;
import org.isetn.entities.Etudiant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EtudiantRepository extends JpaRepository<Etudiant, String> {
    List<Etudiant> findByClasse_CodClass(String codClass);
}
