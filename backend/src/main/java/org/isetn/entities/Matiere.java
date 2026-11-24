package org.isetn.entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "matiere")
public class Matiere {

    @Id
    @Column(name = "cod_mat", length = 20)
    private String codMat;

    @Column(name = "int_mat", length = 150, nullable = false)
    private String intMat;

    @Column(columnDefinition = "TEXT")
    private String description;
}
