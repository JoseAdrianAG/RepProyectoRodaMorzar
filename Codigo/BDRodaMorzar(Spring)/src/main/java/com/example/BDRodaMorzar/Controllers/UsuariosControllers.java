package com.example.BDRodaMorzar.Controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;

import com.example.BDRodaMorzar.Services.UsuariosService;

@RestController
public class UsuariosControllers {
	
	@Autowired
	private UsuariosService usuarioService;

}
