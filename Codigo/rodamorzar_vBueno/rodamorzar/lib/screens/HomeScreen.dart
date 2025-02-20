import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:rodamorzar/screens/ProfileScreen.dart';
import 'package:rodamorzar/screens/RoutesScreen.dart';
import 'package:rodamorzar/screens/FavoritesScreen.dart';
import 'package:rodamorzar/services/AuthService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  bool _permissionsGranted = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  int _currentIndex = 0;
  List<LatLng> _favoriteRoutes = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    connectToServer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> connectToServer() async {
    const String url = 'https://10.0.2.2:3000';
    try {
      HttpClient client = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode == 200) {
        print('Conectado al servidor exitosamente');
      } else {
        print('Error al conectar con el servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión al servidor: $e');
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      HttpClient client = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);

      final request = await client.getUrl(Uri.parse(
          'https://10.0.2.2:3000/location/search?query=${Uri.encodeComponent(query)}'));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final results = json.decode(responseBody);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      if (results.isNotEmpty) {
        final location = results[0];
        final newLocation = LatLng(location['lat'], location['lon']);
        _mapController.move(newLocation, 13.0);
      }
    } catch (e) {
      print('Error searching location: $e');
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar la ubicación')));
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      setState(() {
        _permissionsGranted = true;
      });
      _determinePosition();
    } else if (status.isDenied) {
      final newStatus = await Permission.location.request();

      if (newStatus.isGranted) {
        setState(() {
          _permissionsGranted = true;
        });
        _determinePosition();
      } else if (newStatus.isPermanentlyDenied) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Permisos necesarios'),
              content: const Text(
                  'Necesitamos acceso a tu ubicación para mostrarte el mapa correctamente. Por favor, habilita los permisos en la configuración.'),
              actions: [
                TextButton(
                  child: const Text('Configuración'),
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Servicio de localización no disponible.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permiso denegado');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permisos permanentemente denegados');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentLocation!, 13.0);
    });
  }

  void _addRouteToFavorites(LatLng route) {
    setState(() {
      _favoriteRoutes.add(route);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ruta añadida a favoritos')),
    );
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        // Ya estamos en Home, no necesitamos hacer nada
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RoutesScreen()),
        );
        return; // Retornamos para no actualizar el índice
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FavoritesScreen(),
          ),
        );
        return; // Retornamos para no actualizar el índice
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inici'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () async {
              final isAuthenticated = await AuthService.isAuthenticated();
              if (isAuthenticated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : null,
                      hintText: 'Buscar localització...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onSubmitted: (value) => _searchLocation(value),
                  ),
                ),
              ],
            ),
          ),
          if (_searchResults.isNotEmpty)
            Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return ListTile(
                      title: Text(result['name']),
                      onTap: () {
                        final newLocation =
                            LatLng(result['lat'], result['lon']);
                        _mapController.move(newLocation, 13.0);
                        setState(() {
                          _searchResults = [];
                          _searchController.clear();
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          Expanded(
            child: _permissionsGranted
                ? FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter:
                          _currentLocation ?? const LatLng(51.5, -0.09),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      if (_currentLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation!,
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  )
                : const Center(
                    child: Text(
                        "Es requerixen permisos d'ubicació per mostar el mapa"),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pedal_bike),
            label: 'Inici',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Rutes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorits',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.my_location),
        onPressed: () {
          if (_currentLocation != null) {
            _mapController.move(_currentLocation!, 13.0);
          }
        },
      ),
    );
  }
}
