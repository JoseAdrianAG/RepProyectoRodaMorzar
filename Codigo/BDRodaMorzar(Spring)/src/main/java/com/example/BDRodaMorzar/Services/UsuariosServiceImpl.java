package com.example.BDRodaMorzar.Services;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.example.BDRodaMorzar.DTO.UsuariosDTO;
import com.example.BDRodaMorzar.Models.Usuarios;
import com.example.BDRodaMorzar.Repository.UsuariosRepository;

@Service
public class UsuariosServiceImpl implements UsuariosService{

	@Autowired
	private UsuariosRepository usuarioRepository;
	@Override
	public List<UsuariosDTO> listAllUsuarios() {
		// TODO Auto-generated method stub

		List<UsuariosDTO> losUsuariosDTO=new ArrayList();
		
		List<Usuarios> losUsuarios=usuarioRepository.findAll();
		
		for (int i=0; i<losUsuarios.size(); ++i) {
			losUsuariosDTO.add(UsuariosDTO.convert2DTO(losUsuarios.get(i)));
		}
		return losUsuariosDTO;
	}

	@Override
	public Long saveUsuario(UsuariosDTO usuarioDTO) {
		// TODO Auto-generated method stub
		
		Usuarios elUsuario=new Usuarios();
		
		elUsuario=UsuariosDTO.convert2Entity(usuarioDTO);
		elUsuario=usuarioRepository.save(elUsuario);
		
		return elUsuario.getId();
	}

	@Override
	public UsuariosDTO getUsuarioById(Long id) {
		// TODO Auto-generated method stub
		
		Optional<Usuarios> usuarioOPT=usuarioRepository.findById(id);
		
		if(usuarioOPT.isPresent()) {
			UsuariosDTO usuarioDTO=UsuariosDTO.convert2DTO(usuarioOPT.get());
			return usuarioDTO;
		}
		
		return null;
	}

	@Override
	public boolean deleteUsuario(Long id) {
		// TODO Auto-generated method stub
		Optional<Usuarios> elUsuario=usuarioRepository.findById(id);
		
		if(elUsuario.isPresent()) {
			usuarioRepository.delete(elUsuario.get());
			return true;
		}
		return false;
	}

	@Override
	public UsuariosDTO updateUsuario(UsuariosDTO usuarioDTO) {
		// TODO Auto-generated method stub
		Optional<Usuarios> elUsuario=usuarioRepository.findById(usuarioDTO.getId());
		
		if(elUsuario.isPresent()) {
			
			Usuarios updUsuario=UsuariosDTO.convert2Entity(usuarioDTO);
			
			updUsuario=usuarioRepository.save(updUsuario);
			return UsuariosDTO.convert2DTO(updUsuario);
		}
		return null;
	}
	

}
