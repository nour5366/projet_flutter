package org.isetn.projection;

import org.isetn.entities.Classe;
import org.springframework.data.rest.core.config.Projection;

@Projection(name = "classProjection", types = { Classe.class })
public interface ClassProjection {
    String getCodClass();
    String getNomClass();
    Integer getNbrEtud();
}
