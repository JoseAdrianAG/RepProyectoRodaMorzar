package com.example.BDRodaMorzar.DTO;

import java.io.Serializable;
import javax.persistence.Column;
import com.example.BDRodaMorzar.Models.Usuarios;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class UsuariosDTO implements Serializable{
	
	private static final long serialVersionUID = 17L;
	
	private Long id;
	
	private String nombre;
	
	@JsonIgnore
	private String password;
	
	public static UsuariosDTO convert2DTO(Usuarios usuario) {
		UsuariosDTO usuarioDTO=new UsuariosDTO();
		
		usuarioDTO.setId(usuario.getId());
		usuarioDTO.setNombre(usuario.getNombre());
		usuarioDTO.setPassword(usuario.getPassword());
		
		return usuarioDTO;	
	}
	
	public static Usuarios convert2Entity(UsuariosDTO usuarioDTO) {
		Usuarios usuario=new Usuarios();
		
		if(usuarioDTO.getId()!=null)
			usuario.setId(usuarioDTO.getId());
		
		usuario.setNombre(usuarioDTO.getNombre());
		usuario.setPassword(usuarioDTO.getPassword());
		
		return usuario;
		
	}

}
