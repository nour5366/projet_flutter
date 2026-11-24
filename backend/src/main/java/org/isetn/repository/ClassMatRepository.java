package org.isetn.repository;

import java.util.List;
import java.util.Optional;
import org.isetn.entities.ClassMat;
import org.isetn.entities.ClassMatId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClassMatRepository extends JpaRepository<ClassMat, ClassMatId> {
    List<ClassMat> findByCodClass(String codClass);
    List<ClassMat> findByCodMat(String codMat);
    Optional<ClassMat> findByCodMatAndCodClass(String codMat, String codClass);
}
