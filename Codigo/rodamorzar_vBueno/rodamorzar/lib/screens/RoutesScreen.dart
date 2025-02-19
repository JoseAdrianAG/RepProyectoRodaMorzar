import 'package:flutter/material.dart';
import 'package:rodamorzar/services/RouteService.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  _RoutesScreenState createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  List<Map<String, dynamic>> _routes = [];
  bool _isLoading = true;
  String _filterType = 'todas'; // todas, predefinidas, personales

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() => _isLoading = true);
    try {
      final routes = await RouteService.getRoutes();
      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar las rutas: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get filteredRoutes {
    if (_filterType == 'todas') return _routes;
    return _routes.where((route) {
      if (_filterType == 'predefinidas') return route['es_predefinida'] == true;
      return route['es_predefinida'] == false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutas'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filterType = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'todas',
                child: Text('Todas las rutas'),
              ),
              PopupMenuItem(
                value: 'predefinidas',
                child: Text('Rutas predefinidas'),
              ),
              PopupMenuItem(
                value: 'personales',
                child: Text('Rutas personales'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRoutes,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filteredRoutes.length,
                itemBuilder: (context, index) {
                  final route = filteredRoutes[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        route['es_predefinida'] ? Icons.verified : Icons.route,
                        color:
                            route['es_predefinida'] ? Colors.blue : Colors.grey,
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
                        icon: Icon(
                          route['es_favorita'] ? Icons.star : Icons.star_border,
                        ),
                        onPressed: () async {
                          try {
                            await RouteService.toggleFavorite(
                              route['id'],
                              !route['es_favorita'],
                            );
                            _loadRoutes(); // Recargar para actualizar el estado
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Error al actualizar favorito: $e'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      onTap: () {
                        // TODO: Navegar a la vista detallada de la ruta
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: Navegar a la pantalla de crear ruta
        },
      ),
    );
  }
}
