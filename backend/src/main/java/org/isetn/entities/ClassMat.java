package org.isetn.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "class_mat")
@IdClass(ClassMatId.class)
public class ClassMat {

    @Id
    @Column(name = "cod_mat", length = 20)
    private String codMat;

    @Id
    @Column(name = "cod_class", length = 20)
    private String codClass;

    @Column(nullable = false)
    private Double coef;

    @Column(nullable = false)
    private Double chsm; // Charge horaire semestrielle de la matière

    @ManyToOne
    @JoinColumn(name = "cod_mat", insertable = false, updatable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Matiere matiere;

    @ManyToOne
    @JoinColumn(name = "cod_class", insertable = false, updatable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Classe classe;
}
