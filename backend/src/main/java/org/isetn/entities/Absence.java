package org.isetn.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "absence")
public class Absence {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "date_a", nullable = false, length = 20)
    private String dateA;

    @Column(nullable = false)
    private Double nha; // Nombre d'heures d'absences

    @ManyToOne
    @JoinColumn(name = "cod_mat", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler", "absences"})
    private Matiere matiere;

    @ManyToOne
    @JoinColumn(name = "nce", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler", "absences", "classe"})
    private Etudiant etudiant;
}
