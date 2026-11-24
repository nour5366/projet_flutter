package org.isetn.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "note_etudiant", uniqueConstraints = @UniqueConstraint(columnNames = {"nce", "cod_mat"}))
public class Note {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    @ManyToOne @JoinColumn(name = "nce", nullable = false)
    private Etudiant etudiant;
    @ManyToOne @JoinColumn(name = "cod_mat", nullable = false)
    private Matiere matiere;
    @Column(name = "type_module", nullable = false, length = 10)
    private String typeModule;
    private Double tp1;
    private Double tp2;
    private Double ds;
    private Double exam;
}
