// lib/services/FavoritesService.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'RouteService.dart';

class FavoritesService {
  static Future<List<Map<String, dynamic>>> getFavoriteRoutes() async {
    try {
      final routes = await RouteService.getRoutes();
      return routes
          .where((route) =>
              route['es_favorita'] == 1 || route['es_favorita'] == true)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener rutas favoritas: $e');
    }
  }
}
