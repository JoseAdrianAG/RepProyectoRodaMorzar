import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rodamorzar/services/RouteService.dart';

class CreateRouteScreen extends StatefulWidget {
  @override
  _CreateRouteScreenState createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  double _distance = 0.0;
  int _estimatedTime = 30; // valor por defecto
  LatLng? _startLocation;
  LatLng? _endLocation;
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _startLocation != null &&
        _endLocation != null) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        // Calcular la distancia aproximada entre puntos (en kilómetros)
        final distance = Distance();
        _distance = distance.as(
          LengthUnit.Kilometer,
          _startLocation!,
          _endLocation!,
        );

        // Crear el objeto de ruta
        final routeData = {
          'nombre': _name,
          'descripcion': _description,
          'distancia': _distance.toStringAsFixed(2),
          'tiempo_estimado': _estimatedTime,
          'puntos': [
            {
              'lat': _startLocation!.latitude,
              'lng': _startLocation!.longitude,
              'tipo': 'inicio',
              'nombre': 'Punto de inicio'
            },
            {
              'lat': _endLocation!.latitude,
              'lng': _endLocation!.longitude,
              'tipo': 'fin',
              'nombre': 'Punto final'
            }
          ]
        };

        // Enviar al servidor
        await RouteService.createRoute(routeData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ruta creada correctamente')),
          );
          Navigator.pop(context, true); // Retornar true para indicar éxito
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear la ruta: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Por favor completa todos los campos y selecciona los puntos en el mapa'),
        ),
      );
    }
  }

  void _selectLocation(LatLng position, bool isStart) {
    setState(() {
      if (isStart) {
        _startLocation = position;
      } else {
        _endLocation = position;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Nueva Ruta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 20),
              Text('Selecciona el punto de inicio en el mapa:'),
              Container(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(0, 0),
                    initialZoom: 2,
                    onTap: (tapPosition, point) => _selectLocation(point, true),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    if (_startLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: _startLocation!,
                            child: Icon(Icons.location_on,
                                color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text('Selecciona el punto de destino en el mapa:'),
              Container(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(0, 0),
                    initialZoom: 2,
                    onTap: (tapPosition, point) =>
                        _selectLocation(point, false),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    if (_endLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: _endLocation!,
                            child: Icon(Icons.location_on,
                                color: Colors.blue, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Crear Ruta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
