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
@Table(name = "departement")
public class Departement {

    @Id
    @Column(name = "cod_dept", length = 20)
    private String codDept;

    @Column(name = "nom_dept", length = 150, nullable = false)
    private String nomDept;
}
