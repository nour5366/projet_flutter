package org.isetn.repository;

import java.util.List;
import org.isetn.entities.Absence;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface AbsenceRepository extends JpaRepository<Absence, Integer> {

    List<Absence> findByEtudiant_Nce(String nce);

    List<Absence> findByEtudiant_NceAndMatiere_CodMat(String nce, String codMat);

    // Requête pour calculer le total des heures d'absence par matière pour un étudiant (Suite TP7 p.2)
    @Query("SELECT a.matiere.codMat AS codMat, SUM(a.nha) AS totalNHA " +
           "FROM Absence a WHERE a.etudiant.nce = :nce " +
           "GROUP BY a.matiere.codMat")
    List<Object[]> findTotalAbsencesByEtudiant(@Param("nce") String nce);

    /**
     * EXERCICE 1 : Consultation des absences d'une classe pour une matière et une date données.
     * Jointure complète sur Etudiant, Absence, Classe, Departement, Matiere et ClassMat.
     * Si un étudiant n'a pas d'absence, NHA = 0.
     */
    @Query(value = "SELECT e.nce AS nce, " +
                   "       e.nom AS nom, " +
                   "       e.prenom AS prenom, " +
                   "       COALESCE(SUM(a.nha), 0.0) AS nha, " +
                   "       c.cod_class AS codClass, " +
                   "       c.nom_class AS nomClass, " +
                   "       d.cod_dept AS codDept, " +
                   "       d.nom_dept AS nomDept, " +
                   "       m.cod_mat AS codMat, " +
                   "       m.int_mat AS intMat, " +
                   "       COALESCE(cm.chsm, 45.0) AS chsm " +
                   "FROM etudiant e " +
                   "JOIN classe c ON e.cod_class = c.cod_class " +
                   "JOIN departement d ON c.cod_dept = d.cod_dept " +
                   "CROSS JOIN matiere m ON m.cod_mat = :codMat " +
                   "LEFT JOIN class_mat cm ON cm.cod_mat = m.cod_mat AND cm.cod_class = c.cod_class " +
                   "LEFT JOIN absence a ON a.nce = e.nce AND a.cod_mat = m.cod_mat AND (a.date_a = :dateA1 OR a.date_a = :dateA2) " +
                   "WHERE c.cod_class = :codClass " +
                   "GROUP BY e.nce, e.nom, e.prenom, c.cod_class, c.nom_class, d.cod_dept, d.nom_dept, m.cod_mat, m.int_mat, cm.chsm " +
                   "ORDER BY e.nom ASC, e.prenom ASC", nativeQuery = true)
    List<Object[]> findAbsencesPrevision(
        @Param("codClass") String codClass,
        @Param("codMat") String codMat,
        @Param("dateA1") String dateA1,
        @Param("dateA2") String dateA2
    );
}
