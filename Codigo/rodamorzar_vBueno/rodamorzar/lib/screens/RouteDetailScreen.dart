// lib/screens/RouteDetailScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rodamorzar/services/RouteService.dart';

class RouteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> route;

  const RouteDetailScreen({Key? key, required this.route}) : super(key: key);

  @override
  _RouteDetailScreenState createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  bool _isLoading = true;
  List<LatLng> _routePoints = [];
  List<Map<String, dynamic>> _nearbyBars = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadRouteDetails();
  }

  Future<void> _loadRouteDetails() async {
    try {
      final routeDetails =
          await RouteService.getRouteDetails(widget.route['id']);
      setState(() {
        _routePoints = routeDetails['points']
            .map<LatLng>((point) => LatLng(point['latitud'], point['longitud']))
            .toList();

        _nearbyBars = routeDetails['bars'];
        _isLoading = false;

        if (_routePoints.isNotEmpty) {
          // Usar fitCamera en lugar de fitBounds
          final bounds = LatLngBounds.fromPoints(_routePoints);
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(50.0),
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al cargar los detalles de la ruta: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.route['nombre']),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _routePoints.isNotEmpty
                          ? _routePoints[0]
                          : const LatLng(0, 0),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          // Marcador para el inicio de la ruta
                          if (_routePoints.isNotEmpty)
                            Marker(
                              point: _routePoints.first,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.play_circle,
                                color: Colors.green,
                                size: 40,
                              ),
                            ),
                          // Marcador para el final de la ruta
                          if (_routePoints.isNotEmpty)
                            Marker(
                              point: _routePoints.last,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.stop_circle,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          // Marcadores para los bares
                          ..._nearbyBars.map(
                            (bar) => Marker(
                              point: LatLng(bar['latitud'], bar['longitud']),
                              width: 40,
                              height: 40,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.local_bar,
                                  color: Colors.brown,
                                ),
                                onPressed: () {
                                  _showBarDetails(context, bar);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Descripción: ${widget.route['descripcion']}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.straighten, size: 20),
                          Text(' ${widget.route['distancia']}km'),
                          const SizedBox(width: 16),
                          Icon(Icons.timer, size: 20),
                          Text(' ${widget.route['tiempo_estimado']}min'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bares cercanos: ${_nearbyBars.length}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showBarDetails(BuildContext context, Map<String, dynamic> bar) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bar['nombre'],
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(bar['direccion']),
              if (bar['horario'] != null) ...[
                const SizedBox(height: 8),
                Text('Horario: ${bar['horario']}'),
              ],
              if (bar['descripcion'] != null) ...[
                const SizedBox(height: 8),
                Text(bar['descripcion']),
              ],
            ],
          ),
        );
      },
    );
  }
}
