package com.example.BDRodaMorzar.Services;

import java.util.List;
import com.example.BDRodaMorzar.DTO.UsuariosDTO;

public interface UsuariosService {
	
	List<UsuariosDTO> listAllUsuarios();
	
	Long saveUsuario(UsuariosDTO usuarioDTO);
	
    UsuariosDTO getUsuarioById(Long id);
    
    boolean deleteUsuario(Long id);
    
    UsuariosDTO updateUsuario(UsuariosDTO usuarioDTO);

}
