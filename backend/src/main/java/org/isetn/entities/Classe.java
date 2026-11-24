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
@Table(name = "classe")
public class Classe {

    @Id
    @Column(name = "cod_class", length = 20)
    private String codClass;

    @Column(name = "nom_class", length = 150, nullable = false)
    private String nomClass;

    @Column(name = "nbre_etud")
    private Integer nbrEtud;

    @ManyToOne
    @JoinColumn(name = "cod_dept")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Departement departement;
}
