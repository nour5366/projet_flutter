package org.isetn.projection;

import org.isetn.entities.Etudiant;
import org.springframework.data.rest.core.config.Projection;

@Projection(name = "etudiantProjection", types = { Etudiant.class })
public interface EtudiantProjection {
    String getNce();
    String getNom();
    String getPrenom();
    String getDateNais();
    String getLieuNais();
}
