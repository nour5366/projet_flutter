package org.isetn.entities;

import java.io.Serializable;
import java.util.Objects;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ClassMatId implements Serializable {
    private String codMat;
    private String codClass;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ClassMatId that = (ClassMatId) o;
        return Objects.equals(codMat, that.codMat) && Objects.equals(codClass, that.codClass);
    }

    @Override
    public int hashCode() {
        return Objects.hash(codMat, codClass);
    }
}
