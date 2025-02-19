import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:rodamorzar/screens/HomeScreen.dart';
import 'package:rodamorzar/screens/RegisterScreen.dart';
import 'package:rodamorzar/services/AuthService.dart'; // Importar el nuevo servicio

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    const String url = 'https://10.0.2.2:3000/auth/login';

    final loginData = {
      'username': _usernameController.text.trim(),
      'password': _passwordController.text.trim(),
    };

    try {
      final response = await _makePostRequest(url, loginData);
      if (response == null) {
        throw Exception('No se pudo conectar con el servidor.');
      }

      final data = jsonDecode(response);
      if (data.containsKey('token')) {
        String token = data['token'];
        // Guardar los datos de autenticación usando el AuthService
        await AuthService.saveAuthData(token, _usernameController.text.trim());
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      } else {
        throw Exception(data['error'] ?? 'Error de autenticación');
      }
    } catch (e) {
      print('Error en login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }

    setState(() => _isLoading = false);
  }

  Future<String?> _makePostRequest(
      String url, Map<String, dynamic> body) async {
    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final request = await client.postUrl(Uri.parse(url));
      request.headers.set('content-type', 'application/json');
      request.write(jsonEncode(body));

      final response = await request.close();
      if (response.statusCode == 200) {
        return await response.transform(utf8.decoder).join();
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              Spacer(),
              _buildLoginForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: Text(
        'RODAMORZAR',
        style: TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Usuari', controller: _usernameController),
        SizedBox(height: 20),
        _buildTextField('Contrasenya',
            controller: _passwordController, obscureText: true),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          child:
              _isLoading ? CircularProgressIndicator() : Text('Iniciar Sesion'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Torna al mode proba',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () {
            // Acción para el enlace de registro
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          },
          child: Text(
            'Registrat açí.',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String labelText,
      {TextEditingController? controller, bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      obscureText: obscureText,
    );
  }
}
