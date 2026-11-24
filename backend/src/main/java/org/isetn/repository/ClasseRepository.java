package org.isetn.repository;

import java.util.List;
import org.isetn.entities.Classe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface ClasseRepository extends JpaRepository<Classe, String> {
    List<Classe> findByDepartement_CodDept(String codDept);

    /**
     * EXERCICE 2 : Compter le nombre réel d'étudiants par classe depuis la table Etudiant
     * avec COUNT et GROUP BY et jointures, sans jamais se baser sur nbre_etud.
     */
    @Query(value = "SELECT c.cod_class AS codClass, " +
                   "       c.nom_class AS nomClass, " +
                   "       COALESCE(d.cod_dept, '') AS codDept, " +
                   "       COALESCE(d.nom_dept, '') AS nomDept, " +
                   "       COALESCE(c.nbre_etud, 0) AS nbrEtudActuel, " +
                   "       COUNT(e.nce) AS nbrReelEtud " +
                   "FROM classe c " +
                   "LEFT JOIN departement d ON c.cod_dept = d.cod_dept " +
                   "LEFT JOIN etudiant e ON c.cod_class = e.cod_class " +
                   "GROUP BY c.cod_class, c.nom_class, d.cod_dept, d.nom_dept, c.nbre_etud " +
                   "ORDER BY nbrReelEtud DESC", nativeQuery = true)
    List<Object[]> findClassesWithRealStudentCount();

    /**
     * Mettre à jour la colonne nbre_etud de la classe gagnante avec son effectif réel calculé.
     */
    @Modifying
    @Transactional
    @Query(value = "UPDATE classe SET nbre_etud = :nbrReel WHERE cod_class = :codClass", nativeQuery = true)
    int updateNbrEtudForClass(@Param("codClass") String codClass, @Param("nbrReel") int nbrReel);
}
