package com.example.BDRodaMorzar.Repository;

import javax.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.example.BDRodaMorzar.Models.Usuarios;

@Repository
@Transactional
public interface UsuariosRepository extends JpaRepository<Usuarios, Long>{

}
