import 'package:flutter/material.dart';
import 'package:rodamorzar/services/FavoritesService.dart';
import 'package:rodamorzar/services/RouteService.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _favoriteRoutes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteRoutes();
  }

  Future<void> _loadFavoriteRoutes() async {
    try {
      final routes = await FavoritesService.getFavoriteRoutes();
      setState(() {
        _favoriteRoutes = routes;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar las rutas favoritas: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromFavorites(Map<String, dynamic> route) async {
    try {
      await RouteService.toggleFavorite(route['id'], false);
      _loadFavoriteRoutes(); // Recargar la lista
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al quitar de favoritos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorits'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteRoutes.isEmpty
              ? const Center(
                  child: Text('No tens cap ruta en favorits'),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavoriteRoutes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _favoriteRoutes.length,
                    itemBuilder: (context, index) {
                      final route = _favoriteRoutes[index];
                      bool isPredefined = route['es_predefinida'] == 1 ||
                          route['es_predefinida'] == true;

                      return Card(
                        child: ListTile(
                          leading: Icon(
                            isPredefined ? Icons.verified : Icons.route,
                            color: isPredefined ? Colors.blue : Colors.grey,
                          ),
                          title: Text(route['nombre']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(route['descripcion'] ?? ''),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.straighten, size: 16),
                                  Text(' ${route['distancia']}km'),
                                  SizedBox(width: 16),
                                  Icon(Icons.timer, size: 16),
                                  Text(' ${route['tiempo_estimado']}min'),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.star, color: Colors.amber),
                            onPressed: () => _removeFromFavorites(route),
                          ),
                          onTap: () {
                            // TODO: Navegar a la vista detallada de la ruta
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
