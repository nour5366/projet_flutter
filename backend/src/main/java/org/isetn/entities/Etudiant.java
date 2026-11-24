package org.isetn.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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
@Table(name = "etudiant")
public class Etudiant {

    @Id
    @Column(length = 20)
    private String nce;

    @Column(nullable = false, length = 100)
    private String nom;

    @Column(nullable = false, length = 100)
    private String prenom;

    @Column(name = "date_nais", length = 20)
    private String dateNais;

    @Column(name = "lieu_nais", length = 100)
    private String lieuNais;

    @ManyToOne
    @JoinColumn(name = "cod_class")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler", "etudiants", "absences"})
    private Classe classe;
}
