// lib/services/RouteService.dart
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class RouteService {
  static const String baseUrl = 'https://10.0.2.2:3000';

  static Future<List<Map<String, dynamic>>> getRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('No hay token');

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final request = await client.getUrl(Uri.parse('$baseUrl/routes'));
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final List<dynamic> routes = json.decode(responseBody);
        return routes.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener las rutas');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> createRoute(
      Map<String, dynamic> routeData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('No hay token');

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final request = await client.postUrl(Uri.parse('$baseUrl/routes'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.write(json.encode(routeData));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Error al crear la ruta');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<void> toggleFavorite(int routeId, bool add) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('No hay token');

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final request =
          await client.postUrl(Uri.parse('$baseUrl/routes/$routeId/favorito'));
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');
      request.write(json.encode({'agregar': add}));

      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception('Error al actualizar favoritos');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
